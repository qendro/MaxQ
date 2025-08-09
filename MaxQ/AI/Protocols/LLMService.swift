//
//  LLMService.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

/// Protocol for AI-powered workout insights and suggestions
/// Designed to be local-first with optional network enhancement
public protocol LLMService {
    /// Suggests warmup routine based on recent performance
    func suggestWarmup(for dayId: UUID, recent: [SetEntryModel]) async throws -> String
    
    /// Provides session summary and coaching insights
    func summarizeSession(_ session: WorkoutSessionModel) async throws -> String
    
    /// Analyzes progress trends and suggests adjustments
    func analyzeProgress(sessions: [WorkoutSessionModel], exercises: [ExerciseModel]) async throws -> String
}

/// Error types for LLM operations
public enum LLMError: Error, LocalizedError {
    case serviceUnavailable
    case invalidInput
    case processingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            return "AI service is currently unavailable"
        case .invalidInput:
            return "Invalid workout data provided"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        }
    }
}
