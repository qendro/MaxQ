//
//  HomeViewModel.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation
import SwiftUI
import CoreData

/// ViewModel for the Home screen managing workout days
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var workoutDays: [WorkoutDay] = []
    @Published var isEditMode: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let repository: WorkoutRepositoryProtocol
    private var activeProgram: Program?
    let undoManager = UndoManager()
    
    // MARK: - Initialization
    
    init(repository: WorkoutRepositoryProtocol = WorkoutRepository.shared) {
        self.repository = repository
        ensureSeedData()
        loadActiveProgram()
        fetchActiveDays()
    }
    
    // MARK: - Public Methods
    
    /// Fetches active workout days with proper sorting (order primary, createdAt tiebreaker)
    func fetchActiveDays() {
        guard let program = activeProgram else {
            workoutDays = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            let days = await repository.fetchActiveDays(for: program)
            await MainActor.run {
                workoutDays = days
                isLoading = false
            }
        }
    }
    
    /// Creates a new workout day
    /// - Parameter name: The name for the new workout day
    func createDay(name: String) {
        guard let program = activeProgram else {
            errorMessage = "No active program selected"
            return
        }
        
        let cleanedName = InputValidator.cleanExerciseName(name)
        guard InputValidator.validateExerciseName(cleanedName) else {
            errorMessage = "Day name cannot be empty"
            return
        }
        
        Task {
            let newDay = await repository.createDay(name: cleanedName, program: program)
            fetchActiveDays() // Refresh the list
        }
    }
    
    /// Renames an existing workout day
    /// - Parameters:
    ///   - day: The workout day to rename
    ///   - newName: The new name for the workout day
    func renameDay(_ day: WorkoutDay, to newName: String) {
        let cleanedName = InputValidator.cleanExerciseName(newName)
        guard InputValidator.validateExerciseName(cleanedName) else {
            errorMessage = "Day name cannot be empty"
            return
        }
        
        day.name = cleanedName
        Task {
            await repository.updateDay(day)
            fetchActiveDays() // Refresh the list
        }
    }
    
    /// Soft deletes a workout day with 5-second undo functionality
    /// - Parameter day: The workout day to delete
    func deleteDay(_ day: WorkoutDay) {
        let dayName = day.name ?? "Unknown Day"
        let dayToRestore = day
        
        // Perform the soft delete immediately
        Task {
            await repository.softDeleteDay(day)
            fetchActiveDays() // Refresh the list
            
            // Show undo option
            undoManager.showUndo(message: "Deleted \"\(dayName)\"") { [weak self] in
                self?.restoreDay(dayToRestore)
            }
        }
    }
    
    /// Restores a soft-deleted workout day
    /// - Parameter day: The workout day to restore
    private func restoreDay(_ day: WorkoutDay) {
        day.isActive = true
        Task {
            await repository.updateDay(day)
            fetchActiveDays() // Refresh the list
        }
    }
    
    /// Reorders workout days using drag and drop
    /// - Parameters:
    ///   - source: The source indices
    ///   - destination: The destination index
    func reorderDays(from source: IndexSet, to destination: Int) {
        var updatedDays = workoutDays
        updatedDays.move(fromOffsets: source, toOffset: destination)
        
        // Update the order field for all affected days
        for (index, day) in updatedDays.enumerated() {
            day.order = Int16(index)
        }
        
        // Save all changes
        Task {
            for day in updatedDays {
                await repository.updateDay(day)
            }
            await MainActor.run {
                workoutDays = updatedDays
            }
        }
    }
    
    /// Toggles edit mode for the day list
    func toggleEditMode() {
        isEditMode.toggle()
        
        // Cancel any pending undo actions when exiting edit mode
        if !isEditMode {
            undoManager.cancelUndo()
        }
    }
    
    /// Gets the exercise count for a workout day
    /// - Parameter day: The workout day
    /// - Returns: The number of exercises in the day
    func getExerciseCount(for day: WorkoutDay) -> Int {
        // For now, return a default value since we don't have cached exercise data
        // This could be enhanced later with proper caching
        return 0
    }
    
    /// Clears any error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    /// Ensures seed data is available
    private func ensureSeedData() {
        let seedManager = SeedDataManager(context: Database.shared.viewContext)
        seedManager.seedIfNeeded()
    }
    
    /// Loads the active program from UserDefaults or sets a default
    private func loadActiveProgram() {
        Task {
            // Try to load from UserDefaults first
            if let savedProgramId = UserDefaults.standard.string(forKey: "activeProgram"),
               let programId = UUID(uuidString: savedProgramId),
               let savedProgram = await repository.fetchProgram(by: programId) {
                await MainActor.run {
                    activeProgram = savedProgram
                }
            } else {
                // Fall back to first available program
                let programs = await repository.fetchPrograms()
                await MainActor.run {
                    activeProgram = programs.first
                    
                    // Save the default selection
                    if let program = activeProgram, let programId = program.id {
                        UserDefaults.standard.set(programId.uuidString, forKey: "activeProgram")
                    }
                }
            }
            
            await MainActor.run {
                if activeProgram == nil {
                    errorMessage = "No programs available. Please check seed data."
                }
            }
        }
    }
    
    /// Sets the active program (for future program switching functionality)
    /// - Parameter program: The program to set as active
    func setActiveProgram(_ program: Program) {
        activeProgram = program
        fetchActiveDays()
        
        // Save to UserDefaults for persistence
        if let programId = program.id {
            UserDefaults.standard.set(programId.uuidString, forKey: "activeProgram")
        }
    }
}

// MARK: - Preview Support

extension HomeViewModel {
    /// Creates a preview instance with mock data
    @MainActor
    static var preview: HomeViewModel {
        let repository = WorkoutRepository.preview
        return HomeViewModel(repository: repository)
    }
}