//
//  ContentView.swift
//  MaxQ
//
//  Created by Qendrim Qeriqi on 8/8/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            WorkoutDaysListView()
                .tabItem { Label("Home", systemImage: "list.bullet") }
            ProgressViewScreen()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
