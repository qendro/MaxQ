//
//  WorkoutRepository.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation
import CoreData

// MARK: - Repository Protocol

protocol WorkoutRepositoryProtocol {
    // Program operations
    func fetchPrograms() -> [Program]
    func fetchProgram(by id: UUID) -> Program?
    
    // WorkoutDay operations
    func fetchActiveDays(for program: Program) -> [WorkoutDay]
    func createDay(name: String, program: Program) -> WorkoutDay
    func updateDay(_ day: WorkoutDay)
    func softDeleteDay(_ day: WorkoutDay)
    
    // Exercise operations
    func fetchExercisesForDay(_ day: WorkoutDay) -> [Exercise]
    func createExercise(name: String, day: WorkoutDay, isBaseline: Bool) -> Exercise
    func updateExercise(_ exercise: Exercise)
    func deleteExercise(_ exercise: Exercise)
    
    // ExerciseLog operations
    func fetchTodaysLog(for exercise: Exercise) -> ExerciseLog?
    func createOrUpdateTodaysLog(for exercise: Exercise, sets: [(weight: Double?, reps: Int16?)]) -> ExerciseLog
    func fetchRecentLogs(for exercise: Exercise, limit: Int) -> [ExerciseLog]
    func fetchRecentLogs(for exercise: Exercise, excludingToday: Bool, limit: Int) -> [ExerciseLog]
}

// MARK: - Date Utilities

extension Date {
    /// Normalizes a date to local midnight (00:00:00) for consistent storage
    var normalizedToLocalMidnight: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
    
    /// Returns today's date normalized to local midnight
    static var todayNormalized: Date {
        return Date().normalizedToLocalMidnight
    }
}

// MARK: - Concrete Repository Implementation

class WorkoutRepository: WorkoutRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Program Operations
    
    func fetchPrograms() -> [Program] {
        let request: NSFetchRequest<Program> = Program.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Program.isPreloaded, ascending: false),
            NSSortDescriptor(keyPath: \Program.createdAt, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching programs: \(error)")
            return []
        }
    }
    
    func fetchProgram(by id: UUID) -> Program? {
        let request: NSFetchRequest<Program> = Program.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching program by id: \(error)")
            return nil
        }
    }
    
    // MARK: - WorkoutDay Operations
    
    func fetchActiveDays(for program: Program) -> [WorkoutDay] {
        let request: NSFetchRequest<WorkoutDay> = WorkoutDay.fetchRequest()
        request.predicate = NSPredicate(format: "program == %@ AND isActive == YES", program)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WorkoutDay.order, ascending: true),
            NSSortDescriptor(keyPath: \WorkoutDay.createdAt, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching active days: \(error)")
            return []
        }
    }
    
    func createDay(name: String, program: Program) -> WorkoutDay {
        let day = WorkoutDay(context: context)
        day.id = UUID()
        day.name = name
        day.program = program
        day.isActive = true
        day.createdAt = Date()
        
        // Set order to be last in the program
        let existingDays = fetchActiveDays(for: program)
        day.order = Int16(existingDays.count)
        
        saveContext()
        return day
    }
    
    func updateDay(_ day: WorkoutDay) {
        saveContext()
    }
    
    func softDeleteDay(_ day: WorkoutDay) {
        day.isActive = false
        saveContext()
    }
    
    // MARK: - Exercise Operations
    
    func fetchExercisesForDay(_ day: WorkoutDay) -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "day == %@", day)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Exercise.order, ascending: true),
            NSSortDescriptor(keyPath: \Exercise.name, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises for day: \(error)")
            return []
        }
    }
    
    func createExercise(name: String, day: WorkoutDay, isBaseline: Bool = false) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.day = day
        exercise.isBaseline = isBaseline
        
        // Set order to be last in the day
        let existingExercises = fetchExercisesForDay(day)
        exercise.order = Int16(existingExercises.count)
        
        saveContext()
        return exercise
    }
    
    func updateExercise(_ exercise: Exercise) {
        saveContext()
    }
    
    func deleteExercise(_ exercise: Exercise) {
        context.delete(exercise)
        saveContext()
    }
    
    // MARK: - ExerciseLog Operations
    
    func fetchTodaysLog(for exercise: Exercise) -> ExerciseLog? {
        let today = Date.todayNormalized
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@ AND dateNormalizedToLocalMidnight == %@", exercise, today as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching today's log: \(error)")
            return nil
        }
    }
    
    func createOrUpdateTodaysLog(for exercise: Exercise, sets: [(weight: Double?, reps: Int16?)]) -> ExerciseLog {
        let today = Date.todayNormalized
        
        // Try to find existing log for today
        let existingLog = fetchTodaysLog(for: exercise)
        let log = existingLog ?? ExerciseLog(context: context)
        
        // Set basic properties if this is a new log
        if existingLog == nil {
            log.id = UUID()
            log.exercise = exercise
            log.dateNormalizedToLocalMidnight = today
        }
        
        // Update set data (ensure we have at most 4 sets)
        let setsToUpdate = Array(sets.prefix(4))
        
        // Clear all sets first
        log.set1Weight = nil
        log.set1Reps = nil
        log.set2Weight = nil
        log.set2Reps = nil
        log.set3Weight = nil
        log.set3Reps = nil
        log.set4Weight = nil
        log.set4Reps = nil
        
        // Set the provided data
        for (index, set) in setsToUpdate.enumerated() {
            switch index {
            case 0:
                log.set1Weight = set.weight
                log.set1Reps = set.reps
            case 1:
                log.set2Weight = set.weight
                log.set2Reps = set.reps
            case 2:
                log.set3Weight = set.weight
                log.set3Reps = set.reps
            case 3:
                log.set4Weight = set.weight
                log.set4Reps = set.reps
            default:
                break
            }
        }
        
        saveContext()
        return log
    }
    
    func fetchRecentLogs(for exercise: Exercise, limit: Int) -> [ExerciseLog] {
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@", exercise)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExerciseLog.dateNormalizedToLocalMidnight, ascending: false)
        ]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching recent logs: \(error)")
            return []
        }
    }
    
    func fetchRecentLogs(for exercise: Exercise, excludingToday: Bool, limit: Int) -> [ExerciseLog] {
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        
        if excludingToday {
            let today = Date.todayNormalized
            request.predicate = NSPredicate(format: "exercise == %@ AND dateNormalizedToLocalMidnight < %@", exercise, today as CVarArg)
        } else {
            request.predicate = NSPredicate(format: "exercise == %@", exercise)
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExerciseLog.dateNormalizedToLocalMidnight, ascending: false)
        ]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching recent logs (excluding today): \(error)")
            return []
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

// MARK: - Repository Factory

extension WorkoutRepository {
    /// Creates a repository instance using the shared Core Data context
    static var shared: WorkoutRepository {
        return WorkoutRepository(context: CoreDataManager.shared.viewContext)
    }
    
    /// Creates a repository instance for previews using the preview context
    @MainActor
    static var preview: WorkoutRepository {
        return WorkoutRepository(context: CoreDataManager.preview.viewContext)
    }
}