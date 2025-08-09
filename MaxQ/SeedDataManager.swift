//
//  SeedDataManager.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation
import CoreData

// MARK: - Seed Version Management

/// Enum for managing seed data versions with integer-based comparison
enum SeedVersion: Int, CaseIterable {
    case initial = 1
    case multiProgram = 2
    
    /// Current version of seed data
    static let current: SeedVersion = .multiProgram
    
    /// UserDefaults key for storing seed version
    private static let userDefaultsKey = "seedVersion"
    
    /// Gets the stored seed version from UserDefaults
    static var stored: SeedVersion {
        let storedValue = UserDefaults.standard.integer(forKey: userDefaultsKey)
        return SeedVersion(rawValue: storedValue) ?? .initial
    }
    
    /// Updates the stored seed version in UserDefaults
    static func updateStored(to version: SeedVersion) {
        UserDefaults.standard.set(version.rawValue, forKey: userDefaultsKey)
    }
    
    /// Returns true if seeding is needed (stored version is less than current)
    static var needsSeeding: Bool {
        return stored.rawValue < current.rawValue
    }
}

// MARK: - Seed Data Structures

/// Structure containing all preloaded program data
struct SeedData {
    
    /// Exercise data for seeding
    struct ExerciseData {
        let name: String
        let order: Int16
        let recommendedSets: [(weight: Double?, reps: Int16?)]
        
        init(name: String, order: Int16, sets: [(Double?, Int16?)]) {
            self.name = name
            self.order = order
            self.recommendedSets = sets
        }
    }
    
    /// Workout day data for seeding
    struct WorkoutDayData {
        let name: String
        let order: Int16
        let exercises: [ExerciseData]
    }
    
    /// Program data for seeding
    struct ProgramData {
        let name: String
        let days: [WorkoutDayData]
    }
    
