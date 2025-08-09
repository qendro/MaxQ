//
//  LogViewModel.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation
import SwiftUI
import CoreData

/// ViewModel for the Log screen - displays and manages workout history in text format
@MainActor
class LogViewModel: ObservableObject {
    @Published var logText: String = ""
    @Published var isEditing: Bool = false
    @Published var errorMessage: String?
    
    private let repository: WorkoutRepositoryProtocol
    private let context: NSManagedObjectContext
    
    init(repository: WorkoutRepositoryProtocol = WorkoutRepository.shared, context: NSManagedObjectContext) {
        self.repository = repository
        self.context = context
        loadWorkoutLog()
    }
    
    /// Loads all workout logs and formats them as text
    func loadWorkoutLog() {
        let allLogs = fetchAllLogs()
        logText = formatLogsAsText(allLogs)
    }
    
    /// Fetches all exercise logs grouped by date and day
    private func fetchAllLogs() -> [(date: Date, day: String, exercises: [(name: String, sets: [SetData])])] {
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExerciseLog.dateNormalizedToLocalMidnight, ascending: false),
            NSSortDescriptor(keyPath: \ExerciseLog.exercise?.day?.name, ascending: true),
            NSSortDescriptor(keyPath: \ExerciseLog.exercise?.order, ascending: true)
        ]
        
        do {
            let logs = try context.fetch(request)
            return groupLogsByDateAndDay(logs)
        } catch {
            print("Failed to fetch logs: \(error)")
            return []
        }
    }
    
    /// Groups logs by date and workout day
    private func groupLogsByDateAndDay(_ logs: [ExerciseLog]) -> [(date: Date, day: String, exercises: [(name: String, sets: [SetData])])] {
        var grouped: [String: (date: Date, day: String, exercises: [(name: String, sets: [SetData])])] = [:]
        
        for log in logs {
            guard let date = log.dateNormalizedToLocalMidnight,
                  let exercise = log.exercise,
                  let exerciseName = exercise.name,
                  let dayName = exercise.day?.name else { continue }
            
            let key = "\(date.timeIntervalSince1970)-\(dayName)"
            
            let sets = [
                SetData(weight: log.set1Weight == 0 ? nil : log.set1Weight, reps: log.set1Reps == 0 ? nil : log.set1Reps),
                SetData(weight: log.set2Weight == 0 ? nil : log.set2Weight, reps: log.set2Reps == 0 ? nil : log.set2Reps),
                SetData(weight: log.set3Weight == 0 ? nil : log.set3Weight, reps: log.set3Reps == 0 ? nil : log.set3Reps),
                SetData(weight: log.set4Weight == 0 ? nil : log.set4Weight, reps: log.set4Reps == 0 ? nil : log.set4Reps)
            ].filter { $0.weight != nil || $0.reps != nil }
            
            if grouped[key] == nil {
                grouped[key] = (date: date, day: dayName, exercises: [])
            }
            
            grouped[key]?.exercises.append((name: exerciseName, sets: sets))
        }
        
        return Array(grouped.values).sorted { $0.date > $1.date }
    }
    
    /// Formats workout logs as readable text
    private func formatLogsAsText(_ workouts: [(date: Date, day: String, exercises: [(name: String, sets: [SetData])])]) -> String {
        var text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        // Sort workouts by date ascending (oldest first)
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        
        for workout in sortedWorkouts {
            text += "═══ \(dateFormatter.string(from: workout.date)) - \(workout.day) ═══\n"
            
            for exercise in workout.exercises {
                let shortName = shortenExerciseName(exercise.name)
                let setsText = exercise.sets.compactMap { set in
                    if let weight = set.weight, let reps = set.reps, weight > 0, reps > 0 {
                        return "\(Int(weight))×\(reps)"
                    }
                    return nil
                }.joined(separator: " • ")
                
                if !setsText.isEmpty {
                    text += "  \(shortName): \(setsText)\n"
                }
            }
            text += "\n"
        }
        
        return text
    }
    
    /// Converts exercise names to more concise versions
    private func shortenExerciseName(_ name: String) -> String {
        let lowercased = name.lowercased()
        
        // Common exercise name mappings
        let nameMap: [String: String] = [
            "bench press": "Bench",
            "dumbbell press": "DB Press",
            "db press": "DB Press",
            "incline bench press": "Incline Bench",
            "incline dumbbell press": "Incline DB",
            "cable flyes": "Cable Fly",
            "cable fly": "Cable Fly",
            "lateral raises": "Lat Raise",
            "lateral raise": "Lat Raise",
            "side lateral raises": "Lat Raise",
            "dumbbell lateral raises": "DB Lat Raise",
            "machine trap raises": "M Trap",
            "trap raises": "Trap Raise",
            "tricep bar press down": "Tri Press",
            "tricep pushdown": "Tri Press",
            "tri bar press down": "Tri Press",
            "tricep overhead rope": "Tri OH Rope",
            "tri overhead rope": "Tri OH Rope",
            "overhead press": "OHP",
            "military press": "Military",
            "shoulder press": "Shoulder",
            "barbell row": "BB Row",
            "dumbbell row": "DB Row",
            "t-bar row": "T-Bar Row",
            "lat pulldown": "Lat Pull",
            "pull ups": "Pull-ups",
            "pull-ups": "Pull-ups",
            "chin ups": "Chin-ups",
            "chin-ups": "Chin-ups",
            "deadlift": "Deadlift",
            "romanian deadlift": "RDL",
            "squat": "Squat",
            "front squat": "Front Squat",
            "leg press": "Leg Press",
            "leg curl": "Leg Curl",
            "leg extension": "Leg Ext",
            "calf raises": "Calf Raise",
            "bicep curl": "Bicep",
            "hammer curl": "Hammer",
            "preacher curl": "Preacher"
        ]
        
        // Check for exact matches first
        if let mapped = nameMap[lowercased] {
            return mapped
        }
        
        // Check for partial matches
        for (key, value) in nameMap {
            if lowercased.contains(key) {
                return value
            }
        }
        
        // If no mapping found, use abbreviated version
        let words = name.components(separatedBy: .whitespaces)
        if words.count <= 2 {
            return name
        }
        
        // Take first letter of each word except the last
        let abbreviated = words.dropLast().map { String($0.prefix(1).uppercased()) }.joined() + " " + words.last!
        return abbreviated
    }
    
    /// Parses edited text and updates the database
    func saveChanges() {
        guard isEditing else { return }
        
        do {
            let parsedWorkouts = try parseTextToWorkouts(logText)
            try updateDatabase(with: parsedWorkouts)
            isEditing = false
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
        }
    }
    
    /// Parses text format back to workout data
    private func parseTextToWorkouts(_ text: String) throws -> [(date: Date, day: String, exercises: [(name: String, sets: [SetData])])] {
        var workouts: [(date: Date, day: String, exercises: [(name: String, sets: [SetData])])] = []
        let lines = text.components(separatedBy: .newlines)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        var currentDate: Date?
        var currentDay: String?
        var currentExercises: [(name: String, sets: [SetData])] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed.isEmpty {
                // End of workout - save if we have data
                if let date = currentDate, let day = currentDay, !currentExercises.isEmpty {
                    workouts.append((date: date, day: day, exercises: currentExercises))
                    currentExercises = []
                }
                continue
            }
            
            // Try to parse header line: "═══ MM/dd/yyyy - Day ═══"
            if trimmed.hasPrefix("═══") && trimmed.hasSuffix("═══") {
                let headerContent = String(trimmed.dropFirst(4).dropLast(4)).trimmingCharacters(in: .whitespacesAndNewlines)
                let components = headerContent.components(separatedBy: " - ")
                
                if components.count == 2,
                   let date = dateFormatter.date(from: components[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
                    currentDate = date
                    currentDay = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
                continue
            }
            
            // Try to parse exercise line: "  ExerciseName: 185×3 • 225×8"
            if trimmed.hasPrefix("  "), let colonIndex = trimmed.firstIndex(of: ":") {
                let exerciseName = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: 2)..<colonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                let setsString = String(trimmed[trimmed.index(after: colonIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                let expandedName = expandExerciseName(exerciseName)
                let sets = try parseSets(from: setsString)
                currentExercises.append((name: expandedName, sets: sets))
            }
        }
        
        // Don't forget the last workout if file doesn't end with newline
        if let date = currentDate, let day = currentDay, !currentExercises.isEmpty {
            workouts.append((date: date, day: day, exercises: currentExercises))
        }
        
        return workouts
    }
    
    /// Expands short exercise names back to full names for database matching
    private func expandExerciseName(_ shortName: String) -> String {
        let reverseMap: [String: String] = [
            "bench": "Bench Press",
            "db press": "DB Press",
            "incline bench": "Incline Bench Press",
            "incline db": "Incline Dumbbell Press",
            "cable fly": "Cable Flyes",
            "lat raise": "Lateral Raises",
            "db lat raise": "Dumbbell Lateral Raises",
            "m trap": "Machine Trap Raises",
            "trap raise": "Trap Raises",
            "tri press": "Tricep Bar Press Down",
            "tri oh rope": "Tricep Overhead Rope",
            "ohp": "Overhead Press",
            "military": "Military Press",
            "shoulder": "Shoulder Press",
            "bb row": "Barbell Row",
            "db row": "Dumbbell Row",
            "t-bar row": "T-Bar Row",
            "lat pull": "Lat Pulldown",
            "rdl": "Romanian Deadlift",
            "front squat": "Front Squat",
            "leg press": "Leg Press",
            "leg curl": "Leg Curl",
            "leg ext": "Leg Extension",
            "calf raise": "Calf Raises",
            "bicep": "Bicep Curl",
            "hammer": "Hammer Curl",
            "preacher": "Preacher Curl"
        ]
        
        let lowercased = shortName.lowercased()
        return reverseMap[lowercased] ?? shortName
    }
    
    /// Parses sets string like "185×3 • 225×8 • 225×8"
    private func parseSets(from text: String) throws -> [SetData] {
        // Handle both "•" and "," separators for backwards compatibility
        let separators = [" • ", ", ", ","]
        var setStrings: [String] = [text]
        
        for separator in separators {
            setStrings = setStrings.flatMap { $0.components(separatedBy: separator) }
        }
        
        var sets: [SetData] = []
        
        for setString in setStrings {
            let trimmed = setString.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            
            // Handle both "×" and "x" for weight×reps format
            var components: [String] = []
            if trimmed.contains("×") {
                components = trimmed.components(separatedBy: "×")
            } else if trimmed.contains("x") {
                components = trimmed.components(separatedBy: "x")
            }
            
            guard components.count == 2,
                  let weight = Double(components[0].trimmingCharacters(in: .whitespacesAndNewlines)),
                  let reps = Int16(components[1].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                throw LogParsingError.invalidSetFormat(trimmed)
            }
            
            sets.append(SetData(weight: weight == 0 ? nil : weight, reps: reps == 0 ? nil : reps))
        }
        
        return sets
    }
    
    /// Updates database with parsed workout data
    private func updateDatabase(with workouts: [(date: Date, day: String, exercises: [(name: String, sets: [SetData])])]) throws {
        // Clear existing logs first
        let deleteRequest: NSFetchRequest<NSFetchRequestResult> = ExerciseLog.fetchRequest()
        let deleteResult = NSBatchDeleteRequest(fetchRequest: deleteRequest)
        try context.execute(deleteResult)
        
        // Create new logs from parsed data
        for workout in workouts {
            // Find matching day
            let dayRequest: NSFetchRequest<WorkoutDay> = WorkoutDay.fetchRequest()
            dayRequest.predicate = NSPredicate(format: "name == %@", workout.day)
            dayRequest.fetchLimit = 1
            
            guard let day = try context.fetch(dayRequest).first else {
                print("Warning: Could not find workout day '\(workout.day)'")
                continue
            }
            
            for exerciseData in workout.exercises {
                // Find matching exercise
                let exerciseRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
                exerciseRequest.predicate = NSPredicate(format: "name == %@ AND day == %@", exerciseData.name, day)
                exerciseRequest.fetchLimit = 1
                
                guard let exercise = try context.fetch(exerciseRequest).first else {
                    print("Warning: Could not find exercise '\(exerciseData.name)' in day '\(workout.day)'")
                    continue
                }
                
                // Create new log
                let log = ExerciseLog(context: context)
                log.id = UUID()
                log.exercise = exercise
                log.dateNormalizedToLocalMidnight = workout.date.normalizedToLocalMidnight
                
                // Set the sets data (pad with empty sets to 4 total)
                let paddedSets = Array(exerciseData.sets.prefix(4)) + Array(repeating: SetData(weight: nil, reps: nil), count: max(0, 4 - exerciseData.sets.count))
                
                log.set1Weight = paddedSets[0].weight ?? 0
                log.set1Reps = paddedSets[0].reps ?? 0
                log.set2Weight = paddedSets[1].weight ?? 0
                log.set2Reps = paddedSets[1].reps ?? 0
                log.set3Weight = paddedSets[2].weight ?? 0
                log.set3Reps = paddedSets[2].reps ?? 0
                log.set4Weight = paddedSets[3].weight ?? 0
                log.set4Reps = paddedSets[3].reps ?? 0
            }
        }
        
        try context.save()
    }
    
    /// Discards changes and reloads from database
    func discardChanges() {
        isEditing = false
        loadWorkoutLog()
        errorMessage = nil
    }
}

enum LogParsingError: LocalizedError {
    case invalidSetFormat(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidSetFormat(let format):
            return "Invalid set format: '\(format)'. Expected format: 'weightxreps'"
        }
    }
}
