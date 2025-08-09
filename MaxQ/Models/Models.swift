//
//  Models.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

public struct ProgramModel: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID = .init()
    public var name: String
    public var days: [WorkoutDayModel]   // template days
    
    public init(id: UUID = UUID(), name: String, days: [WorkoutDayModel] = []) {
        self.id = id
        self.name = name
        self.days = days
    }
}

public struct WorkoutDayModel: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID = .init()
    public var name: String
    public var order: Int
    public var exercises: [ExerciseRefModel]   // references into library
    
    public init(id: UUID = UUID(), name: String, order: Int, exercises: [ExerciseRefModel] = []) {
        self.id = id
        self.name = name
        self.order = order
        self.exercises = exercises
    }
}

public struct ExerciseRefModel: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var customName: String? = nil  // if not found in library
    
    public init(id: UUID, customName: String? = nil) {
        self.id = id
        self.customName = customName
    }
}

public struct ExerciseModel: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID = .init()
    public var name: String
    public var muscleGroup: String?
    public var isCustom: Bool = false
    
    public init(id: UUID = UUID(), name: String, muscleGroup: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
    }
}

public struct WorkoutSessionModel: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID = .init()
    public var date: Date
    public var programId: UUID?
    public var dayId: UUID?
    public var entries: [SetEntryModel]
    public var notes: String?
    
    public init(id: UUID = UUID(), date: Date, programId: UUID? = nil, dayId: UUID? = nil, entries: [SetEntryModel] = [], notes: String? = nil) {
        self.id = id
        self.date = date
        self.programId = programId
        self.dayId = dayId
        self.entries = entries
        self.notes = notes
    }
}

public struct SetEntryModel: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID = .init()
    public var exerciseId: UUID
    public var weight: Double
    public var reps: Int
    public var rpe: Double?
    
    public init(id: UUID = UUID(), exerciseId: UUID, weight: Double, reps: Int, rpe: Double? = nil) {
        self.id = id
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
    }
}
