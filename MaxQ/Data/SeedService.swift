//
//  SeedService.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

enum SeedService {
    static func defaultPrograms() -> [ProgramModel] {
        // Core exercises with IDs that we'll use across the app
        let exercises = defaultExercises()
        
        // Pull Day
        let pullExercises = [
            ExerciseRefModel(id: exercises.first { $0.name == "Barbell Row" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Pull-ups" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Lat Pulldown" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Cable Row" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Barbell Curl" }!.id)
        ]
        
        // Push Day
        let pushExercises = [
            ExerciseRefModel(id: exercises.first { $0.name == "Barbell Bench Press" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Overhead Press" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Dumbbell Press" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Lateral Raises" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Tricep Press Down" }!.id)
        ]
        
        // Legs Day
        let legsExercises = [
            ExerciseRefModel(id: exercises.first { $0.name == "Back Squat" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Romanian Deadlift" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Leg Press" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Leg Curl" }!.id),
            ExerciseRefModel(id: exercises.first { $0.name == "Calf Raises" }!.id)
        ]
        
        let pull = WorkoutDayModel(name: "Pull", order: 0, exercises: pullExercises)
        let push = WorkoutDayModel(name: "Push", order: 1, exercises: pushExercises)
        let legs = WorkoutDayModel(name: "Legs", order: 2, exercises: legsExercises)

        return [ProgramModel(name: "Push/Pull/Legs", days: [pull, push, legs])]
    }
    
    static func defaultExercises() -> [ExerciseModel] {
        return [
            // Pull exercises
            ExerciseModel(name: "Barbell Row", muscleGroup: "Back"),
            ExerciseModel(name: "Pull-ups", muscleGroup: "Back"),
            ExerciseModel(name: "Lat Pulldown", muscleGroup: "Back"),
            ExerciseModel(name: "Cable Row", muscleGroup: "Back"),
            ExerciseModel(name: "Barbell Curl", muscleGroup: "Arms"),
            
            // Push exercises
            ExerciseModel(name: "Barbell Bench Press", muscleGroup: "Chest"),
            ExerciseModel(name: "Overhead Press", muscleGroup: "Shoulders"),
            ExerciseModel(name: "Dumbbell Press", muscleGroup: "Chest"),
            ExerciseModel(name: "Lateral Raises", muscleGroup: "Shoulders"),
            ExerciseModel(name: "Tricep Press Down", muscleGroup: "Arms"),
            
            // Leg exercises
            ExerciseModel(name: "Back Squat", muscleGroup: "Legs"),
            ExerciseModel(name: "Romanian Deadlift", muscleGroup: "Legs"),
            ExerciseModel(name: "Leg Press", muscleGroup: "Legs"),
            ExerciseModel(name: "Leg Curl", muscleGroup: "Legs"),
            ExerciseModel(name: "Calf Raises", muscleGroup: "Legs")
        ]
    }
}
