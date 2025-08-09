//
//  WorkoutError.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation

/// Errors that can occur during workout data operations
enum WorkoutError: LocalizedError {
    case programNotFound
    case dayNotFound
    case exerciseNotFound
    case logNotFound
    case invalidInput(String)
    case coreDataError(Error)
    
    var errorDescription: String? {
        switch self {
        case .programNotFound:
            return "Program not found"
        case .dayNotFound:
            return "Workout day not found"
        case .exerciseNotFound:
            return "Exercise not found"
        case .logNotFound:
            return "Exercise log not found"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .coreDataError(let error):
            return "Data error: \(error.localizedDescription)"
        }
    }
}