    /// All preloaded programs
    static let programs: [ProgramData] = [
        // Classic Push/Pull/Arms/Full Body Program
        ProgramData(name: "Classic", days: [
            WorkoutDayData(name: "Push", order: 0, exercises: [
                ExerciseData(name: "Bench Press", order: 0, sets: [(135, 8), (135, 8), (135, 8), (135, 8)]),
                ExerciseData(name: "Incline Press", order: 1, sets: [(115, 8), (115, 8), (115, 8), (115, 8)]),
                ExerciseData(name: "Cable Fly", order: 2, sets: [(30, 12), (30, 12), (30, 12), (30, 12)]),
                ExerciseData(name: "Overhead Press", order: 3, sets: [(95, 8), (95, 8), (95, 8), (95, 8)]),
                ExerciseData(name: "Triceps Pushdowns", order: 4, sets: [(40, 12), (40, 12), (40, 12), (40, 12)])
            ]),
            WorkoutDayData(name: "Pull", order: 1, exercises: [
                ExerciseData(name: "Pull-ups", order: 0, sets: [(nil, 8), (nil, 8), (nil, 8), (nil, 8)]),
                ExerciseData(name: "Barbell Rows", order: 1, sets: [(135, 8), (135, 8), (135, 8), (135, 8)]),
                ExerciseData(name: "Lat Pulldowns", order: 2, sets: [(120, 10), (120, 10), (120, 10), (120, 10)]),
                ExerciseData(name: "Cable Rows", order: 3, sets: [(100, 10), (100, 10), (100, 10), (100, 10)]),
                ExerciseData(name: "Bicep Curls", order: 4, sets: [(30, 12), (30, 12), (30, 12), (30, 12)])
            ]),
            WorkoutDayData(name: "Arms", order: 2, exercises: [
                ExerciseData(name: "Close-Grip Bench Press", order: 0, sets: [(115, 8), (115, 8), (115, 8), (115, 8)]),
                ExerciseData(name: "Dips", order: 1, sets: [(nil, 10), (nil, 10), (nil, 10), (nil, 10)]),
                ExerciseData(name: "Hammer Curls", order: 2, sets: [(35, 10), (35, 10), (35, 10), (35, 10)]),
                ExerciseData(name: "Preacher Curls", order: 3, sets: [(25, 12), (25, 12), (25, 12), (25, 12)]),
                ExerciseData(name: "Tricep Extensions", order: 4, sets: [(25, 12), (25, 12), (25, 12), (25, 12)])
            ]),
            WorkoutDayData(name: "Legs", order: 3, exercises: [
                ExerciseData(name: "Squats", order: 0, sets: [(185, 8), (185, 8), (185, 8), (185, 8)]),
                ExerciseData(name: "Romanian Deadlifts", order: 1, sets: [(155, 8), (155, 8), (155, 8), (155, 8)]),
                ExerciseData(name: "Leg Press", order: 2, sets: [(270, 12), (270, 12), (270, 12), (270, 12)]),
                ExerciseData(name: "Leg Curls", order: 3, sets: [(80, 12), (80, 12), (80, 12), (80, 12)]),
                ExerciseData(name: "Calf Raises", order: 4, sets: [(45, 15), (45, 15), (45, 15), (45, 15)])
            ]),
            WorkoutDayData(name: "Full Body", order: 4, exercises: [
                ExerciseData(name: "Deadlifts", order: 0, sets: [(185, 5), (185, 5), (185, 5), (185, 5)]),
                ExerciseData(name: "Bench Press", order: 1, sets: [(135, 8), (135, 8), (135, 8), (135, 8)]),
                ExerciseData(name: "Squats", order: 2, sets: [(155, 8), (155, 8), (155, 8), (155, 8)]),
                ExerciseData(name: "Pull-ups", order: 3, sets: [(nil, 6), (nil, 6), (nil, 6), (nil, 6)]),
                ExerciseData(name: "Overhead Press", order: 4, sets: [(85, 8), (85, 8), (85, 8), (85, 8)])
            ])
        ]),
        
        // Full Body Beginner Program
        ProgramData(name: "Full Body Beginner", days: [
            WorkoutDayData(name: "Workout A", order: 0, exercises: [
                ExerciseData(name: "Goblet Squats", order: 0, sets: [(25, 10), (25, 10), (25, 10), (nil, nil)]),
                ExerciseData(name: "Push-ups", order: 1, sets: [(nil, 8), (nil, 8), (nil, 8), (nil, nil)]),
                ExerciseData(name: "Assisted Pull-ups", order: 2, sets: [(nil, 5), (nil, 5), (nil, 5), (nil, nil)]),
                ExerciseData(name: "Plank", order: 3, sets: [(nil, 30), (nil, 30), (nil, 30), (nil, nil)]),
                ExerciseData(name: "Glute Bridges", order: 4, sets: [(nil, 12), (nil, 12), (nil, 12), (nil, nil)])
            ]),
            WorkoutDayData(name: "Workout B", order: 1, exercises: [
                ExerciseData(name: "Dumbbell Deadlifts", order: 0, sets: [(20, 8), (20, 8), (20, 8), (nil, nil)]),
                ExerciseData(name: "Incline Push-ups", order: 1, sets: [(nil, 10), (nil, 10), (nil, 10), (nil, nil)]),
                ExerciseData(name: "Lat Pulldowns", order: 2, sets: [(60, 8), (60, 8), (60, 8), (nil, nil)]),
                ExerciseData(name: "Side Plank", order: 3, sets: [(nil, 20), (nil, 20), (nil, 20), (nil, nil)]),
                ExerciseData(name: "Wall Sits", order: 4, sets: [(nil, 30), (nil, 30), (nil, 30), (nil, nil)])
            ]),
            WorkoutDayData(name: "Workout C", order: 2, exercises: [
                ExerciseData(name: "Bodyweight Squats", order: 0, sets: [(nil, 12), (nil, 12), (nil, 12), (nil, nil)]),
                ExerciseData(name: "Knee Push-ups", order: 1, sets: [(nil, 10), (nil, 10), (nil, 10), (nil, nil)]),
                ExerciseData(name: "Seated Rows", order: 2, sets: [(40, 10), (40, 10), (40, 10), (nil, nil)]),
                ExerciseData(name: "Dead Bug", order: 3, sets: [(nil, 8), (nil, 8), (nil, 8), (nil, nil)]),
                ExerciseData(name: "Calf Raises", order: 4, sets: [(nil, 15), (nil, 15), (nil, 15), (nil, nil)])
            ])
        ]),
        
        // Arms Focus Program
        ProgramData(name: "Arms Focus", days: [
            WorkoutDayData(name: "Biceps & Back", order: 0, exercises: [
                ExerciseData(name: "Barbell Curls", order: 0, sets: [(45, 10), (45, 10), (45, 10), (45, 10)]),
                ExerciseData(name: "Hammer Curls", order: 1, sets: [(30, 12), (30, 12), (30, 12), (30, 12)]),
                ExerciseData(name: "Preacher Curls", order: 2, sets: [(25, 10), (25, 10), (25, 10), (25, 10)]),
                ExerciseData(name: "Cable Curls", order: 3, sets: [(35, 12), (35, 12), (35, 12), (35, 12)]),
                ExerciseData(name: "Chin-ups", order: 4, sets: [(nil, 6), (nil, 6), (nil, 6), (nil, 6)])
            ]),
            WorkoutDayData(name: "Triceps & Chest", order: 1, exercises: [
                ExerciseData(name: "Close-Grip Bench Press", order: 0, sets: [(95, 10), (95, 10), (95, 10), (95, 10)]),
                ExerciseData(name: "Tricep Dips", order: 1, sets: [(nil, 8), (nil, 8), (nil, 8), (nil, 8)]),
                ExerciseData(name: "Overhead Tricep Extension", order: 2, sets: [(30, 12), (30, 12), (30, 12), (30, 12)]),
                ExerciseData(name: "Tricep Pushdowns", order: 3, sets: [(40, 12), (40, 12), (40, 12), (40, 12)]),
                ExerciseData(name: "Diamond Push-ups", order: 4, sets: [(nil, 8), (nil, 8), (nil, 8), (nil, 8)])
            ]),
            WorkoutDayData(name: "Forearms & Shoulders", order: 2, exercises: [
                ExerciseData(name: "Wrist Curls", order: 0, sets: [(15, 15), (15, 15), (15, 15), (15, 15)]),
                ExerciseData(name: "Reverse Wrist Curls", order: 1, sets: [(10, 15), (10, 15), (10, 15), (10, 15)]),
                ExerciseData(name: "Farmer's Walks", order: 2, sets: [(40, nil), (40, nil), (40, nil), (40, nil)]),
                ExerciseData(name: "Lateral Raises", order: 3, sets: [(15, 12), (15, 12), (15, 12), (15, 12)]),
                ExerciseData(name: "Face Pulls", order: 4, sets: [(25, 15), (25, 15), (25, 15), (25, 15)])
            ])
        ])
    ]
}

