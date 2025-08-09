//
//  MaxQApp.swift
//  MaxQ
//
//  Created by Qendrim Qeriqi on 8/8/25.
//

import SwiftUI

@main
struct MaxQApp: App {
    let coreDataManager = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                .onAppear {
                    // Perform seed data initialization on app launch
                    let seedManager = SeedDataManager(context: coreDataManager.viewContext)
                    seedManager.seedIfNeeded()
                }
        }
    }
}
