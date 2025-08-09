//
//  DayDetailViewModel.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation
import SwiftUI
import CoreData

/// ViewModel for Day Detail screen managing exercises and today's sets
@MainActor
class DayDetailViewModel: ObservableObject {
    // MARK: - Nested Types
    
    enum FocusField: Hashable {
        case weight
        case reps
    }
    
    struct FocusedCell: Hashable {
        let exerciseId: UUID
        let setIndex: Int
        let field: FocusField
    }
    
    // MARK: - Published State
    
    @Published var exercises: [Exercise] = []
    @Published var todaysSetsByExerciseId: [UUID: [SetData]] = [:]
    @Published var focusedCell: FocusedCell?
    @Published var errorMessage: String?
    @Published var invalidInputs: Set<FocusedCell> = []
    
    // MARK: - Dependencies
    
    let undoManager = UndoManager()
    private let repository: WorkoutRepositoryProtocol
    private(set) var day: WorkoutDay
    
    // MARK: - Init
    
    init(day: WorkoutDay,
         repository: WorkoutRepositoryProtocol = WorkoutRepository.shared) {
        self.day = day
        self.repository = repository
        loadExercises()
    }
    
    // MARK: - Focus Navigation
    
    /// Returns the next focus cell for Return key navigation within an exercise
    func nextFocus(after cell: FocusedCell) -> FocusedCell? {
        switch cell.field {
        case .weight:
            return FocusedCell(exerciseId: cell.exerciseId, setIndex: cell.setIndex, field: .reps)
        case .reps:
            let nextIndex = cell.setIndex + 1
            if nextIndex < 4 {
                return FocusedCell(exerciseId: cell.exerciseId, setIndex: nextIndex, field: .weight)
            } else {
                return nil
            }
        }
    }

    // MARK: - Loading
    
    func loadExercises() {
        exercises = repository.fetchExercisesForDay(day)
        // Preload today's sets map using today's log if available, otherwise recommended
        var map: [UUID: [SetData]] = [:]
        for exercise in exercises {
            let id = exercise.id ?? UUID()
            if let log = repository.fetchTodaysLog(for: exercise) {
                map[id] = [
                    SetData(weight: log.set1Weight, reps: log.set1Reps),
                    SetData(weight: log.set2Weight, reps: log.set2Reps),
                    SetData(weight: log.set3Weight, reps: log.set3Reps),
                    SetData(weight: log.set4Weight, reps: log.set4Reps)
                ]
            } else {
                map[id] = exercise.recommendedSetsArray
            }
        }
        todaysSetsByExerciseId = map
    }
    
    // MARK: - Accessors
    
    func displayModel(for exercise: Exercise) -> ExerciseDisplayModel {
        let log = repository.fetchTodaysLog(for: exercise)
        return ExerciseDisplayModel(from: exercise, todaysLog: log)
    }
    
    func todaysSets(for exercise: Exercise) -> [SetData] {
        let id = exercise.id ?? UUID()
        return todaysSetsByExerciseId[id] ?? exercise.recommendedSetsArray
    }
    
    /// Returns last 3 historical entries (excluding today unless a log exists for today which is handled separately)
    func lastThreeWeeks(for exercise: Exercise) -> [HistoricalEntry] {
        let logs = repository.fetchRecentLogs(for: exercise, excludingToday: true, limit: 3)
        return logs.map { HistoricalEntry(from: $0) }
    }
    
    // MARK: - Editing & Validation
    
    func updateWeight(for exercise: Exercise, setIndex: Int, weightString: String) {
        let cleaned = weightString.trimmingCharacters(in: .whitespacesAndNewlines)
        let weight = Double(cleaned)
        if !InputValidator.validateWeight(weight) {
            invalidInputs.insert(FocusedCell(exerciseId: exercise.id ?? UUID(), setIndex: setIndex, field: .weight))
            errorMessage = "Weight must be ≥ 0"
            return
        }
        invalidInputs.remove(FocusedCell(exerciseId: exercise.id ?? UUID(), setIndex: setIndex, field: .weight))
        setValue(for: exercise, setIndex: setIndex, weight: weight, reps: nil)
    }
    
    func updateReps(for exercise: Exercise, setIndex: Int, repsString: String) {
        let cleaned = repsString.trimmingCharacters(in: .whitespacesAndNewlines)
        let repsInt = Int16(cleaned)
        if !InputValidator.validateReps(repsInt) {
            invalidInputs.insert(FocusedCell(exerciseId: exercise.id ?? UUID(), setIndex: setIndex, field: .reps))
            errorMessage = "Reps must be ≥ 0"
            return
        }
        invalidInputs.remove(FocusedCell(exerciseId: exercise.id ?? UUID(), setIndex: setIndex, field: .reps))
        setValue(for: exercise, setIndex: setIndex, weight: nil, reps: repsInt)
    }
    
    private func setValue(for exercise: Exercise, setIndex: Int, weight: Double?, reps: Int16?) {
        guard setIndex >= 0 && setIndex < 4 else { return }
        let id = exercise.id ?? UUID()
        var sets = todaysSetsByExerciseId[id] ?? exercise.recommendedSetsArray
        var existing = sets[setIndex]
        let newWeight = weight ?? existing.weight
        let newReps = reps ?? existing.reps
        sets[setIndex] = SetData(weight: newWeight, reps: newReps)
        todaysSetsByExerciseId[id] = sets
    }
    
    /// Persists the current today's sets for the exercise into today's log
    func commitTodaysSets(for exercise: Exercise) {
        let id = exercise.id ?? UUID()
        let sets = todaysSetsByExerciseId[id] ?? exercise.recommendedSetsArray
        // Transform to repository tuple format
        let tuples: [(Double?, Int16?)] = sets.map { ($0.weight, $0.reps) }
        _ = repository.createOrUpdateTodaysLog(for: exercise, sets: tuples)
        // Refresh so computed state reflects saved values
        loadExercises()
    }
    
    // MARK: - Exercise Management
    
    func addExercise(named name: String) {
        let cleaned = InputValidator.cleanExerciseName(name)
        guard InputValidator.validateExerciseName(cleaned) else {
            errorMessage = "Exercise name cannot be empty"
            return
        }
        let newExercise = repository.createExercise(name: cleaned, day: day, isBaseline: false)
        // Initialize today's sets with recommended (which are empty by default)
        let id = newExercise.id ?? UUID()
        todaysSetsByExerciseId[id] = newExercise.recommendedSetsArray
        loadExercises()
    }
    
    func deleteExercise(_ exercise: Exercise) {
        let exerciseName = exercise.name ?? "Exercise"
        // Capture for undo
        let dayRef = day
        let isBaseline = exercise.isBaseline
        let order = exercise.order
        let recSets = exercise.recommendedSetsArray
        let exerciseId = exercise.id
        
        repository.deleteExercise(exercise)
        loadExercises()
        
        undoManager.showUndo(message: "Deleted \"\(exerciseName)\"") { [weak self] in
            guard let self = self else { return }
            // Recreate exercise
            let restored = self.repository.createExercise(name: exerciseName, day: dayRef, isBaseline: isBaseline)
            restored.order = order
            restored.updateRecommendedSets(from: recSets)
            if let restoredId = exerciseId {
                restored.id = restoredId
            }
            self.repository.updateExercise(restored)
            self.loadExercises()
        }
    }
    
    func updateRecommendedFromToday(for exercise: Exercise) {
        exercise.updateRecommendedFromToday(using: repository)
        repository.updateExercise(exercise)
        loadExercises()
    }
}


