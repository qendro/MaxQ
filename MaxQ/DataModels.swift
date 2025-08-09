//
//  DataModels.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation

// MARK: - Set Data Structure

/// Represents a single set with weight and reps
struct SetData {
    let weight: Double?
    let reps: Int16?
    
    /// Returns a formatted display string for the set (e.g., "135×8")
    var displayString: String {
        guard let weight = weight, let reps = reps else { return "" }
        return "\(Int(weight))×\(reps)"
    }
    
    /// Returns true if both weight and reps have values
    var isComplete: Bool {
        return weight != nil && reps != nil
    }
    
    /// Returns true if the set is empty (no weight or reps)
    var isEmpty: Bool {
        return weight == nil && reps == nil
    }
}

// MARK: - Exercise Display Model

/// Model for displaying exercise data in the UI
struct ExerciseDisplayModel {
    let id: UUID
    let name: String
    let isBaseline: Bool
    let recommendedSets: [SetData]
    let todaysSets: [SetData]
    
    init(from exercise: Exercise, todaysLog: ExerciseLog? = nil) {
        self.id = exercise.id ?? UUID()
        self.name = exercise.name ?? ""
        self.isBaseline = exercise.isBaseline
        
        // Extract recommended sets
        self.recommendedSets = [
            SetData(weight: exercise.recSet1Weight, reps: exercise.recSet1Reps),
            SetData(weight: exercise.recSet2Weight, reps: exercise.recSet2Reps),
            SetData(weight: exercise.recSet3Weight, reps: exercise.recSet3Reps),
            SetData(weight: exercise.recSet4Weight, reps: exercise.recSet4Reps)
        ]
        
        // Extract today's sets from log if available
        if let log = todaysLog {
            self.todaysSets = [
                SetData(weight: log.set1Weight, reps: log.set1Reps),
                SetData(weight: log.set2Weight, reps: log.set2Reps),
                SetData(weight: log.set3Weight, reps: log.set3Reps),
                SetData(weight: log.set4Weight, reps: log.set4Reps)
            ]
        } else {
            // Use recommended sets as default for today
            self.todaysSets = recommendedSets
        }
    }
}

// MARK: - Historical Entry Model

/// Model for displaying historical exercise data
struct HistoricalEntry {
    let date: Date
    let sets: [SetData]
    
    /// Returns a formatted display string for the historical entry
    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dateString = formatter.string(from: date)
        
        let setsString = sets.map { $0.displayString }.joined(separator: " | ")
        return "\(dateString): \(setsString)"
    }
    
    /// Returns a week number relative to today for display
    var weekNumber: Int {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.weekOfYear], from: date, to: today)
        return (components.weekOfYear ?? 0) + 1
    }
    
    /// Returns a formatted display string with week number
    var displayStringWithWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dateString = formatter.string(from: date)
        
        let setsString = sets.map { $0.displayString }.joined(separator: " | ")
        return "Week \(weekNumber) (\(dateString)): \(setsString)"
    }
    
    init(from log: ExerciseLog) {
        self.date = log.dateNormalizedToLocalMidnight ?? Date()
        self.sets = [
            SetData(weight: log.set1Weight, reps: log.set1Reps),
            SetData(weight: log.set2Weight, reps: log.set2Reps),
            SetData(weight: log.set3Weight, reps: log.set3Reps),
            SetData(weight: log.set4Weight, reps: log.set4Reps)
        ]
    }
}

// MARK: - Input Validation

/// Utility functions for validating user input
struct InputValidator {
    /// Validates weight input (must be >= 0, decimal allowed)
    static func validateWeight(_ weight: Double?) -> Bool {
        guard let weight = weight else { return true } // nil is valid (empty)
        return weight >= 0
    }
    
    /// Validates reps input (must be >= 0, integer only)
    static func validateReps(_ reps: Int16?) -> Bool {
        guard let reps = reps else { return true } // nil is valid (empty)
        return reps >= 0
    }
    
    /// Validates exercise name (must not be empty after trimming)
    static func validateExerciseName(_ name: String?) -> Bool {
        guard let name = name else { return false }
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Returns a cleaned exercise name (trimmed whitespace)
    static func cleanExerciseName(_ name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}