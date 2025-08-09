//
//  MaxQTests.swift
//  MaxQTests
//
//  Created by Qendrim Qeriqi on 8/8/25.
//

import Testing
import CoreData
@testable import MaxQ

struct MaxQTests {
    
    @Test func testRepositoryCreation() async throws {
        // Test that we can create a repository instance
        let container = NSPersistentContainer(name: "MaxQ")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        
        await withCheckedContinuation { continuation in
            container.loadPersistentStores { _, error in
                #expect(error == nil, "Core Data store should load without error")
                continuation.resume()
            }
        }
        
        let repository = WorkoutRepository(context: container.viewContext)
        #expect(repository != nil, "Repository should be created successfully")
    }
    
    @Test func testDateNormalization() async throws {
        // Test that dates are properly normalized to midnight
        let now = Date()
        let normalized = now.normalizedToLocalMidnight
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: normalized)
        
        #expect(components.hour == 0, "Hour should be 0 after normalization")
        #expect(components.minute == 0, "Minute should be 0 after normalization")
        #expect(components.second == 0, "Second should be 0 after normalization")
    }
    
    @Test func testInputValidation() async throws {
        // Test weight validation
        #expect(InputValidator.validateWeight(nil) == true, "Nil weight should be valid")
        #expect(InputValidator.validateWeight(0.0) == true, "Zero weight should be valid")
        #expect(InputValidator.validateWeight(135.5) == true, "Positive weight should be valid")
        #expect(InputValidator.validateWeight(-1.0) == false, "Negative weight should be invalid")
        
        // Test reps validation
        #expect(InputValidator.validateReps(nil) == true, "Nil reps should be valid")
        #expect(InputValidator.validateReps(0) == true, "Zero reps should be valid")
        #expect(InputValidator.validateReps(10) == true, "Positive reps should be valid")
        #expect(InputValidator.validateReps(-1) == false, "Negative reps should be invalid")
        
        // Test exercise name validation
        #expect(InputValidator.validateExerciseName(nil) == false, "Nil name should be invalid")
        #expect(InputValidator.validateExerciseName("") == false, "Empty name should be invalid")
        #expect(InputValidator.validateExerciseName("   ") == false, "Whitespace-only name should be invalid")
        #expect(InputValidator.validateExerciseName("Bench Press") == true, "Valid name should be valid")
        #expect(InputValidator.validateExerciseName("  Bench Press  ") == true, "Name with whitespace should be valid")
        
        // Test name cleaning
        #expect(InputValidator.cleanExerciseName("  Bench Press  ") == "Bench Press", "Name should be trimmed")
    }
    
    @Test func testSetDataFormatting() async throws {
        // Test SetData display formatting
        let completeSet = SetData(weight: 135.0, reps: 8)
        #expect(completeSet.displayString == "135×8", "Complete set should format correctly")
        #expect(completeSet.isComplete == true, "Complete set should be marked as complete")
        #expect(completeSet.isEmpty == false, "Complete set should not be empty")
        
        let emptySet = SetData(weight: nil, reps: nil)
        #expect(emptySet.displayString == "", "Empty set should have empty display string")
        #expect(emptySet.isComplete == false, "Empty set should not be complete")
        #expect(emptySet.isEmpty == true, "Empty set should be marked as empty")
        
        let partialSet = SetData(weight: 135.0, reps: nil)
        #expect(partialSet.displayString == "", "Partial set should have empty display string")
        #expect(partialSet.isComplete == false, "Partial set should not be complete")
        #expect(partialSet.isEmpty == false, "Partial set should not be empty")
    }

}
