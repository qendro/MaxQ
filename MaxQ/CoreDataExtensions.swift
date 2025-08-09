//
//  CoreDataExtensions.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation
import CoreData

// MARK: - Exercise Extensions

extension Exercise {
    /// Returns the recommended sets as an array of SetData
    var recommendedSetsArray: [SetData] {
        return [
            SetData(weight: recSet1Weight, reps: recSet1Reps),
            SetData(weight: recSet2Weight, reps: recSet2Reps),
            SetData(weight: recSet3Weight, reps: recSet3Reps),
            SetData(weight: recSet4Weight, reps: recSet4Reps)
        ]
    }
    
    /// Updates the recommended sets from an array of SetData
    func updateRecommendedSets(from sets: [SetData]) {
        let setsToUpdate = Array(sets.prefix(4)) // Ensure max 4 sets
        
        // Clear all sets first
        recSet1Weight = nil
        recSet1Reps = nil
        recSet2Weight = nil
        recSet2Reps = nil
        recSet3Weight = nil
        recSet3Reps = nil
        recSet4Weight = nil
        recSet4Reps = nil
        
        // Set the provided data
        for (index, set) in setsToUpdate.enumerated() {
            switch index {
            case 0:
                recSet1Weight = set.weight
                recSet1Reps = set.reps
            case 1:
                recSet2Weight = set.weight
                recSet2Reps = set.reps
            case 2:
                recSet3Weight = set.weight
                recSet3Reps = set.reps
            case 3:
                recSet4Weight = set.weight
                recSet4Reps = set.reps
            default:
                break
            }
        }
    }
    
    /// Updates recommended sets from today's values (for "Update Recommended from Today" functionality)
    func updateRecommendedFromToday(using repository: WorkoutRepositoryProtocol) {
        guard let todaysLog = repository.fetchTodaysLog(for: self) else { return }
        
        let todaysSets = [
            SetData(weight: todaysLog.set1Weight, reps: todaysLog.set1Reps),
            SetData(weight: todaysLog.set2Weight, reps: todaysLog.set2Reps),
            SetData(weight: todaysLog.set3Weight, reps: todaysLog.set3Reps),
            SetData(weight: todaysLog.set4Weight, reps: todaysLog.set4Reps)
        ]
        
        updateRecommendedSets(from: todaysSets)
    }
}

// MARK: - ExerciseLog Extensions

extension ExerciseLog {
    /// Returns the performed sets as an array of SetData
    var setsArray: [SetData] {
        return [
            SetData(weight: set1Weight, reps: set1Reps),
            SetData(weight: set2Weight, reps: set2Reps),
            SetData(weight: set3Weight, reps: set3Reps),
            SetData(weight: set4Weight, reps: set4Reps)
        ]
    }
    
    /// Updates the performed sets from an array of SetData
    func updateSets(from sets: [SetData]) {
        let setsToUpdate = Array(sets.prefix(4)) // Ensure max 4 sets
        
        // Clear all sets first
        set1Weight = nil
        set1Reps = nil
        set2Weight = nil
        set2Reps = nil
        set3Weight = nil
        set3Reps = nil
        set4Weight = nil
        set4Reps = nil
        
        // Set the provided data
        for (index, set) in setsToUpdate.enumerated() {
            switch index {
            case 0:
                set1Weight = set.weight
                set1Reps = set.reps
            case 1:
                set2Weight = set.weight
                set2Reps = set.reps
            case 2:
                set3Weight = set.weight
                set3Reps = set.reps
            case 3:
                set4Weight = set.weight
                set4Reps = set.reps
            default:
                break
            }
        }
    }
    
    /// Returns true if this log has any completed sets
    var hasCompletedSets: Bool {
        return setsArray.contains { $0.isComplete }
    }
    
    /// Returns the total volume (weight × reps) for this log
    var totalVolume: Double {
        return setsArray.reduce(0) { total, set in
            guard let weight = set.weight, let reps = set.reps else { return total }
            return total + (weight * Double(reps))
        }
    }
}

// MARK: - WorkoutDay Extensions

extension WorkoutDay {
    /// Returns the exercises for this day sorted by order
    var sortedExercises: [Exercise] {
        let exercisesSet = exercises as? Set<Exercise> ?? Set()
        return exercisesSet.sorted { exercise1, exercise2 in
            if exercise1.order == exercise2.order {
                return (exercise1.name ?? "") < (exercise2.name ?? "")
            }
            return exercise1.order < exercise2.order
        }
    }
    
    /// Returns the count of exercises in this day
    var exerciseCount: Int {
        return exercises?.count ?? 0
    }
    
    /// Updates the order of exercises in this day
    func updateExerciseOrder(_ exercises: [Exercise]) {
        for (index, exercise) in exercises.enumerated() {
            exercise.order = Int16(index)
        }
    }
}

// MARK: - Program Extensions

extension Program {
    /// Returns the active workout days for this program sorted by order
    var activeDaysSorted: [WorkoutDay] {
        let daysSet = days as? Set<WorkoutDay> ?? Set()
        return daysSet.filter { $0.isActive }.sorted { day1, day2 in
            if day1.order == day2.order {
                return (day1.createdAt ?? Date.distantPast) < (day2.createdAt ?? Date.distantPast)
            }
            return day1.order < day2.order
        }
    }
    
    /// Returns the count of active days in this program
    var activeDayCount: Int {
        let daysSet = days as? Set<WorkoutDay> ?? Set()
        return daysSet.filter { $0.isActive }.count
    }
    
    /// Updates the order of days in this program
    func updateDayOrder(_ days: [WorkoutDay]) {
        for (index, day) in days.enumerated() {
            day.order = Int16(index)
        }
    }
}