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
        WorkoutDaysListView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
