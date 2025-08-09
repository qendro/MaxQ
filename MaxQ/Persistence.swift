//
//  Persistence.swift
//  MaxQ
//
//  Created by Qendrim Qeriqi on 8/8/25.
//

import CoreData

/// CoreDataManager singleton for managing the Core Data stack with lightweight migration support
class CoreDataManager {
    static let shared = CoreDataManager()
    
    @MainActor
    static let preview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true)
        // Add preview data if needed for SwiftUI previews
        return manager
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MaxQ")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure for lightweight migration
        container.persistentStoreDescriptions.forEach { storeDescription in
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                // For now, we'll log and crash during development
                print("Core Data error: \(error), \(error.userInfo)")
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private let inMemory: Bool
    
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Save error: \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Legacy PersistenceController for compatibility
struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        self.container = CoreDataManager.shared.persistentContainer
    }
}