// MARK: - Seed Data Manager

/// Manager class for handling first-launch seeding with version guard
class SeedDataManager {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
    }
    
    /// Performs seeding if needed based on version comparison
    func seedIfNeeded() {
        guard SeedVersion.needsSeeding else {
            print("Seed data is up to date (version \(SeedVersion.stored.rawValue))")
            return
        }
        
        print("Seeding data from version \(SeedVersion.stored.rawValue) to \(SeedVersion.current.rawValue)")
        
        do {
            try performSeeding()
            SeedVersion.updateStored(to: .current)
            print("Seed data completed successfully")
        } catch {
            print("Seed data failed: \(error)")
            // Don't update version on failure so seeding will be retried
        }
    }
    
    /// Performs the actual seeding operation
    private func performSeeding() throws {
        // Create all programs
        for programData in SeedData.programs {
            try createProgram(from: programData)
        }
        
        // Save all changes
        try context.save()
    }
    
    /// Creates a program with its days and exercises
    private func createProgram(from data: SeedData.ProgramData) throws {
        // Check if program already exists
        let fetchRequest: NSFetchRequest<Program> = Program.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", data.name)
        
        let existingPrograms = try context.fetch(fetchRequest)
        if !existingPrograms.isEmpty {
            print("Program '\(data.name)' already exists, skipping")
            return
        }
        
        // Create new program
        let program = Program(context: context)
        program.id = UUID()
        program.name = data.name
        program.isPreloaded = true
        program.createdAt = Date()
        
        // Create workout days
        for dayData in data.days {
            try createWorkoutDay(from: dayData, in: program)
        }
        
        print("Created program: \(data.name) with \(data.days.count) days")
    }
    
    /// Creates a workout day with its exercises
    private func createWorkoutDay(from data: SeedData.WorkoutDayData, in program: Program) throws {
        let workoutDay = WorkoutDay(context: context)
        workoutDay.id = UUID()
        workoutDay.name = data.name
        workoutDay.order = data.order
        workoutDay.createdAt = Date()
        workoutDay.isActive = true
        workoutDay.program = program
        
        // Create exercises
        for exerciseData in data.exercises {
            createExercise(from: exerciseData, in: workoutDay)
        }
        
        print("  Created day: \(data.name) with \(data.exercises.count) exercises")
    }
    
    /// Creates an exercise with recommended sets
    private func createExercise(from data: SeedData.ExerciseData, in day: WorkoutDay) {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = data.name
        exercise.order = data.order
        exercise.isBaseline = true // All seeded exercises are baseline
        exercise.day = day
        
        // Set recommended sets (ensure we have exactly 4 sets)
        let sets = data.recommendedSets
        
        if sets.count > 0 {
            exercise.recSet1Weight = sets[0].weight
            exercise.recSet1Reps = sets[0].reps
        }
        if sets.count > 1 {
            exercise.recSet2Weight = sets[1].weight
            exercise.recSet2Reps = sets[1].reps
        }
        if sets.count > 2 {
            exercise.recSet3Weight = sets[2].weight
            exercise.recSet3Reps = sets[2].reps
        }
        if sets.count > 3 {
            exercise.recSet4Weight = sets[3].weight
            exercise.recSet4Reps = sets[3].reps
        }
        
        print("    Created exercise: \(data.name) (baseline)")
    }
    
    /// Resets seed version for testing purposes (development only)
    func resetSeedVersion() {
        UserDefaults.standard.removeObject(forKey: "seedVersion")
        print("Seed version reset - seeding will run on next launch")
    }
    
    /// Clears all seeded data for testing purposes (development only)
    func clearAllData() throws {
        let programFetch: NSFetchRequest<NSFetchRequestResult> = Program.fetchRequest()
        let deletePrograms = NSBatchDeleteRequest(fetchRequest: programFetch)
        try context.execute(deletePrograms)
        
        try context.save()
        resetSeedVersion()
        print("All data cleared and seed version reset")
    }
}

// MARK: - Extensions for Testing

#if DEBUG
extension SeedDataManager {
    /// Force seeds data regardless of version (for testing)
    func forceSeed() throws {
        try performSeeding()
        SeedVersion.updateStored(to: .current)
    }
    
    /// Returns the count of seeded programs
    func getSeededProgramCount() throws -> Int {
        let fetchRequest: NSFetchRequest<Program> = Program.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isPreloaded == YES")
        return try context.count(for: fetchRequest)
    }
    
    /// Returns the count of seeded exercises marked as baseline
    func getBaselineExerciseCount() throws -> Int {
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBaseline == YES")
        return try context.count(for: fetchRequest)
    }
}
#endif