//
//  LLMResultStore.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

/// Stores and retrieves LLM-generated insights locally
/// Enables caching for offline access and avoids re-computation
public protocol LLMResultStore {
    /// Fetch cached completions for a specific workout session
    func fetchCompletions(for sessionId: UUID) async throws -> [LLMCompletion]
    
    /// Save a new completion result
    func save(completion: LLMCompletion) async throws
    
    /// Remove old completions to manage storage
    func purgeOld(maxAgeDays: Int) async throws
    
    /// Get cached warmup suggestion for a day
    func fetchWarmup(for dayId: UUID) async throws -> LLMCompletion?
    
    /// Get cached progress analysis
    func fetchProgressAnalysis() async throws -> LLMCompletion?
}

/// Represents a cached LLM completion
public struct LLMCompletion: Identifiable, Codable, Sendable {
    public let id: UUID
    public let type: CompletionType
    public let content: String
    public let relatedId: UUID? // sessionId, dayId, etc.
    public let createdAt: Date
    public let metadata: [String: String]
    
    public init(
        id: UUID = UUID(),
        type: CompletionType,
        content: String,
        relatedId: UUID? = nil,
        createdAt: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.relatedId = relatedId
        self.createdAt = createdAt
        self.metadata = metadata
    }
}

/// Types of LLM completions we store
public enum CompletionType: String, Codable, CaseIterable {
    case warmupSuggestion = "warmup"
    case sessionSummary = "summary"
    case progressAnalysis = "progress"
    
    public var displayName: String {
        switch self {
        case .warmupSuggestion: return "Warmup Suggestion"
        case .sessionSummary: return "Session Summary"
        case .progressAnalysis: return "Progress Analysis"
        }
    }
}
