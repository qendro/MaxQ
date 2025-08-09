//
//  TestSeedData.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//  This file is for testing seed data functionality during development
//

import Foundation
import CoreData

#if DEBUG
/// Simple test function to verify seed data works
func testSeedDataFunctionality() {
    print("=== Testing Seed Data Functionality ===")
    
    // Create in-memory context for testing
    let container = NSPersistentContainer(name: "MaxQ")
    container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    
    container.loadPersistentStores { _, error in
        if let error = error {
            print("❌ Failed to load test store: \(error)")
            return
        }
        
        let context = container.viewContext
        let seedManager = SeedDataManager(context: context)
        
        // Clear any existing seed version
        UserDefaults.standard.removeObject(forKey: "seedVersion")
        
        print("📊 Initial state:")
        print("   - Seed version stored: \(SeedVersion.stored.rawValue)")
        print("   - Needs seeding: \(SeedVersion.needsSeeding)")
        print("   - Current version: \(SeedVersion.current.rawValue)")
        
        // Test seeding
        print("\n🌱 Running seed process...")
        seedManager.seedIfNeeded()
        
        // Verify results
        do {
            let programCount = try seedManager.getSeededProgramCount()
            let exerciseCount = try seedManager.getBaselineExerciseCount()
            
            print("\n✅ Seeding completed:")
            print("   - Programs created: \(programCount)")
            print("   - Baseline exercises created: \(exerciseCount)")
            print("   - Final seed version: \(SeedVersion.stored.rawValue)")
            print("   - Still needs seeding: \(SeedVersion.needsSeeding)")
            
            // Test specific program content
            let programFetch: NSFetchRequest<Program> = Program.fetchRequest()
            programFetch.predicate = NSPredicate(format: "name == %@", "Classic")
            let classicPrograms = try context.fetch(programFetch)
            
            if let classic = classicPrograms.first {
                print("\n📋 Classic Program Details:")
                print("   - Name: \(classic.name ?? "Unknown")")
                print("   - Days count: \(classic.days?.count ?? 0)")
                print("   - Is preloaded: \(classic.isPreloaded)")
                
                if let days = classic.days?.allObjects as? [WorkoutDay] {
                    for day in days.sorted(by: { $0.order < $1.order }) {
                        let exerciseCount = day.exercises?.count ?? 0
                        print("     - \(day.name ?? "Unknown"): \(exerciseCount) exercises")
                    }
                }
            }
            
            // Test that no logs were created
            let logFetch: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
            let logCount = try context.count(for: logFetch)
            print("\n📝 Exercise logs created: \(logCount) (should be 0)")
            
            if logCount == 0 {
                print("✅ Correctly avoided creating historical logs during seeding")
            } else {
                print("❌ Incorrectly created historical logs during seeding")
            }
            
        } catch {
            print("❌ Error verifying seed results: \(error)")
        }
        
        // Test second run (should skip)
        print("\n🔄 Testing second run (should skip)...")
        seedManager.seedIfNeeded()
        
        do {
            let finalProgramCount = try seedManager.getSeededProgramCount()
            print("   - Programs after second run: \(finalProgramCount) (should be same)")
        } catch {
            print("❌ Error in second run test: \(error)")
        }
    }
    
    print("\n=== Seed Data Test Complete ===")
}
#endif