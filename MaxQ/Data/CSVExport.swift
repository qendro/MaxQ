//
//  CSVExport.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

enum CSVExport {
    static func make(sessions: [WorkoutSessionModel], exercises: [ExerciseModel] = []) -> String {
        var rows = ["date,exercise,weight,reps,rpe,notes"]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        // Create exercise lookup for names
        let exerciseMap = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0.name) })
        
        for session in sessions.sorted(by: { $0.date < $1.date }) {
            let dateString = df.string(from: session.date)
            let notes = session.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            
            for entry in session.entries {
                let exerciseName = exerciseMap[entry.exerciseId] ?? entry.exerciseId.uuidString
                let escapedName = exerciseName.replacingOccurrences(of: "\"", with: "\"\"")
                let rpe = entry.rpe.map { String($0) } ?? ""
                
                rows.append("\"\(dateString)\",\"\(escapedName)\",\(entry.weight),\(entry.reps),\(rpe),\"\(notes)\"")
            }
        }
        return rows.joined(separator: "\n")
    }
    
    static func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory.appending(path: "maxq_export_\(Date().timeIntervalSince1970).csv")
    }
}
