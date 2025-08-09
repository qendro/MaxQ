//
//  SeedDataManagerTests.swift
//  MaxQTests
//
//  Created by Kiro on 8/8/25.
//

import Testing
import CoreData
@testable import MaxQ

struct SeedDataManagerTests {
    
    // Helper function to create test context and seed manager
    func createTestEnvironment() async throws -> (NSManagedObjectContext, SeedDataManager) {
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "MaxQ")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        
        await withCheckedContinuation { continuation in
            container.loadPersistentStores { _, error in
                #expect(error == nil, "Core Data store should load without error")
                continuation.resume()
            }
        }
        
        let testContext = container.viewContext
        let seedManager = SeedDataManager(context: testContext)
        
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "seedVersion")
        
        return (testContext, seedManager)
    }
    
    // MARK: - SeedVersion Tests
    
    @Test func testSeedVersionInitialState() async throws {
        // When no version is stored, should default to initial
        #expect(SeedVersion.stored == .initial, "Should default to initial version")
        #expect(SeedVersion.needsSeeding == true, "Should need seeding initially")
    }
    
    @Test func testSeedVersionUpdate() async throws {
        // Test updating seed version
        SeedVersion.updateStored(to: .multiProgram)
        #expect(SeedVersion.stored == .multiProgram, "Should update to multiProgram version")
        #expect(SeedVersion.needsSeeding == false, "Should not need seeding after update")
    }
    
    @Test func testSeedVersionComparison() async throws {
        // Test version comparison logic
        #expect(SeedVersion.initial.rawValue < SeedVersion.multiProgram.rawValue, "Initial should be less than multiProgram")
        #expect(SeedVersion.current == .multiProgram, "Current should be multiProgram")
    }
    
    // MARK: - Seeding Tests
    
    @Test func testSeedIfNeededFirstLaunch() async throws {
        let (_, seedManager) = try await createTestEnvironment()
        
        // Verify seeding runs on first launch
        #expect(SeedVersion.needsSeeding == true, "Should need seeding on first launch")
        
        seedManager.seedIfNeeded()
        
        // Verify programs were created
        let programCount = try seedManager.getSeededProgramCount()
        #expect(programCount == 3, "Should create 3 programs")
        
        // Verify version was updated
        #expect(SeedVersion.needsSeeding == false, "Should not need seeding after completion")
        #expect(SeedVersion.stored == .current, "Should update to current version")
    }
    
    @Test func testSeedIfNeededSkipsWhenUpToDate() async throws {
        let (_, seedManager) = try await createTestEnvironment()
        
        // Set version to current
        SeedVersion.updateStored(to: .current)
        
        // Should not seed when up to date
        seedManager.seedIfNeeded()
        
        let programCount = try seedManager.getSeededProgramCount()
        #expect(programCount == 0, "Should not create programs when up to date")
    }
    
    @Test func testSeedDataStructure() async throws {
        // Test that seed data has expected structure
        #expect(SeedData.programs.count == 3, "Should have 3 programs")
        
        // Test Classic program
        let classic = SeedData.programs.first { $0.name == "Classic" }
        #expect(classic != nil, "Should have Classic program")
        #expect(classic?.days.count == 5, "Classic should have 5 days")
        
        // Test Push day exercises
        let pushDay = classic?.days.first { $0.name == "Push" }
        #expect(pushDay != nil, "Should have Push day")
        #expect(pushDay?.exercises.count == 5, "Push day should have 5 exercises")
        
        // Test specific exercise
        let benchPress = pushDay?.exercises.first { $0.name == "Bench Press" }
        #expect(benchPress != nil, "Should have Bench Press exercise")
        #expect(benchPress?.recommendedSets.count == 4, "Should have 4 recommended sets")
        #expect(benchPress?.recommendedSets[0].weight == 135, "First set weight should be 135")
        #expect(benchPress?.recommendedSets[0].reps == 8, "First set reps should be 8")
    }
    
    @Test func testBaselineExerciseMarking() async throws {
        let (testContext, seedManager) = try await createTestEnvironment()
        
        // Seed data and verify all exercises are marked as baseline
        try seedManager.forceSeed()
        
        let baselineCount = try seedManager.getBaselineExerciseCount()
        #expect(baselineCount > 0, "Should have baseline exercises")
        
        // Verify no non-baseline exercises exist
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBaseline == NO")
        let nonBaselineCount = try testContext.count(for: fetchRequest)
        #expect(nonBaselineCount == 0, "Should have no non-baseline exercises after seeding")
    }
    
    @Test func testNoHistoricalLogsCreated() async throws {
        let (testContext, seedManager) = try await createTestEnvironment()
        
        // Seed data and verify no ExerciseLog entries are created
        try seedManager.forceSeed()
        
        let logFetchRequest: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        let logCount = try testContext.count(for: logFetchRequest)
        #expect(logCount == 0, "Should not create any ExerciseLog entries during seeding")
    }
    
    @Test func testProgramStructureIntegrity() async throws {
        let (testContext, seedManager) = try await createTestEnvironment()
        
        // Seed data and verify program structure
        try seedManager.forceSeed()
        
        let programFetchRequest: NSFetchRequest<Program> = Program.fetchRequest()
        let programs = try testContext.fetch(programFetchRequest)
        
        #expect(programs.count == 3, "Should create 3 programs")
        
        for program in programs {
            #expect(program.id != nil, "Program should have ID")
            #expect(program.name != nil, "Program should have name")
            #expect(program.isPreloaded == true, "Program should be marked as preloaded")
            #expect(program.createdAt != nil, "Program should have creation date")
            #expect(program.days != nil, "Program should have days")
            #expect((program.days?.count ?? 0) > 0, "Program should have at least one day")
            
            // Verify each day has exercises
            for day in program.days?.allObjects as? [WorkoutDay] ?? [] {
                #expect(day.id != nil, "Day should have ID")
                #expect(day.name != nil, "Day should have name")
                #expect(day.isActive == true, "Day should be active")
                #expect(day.exercises != nil, "Day should have exercises")
                #expect((day.exercises?.count ?? 0) > 0, "Day should have at least one exercise")
                
                // Verify each exercise has proper structure
                for exercise in day.exercises?.allObjects as? [Exercise] ?? [] {
                    #expect(exercise.id != nil, "Exercise should have ID")
                    #expect(exercise.name != nil, "Exercise should have name")
                    #expect(exercise.isBaseline == true, "Exercise should be marked as baseline")
                    #expect(exercise.day == day, "Exercise should belong to correct day")
                }
            }
        }
    }
    
    @Test func testSeedVersionPreventsOverwrite() async throws {
        let (testContext, seedManager) = try await createTestEnvironment()
        
        // Seed initial data
        try seedManager.forceSeed()
        let initialProgramCount = try seedManager.getSeededProgramCount()
        
        // Create a user-added program
        let userProgram = Program(context: testContext)
        userProgram.id = UUID()
        userProgram.name = "User Custom Program"
        userProgram.isPreloaded = false
        userProgram.createdAt = Date()
        try testContext.save()
        
        // Simulate app update by calling seedIfNeeded again
        seedManager.seedIfNeeded()
        
        // Verify user data wasn't overwritten
        let finalProgramCount = try seedManager.getSeededProgramCount()
        #expect(finalProgramCount == initialProgramCount, "Should not duplicate seeded programs")
        
        // Verify user program still exists
        let userProgramFetch: NSFetchRequest<Program> = Program.fetchRequest()
        userProgramFetch.predicate = NSPredicate(format: "name == %@", "User Custom Program")
        let userPrograms = try testContext.fetch(userProgramFetch)
        #expect(userPrograms.count == 1, "User program should still exist")
    }
    
    @Test func testSpecificProgramContent() async throws {
        let (testContext, seedManager) = try await createTestEnvironment()
        
        // Test specific program content matches requirements
        try seedManager.forceSeed()
        
        // Test Classic program has Push day with required exercises
        let programFetch: NSFetchRequest<Program> = Program.fetchRequest()
        programFetch.predicate = NSPredicate(format: "name == %@", "Classic")
        let classicPrograms = try testContext.fetch(programFetch)
        #expect(classicPrograms.count == 1, "Should have exactly one Classic program")
        
        let classic = classicPrograms.first!
        let pushDay = (classic.days?.allObjects as? [WorkoutDay])?.first { $0.name == "Push" }
        #expect(pushDay != nil, "Should have Push day")
        
        let exercises = pushDay?.exercises?.allObjects as? [Exercise] ?? []
        let exerciseNames = exercises.map { $0.name ?? "" }.sorted()
        let expectedNames = ["Bench Press", "Cable Fly", "Incline Press", "Overhead Press", "Triceps Pushdowns"].sorted()
        #expect(exerciseNames == expectedNames, "Push day should have expected exercises")
    }
    
    // MARK: - Development Helper Tests
    
    @Test func testClearAllData() async throws {
        let (_, seedManager) = try await createTestEnvironment()
        
        // Seed data first
        try seedManager.forceSeed()
        #expect(try seedManager.getSeededProgramCount() > 0, "Should have seeded programs")
        
        // Clear all data
        try seedManager.clearAllData()
        
        // Verify data is cleared
        #expect(try seedManager.getSeededProgramCount() == 0, "Should have no programs after clearing")
        #expect(SeedVersion.needsSeeding == true, "Should need seeding after clearing")
    }
    
    @Test func testResetSeedVersion() async throws {
        let (_, seedManager) = try await createTestEnvironment()
        
        // Set version to current
        SeedVersion.updateStored(to: .current)
        #expect(SeedVersion.needsSeeding == false, "Should not need seeding when current")
        
        // Reset version
        seedManager.resetSeedVersion()
        
        // Verify version is reset
        #expect(SeedVersion.needsSeeding == true, "Should need seeding after reset")
    }
}