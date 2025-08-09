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
        
        // Clear all sets first (set to default values)
        recSet1Weight = 0.0
        recSet1Reps = 0
        recSet2Weight = 0.0
        recSet2Reps = 0
        recSet3Weight = 0.0
        recSet3Reps = 0
        recSet4Weight = 0.0
        recSet4Reps = 0
        
        // Set the provided data
        for (index, set) in setsToUpdate.enumerated() {
            switch index {
            case 0:
                recSet1Weight = set.weight ?? 0.0
                recSet1Reps = set.reps ?? 0
            case 1:
                recSet2Weight = set.weight ?? 0.0
                recSet2Reps = set.reps ?? 0
            case 2:
                recSet3Weight = set.weight ?? 0.0
                recSet3Reps = set.reps ?? 0
            case 3:
                recSet4Weight = set.weight ?? 0.0
                recSet4Reps = set.reps ?? 0
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
        
        // Clear all sets first (set to default values)
        set1Weight = 0.0
        set1Reps = 0
        set2Weight = 0.0
        set2Reps = 0
        set3Weight = 0.0
        set3Reps = 0
        set4Weight = 0.0
        set4Reps = 0
        
        // Set the provided data
        for (index, set) in setsToUpdate.enumerated() {
            switch index {
            case 0:
                set1Weight = set.weight ?? 0.0
                set1Reps = set.reps ?? 0
            case 1:
                set2Weight = set.weight ?? 0.0
                set2Reps = set.reps ?? 0
            case 2:
                set3Weight = set.weight ?? 0.0
                set3Reps = set.reps ?? 0
            case 3:
                set4Weight = set.weight ?? 0.0
                set4Reps = set.reps ?? 0
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