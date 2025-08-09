//
//  HomeViewModelTests.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation
import CoreData

#if DEBUG
/// Simple test function to verify HomeViewModel functionality
@MainActor
func testHomeViewModelFunctionality() {
    print("=== Testing HomeViewModel Functionality ===")
    
    // Create test context
    let context = CoreDataManager.preview.viewContext
    let repository = WorkoutRepository(context: context)
    
    // Ensure seed data
    let seedManager = SeedDataManager(context: context)
    do {
        try seedManager.forceSeed()
        print("✅ Seed data created successfully")
    } catch {
        print("❌ Failed to create seed data: \(error)")
        return
    }
    
    // Test HomeViewModel initialization
    let viewModel = HomeViewModel(repository: repository)
    print("✅ HomeViewModel initialized")
    
    // Test fetching active days
    viewModel.fetchActiveDays()
    print("✅ Fetched \(viewModel.workoutDays.count) workout days")
    
    // Test creating a new day
    let initialCount = viewModel.workoutDays.count
    viewModel.createDay(name: "Test Day")
    print("✅ Created new day. Count: \(initialCount) -> \(viewModel.workoutDays.count)")
    
    // Test renaming a day
    if let firstDay = viewModel.workoutDays.first {
        let originalName = firstDay.name
        viewModel.renameDay(firstDay, to: "Renamed Day")
        print("✅ Renamed day from '\(originalName ?? "nil")' to '\(firstDay.name ?? "nil")'")
    }
    
    // Test soft delete with undo
    if let dayToDelete = viewModel.workoutDays.last {
        let dayName = dayToDelete.name
        let countBeforeDelete = viewModel.workoutDays.count
        
        viewModel.deleteDay(dayToDelete)
        print("✅ Soft deleted day '\(dayName ?? "nil")'. Count: \(countBeforeDelete) -> \(viewModel.workoutDays.count)")
        
        // Test undo functionality
        if viewModel.undoManager.undoAction != nil {
            viewModel.undoManager.performUndo()
            print("✅ Undo performed. Count restored to: \(viewModel.workoutDays.count)")
        }
    }
    
    // Test reordering
    if viewModel.workoutDays.count >= 2 {
        let originalOrder = viewModel.workoutDays.map { $0.name ?? "Unknown" }
        viewModel.reorderDays(from: IndexSet([0]), to: 2)
        let newOrder = viewModel.workoutDays.map { $0.name ?? "Unknown" }
        print("✅ Reordered days:")
        print("   Original: \(originalOrder)")
        print("   New: \(newOrder)")
    }
    
    // Test edit mode toggle
    viewModel.toggleEditMode()
    print("✅ Edit mode toggled to: \(viewModel.isEditMode)")
    
    // Test exercise count
    if let firstDay = viewModel.workoutDays.first {
        let exerciseCount = viewModel.getExerciseCount(for: firstDay)
        print("✅ Exercise count for '\(firstDay.name ?? "Unknown")': \(exerciseCount)")
    }
    
    // Test program switching functionality
    let programs = repository.fetchPrograms()
    if programs.count > 1 {
        let secondProgram = programs[1]
        viewModel.setActiveProgram(secondProgram)
        print("✅ Switched to program: \(secondProgram.name ?? "Unknown")")
        print("   New day count: \(viewModel.workoutDays.count)")
    }
    
    print("=== HomeViewModel Tests Complete ===")
}
#endif