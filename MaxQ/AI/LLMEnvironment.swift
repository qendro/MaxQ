//
//  LLMEnvironment.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import SwiftUI

/// Environment key for LLM service dependency injection
private struct LLMServiceKey: EnvironmentKey {
    static let defaultValue: LLMService = LocalLLMService()
}

/// Environment key for LLM result store dependency injection
private struct LLMResultStoreKey: EnvironmentKey {
    static let defaultValue: LLMResultStore = {
        do {
            return try JSONLLMResultStore()
        } catch {
            // Fallback to in-memory store if file system fails
            return InMemoryLLMResultStore()
        }
    }()
}

public extension EnvironmentValues {
    /// Access to LLM service for generating coaching insights
    var llmService: LLMService {
        get { self[LLMServiceKey.self] }
        set { self[LLMServiceKey.self] = newValue }
    }
    
    /// Access to LLM result store for caching completions
    var llmResultStore: LLMResultStore {
        get { self[LLMResultStoreKey.self] }
        set { self[LLMResultStoreKey.self] = newValue }
    }
}

/// In-memory fallback store for when JSON storage fails
private final class InMemoryLLMResultStore: LLMResultStore {
    private var completions: [LLMCompletion] = []
    private let queue = DispatchQueue(label: "InMemoryLLMResultStore")
    
    func fetchCompletions(for sessionId: UUID) async throws -> [LLMCompletion] {
        await withCheckedContinuation { continuation in
            queue.async {
                let results = self.completions.filter { $0.relatedId == sessionId }
                continuation.resume(returning: results)
            }
        }
    }
    
    func save(completion: LLMCompletion) async throws {
        await withCheckedContinuation { continuation in
            queue.async {
                // Remove existing completion of same type for same relatedId
                self.completions.removeAll { existing in
                    existing.type == completion.type && 
                    existing.relatedId == completion.relatedId
                }
                self.completions.append(completion)
                continuation.resume(returning: ())
            }
        }
    }
    
    func purgeOld(maxAgeDays: Int) async throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxAgeDays, to: Date()) ?? Date()
        await withCheckedContinuation { continuation in
            queue.async {
                self.completions.removeAll { $0.createdAt < cutoffDate }
                continuation.resume(returning: ())
            }
        }
    }
    
    func fetchWarmup(for dayId: UUID) async throws -> LLMCompletion? {
        await withCheckedContinuation { continuation in
            queue.async {
                let result = self.completions
                    .filter { $0.type == .warmupSuggestion && $0.relatedId == dayId }
                    .max(by: { $0.createdAt < $1.createdAt })
                continuation.resume(returning: result)
            }
        }
    }
    
    func fetchProgressAnalysis() async throws -> LLMCompletion? {
        await withCheckedContinuation { continuation in
            queue.async {
                let result = self.completions
                    .filter { $0.type == .progressAnalysis }
                    .max(by: { $0.createdAt < $1.createdAt })
                continuation.resume(returning: result)
            }
        }
    }
}
