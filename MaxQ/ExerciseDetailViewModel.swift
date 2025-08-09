//
//  ExerciseDetailViewModel.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation
import SwiftUI
import CoreData

/// ViewModel for individual Exercise detail: today's editing and history
@MainActor
class ExerciseDetailViewModel: ObservableObject {
    // MARK: - Published State
    @Published var exercise: Exercise
    @Published var exerciseName: String
    @Published var todaysSets: [SetData] = [SetData](repeating: SetData(weight: nil, reps: nil), count: 4)
    @Published var history: [HistoricalEntry] = []
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let repository: WorkoutRepositoryProtocol
    
    // MARK: - Init
    init(exercise: Exercise, repository: WorkoutRepositoryProtocol = WorkoutRepository.shared) {
        self.exercise = exercise
        self.exerciseName = exercise.name ?? ""
        self.repository = repository
        load()
    }
    
    // MARK: - Loading
    func load() {
        errorMessage = nil
        loadTodaysSets()
        loadHistory()
    }
    
    private func loadTodaysSets() {
        if let log = repository.fetchTodaysLog(for: exercise) {
            todaysSets = [
                SetData(weight: log.set1Weight, reps: log.set1Reps),
                SetData(weight: log.set2Weight, reps: log.set2Reps),
                SetData(weight: log.set3Weight, reps: log.set3Reps),
                SetData(weight: log.set4Weight, reps: log.set4Reps)
            ]
        } else {
            todaysSets = exercise.recommendedSetsArray
        }
    }
    
    private func loadHistory() {
        let hasTodayLog = repository.fetchTodaysLog(for: exercise) != nil
        let logs = repository.fetchRecentLogs(for: exercise, excludingToday: !hasTodayLog, limit: 10)
        // Group by date and take the 3 most recent distinct days
        let grouped = Dictionary(grouping: logs) { (log: ExerciseLog) in
            log.dateNormalizedToLocalMidnight ?? Date.distantPast
        }
        let sortedDates = grouped.keys.sorted(by: { $0 > $1 })
        var entries: [HistoricalEntry] = []
        for date in sortedDates.prefix(3) {
            if let anyLog = grouped[date]?.first {
                entries.append(HistoricalEntry(from: anyLog))
            }
        }
        history = entries
    }
    
    // MARK: - Editing Today's Sets
    func updateWeight(setIndex: Int, weightString: String) {
        guard (0..<4).contains(setIndex) else { return }
        let cleaned = weightString.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = Double(cleaned)
        if !InputValidator.validateWeight(value) {
            errorMessage = "Weight must be ≥ 0"
            return
        }
        var s = todaysSets[setIndex]
        todaysSets[setIndex] = SetData(weight: value, reps: s.reps)
    }
    
    func updateReps(setIndex: Int, repsString: String) {
        guard (0..<4).contains(setIndex) else { return }
        let cleaned = repsString.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = Int16(cleaned)
        if !InputValidator.validateReps(value) {
            errorMessage = "Reps must be ≥ 0"
            return
        }
        var s = todaysSets[setIndex]
        todaysSets[setIndex] = SetData(weight: s.weight, reps: value)
    }
    
    func commitTodaysSets() {
        let tuples: [(Double?, Int16?)] = todaysSets.map { ($0.weight, $0.reps) }
        _ = repository.createOrUpdateTodaysLog(for: exercise, sets: tuples)
        // refresh today's state and history so UI reflects saved values
        loadTodaysSets()
        loadHistory()
    }
    
    // MARK: - Exercise Name Editing
    func rename(to newName: String) {
        let cleaned = InputValidator.cleanExerciseName(newName)
        guard InputValidator.validateExerciseName(cleaned) else {
            errorMessage = "Exercise name cannot be empty"
            return
        }
        exercise.name = cleaned
        exerciseName = cleaned
        repository.updateExercise(exercise)
    }
    
    // MARK: - Recommended Template
    func updateRecommendedFromToday() {
        exercise.updateRecommendedFromToday(using: repository)
        repository.updateExercise(exercise)
        // reload today's default template only if there is no log; otherwise keep today's edited values
        if repository.fetchTodaysLog(for: exercise) == nil {
            loadTodaysSets()
        }
    }
}


