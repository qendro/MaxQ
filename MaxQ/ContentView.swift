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
                .tabItem { 
                    Label("Home", systemImage: "house.fill")
                }
            LogView()
                .tabItem { 
                    Label("Log", systemImage: "doc.text.fill") 
                }
            ProgressViewScreen()
                .tabItem { 
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis") 
                }
            SettingsView()
                .tabItem { 
                    Label("Settings", systemImage: "gearshape.fill") 
                }
        }
        .tint(DS.brand)
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Set shadow for elevation
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, Database.preview.viewContext)
}
