//
//  JSONLLMResultStore.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

/// JSON-based implementation of LLMResultStore
/// Stores completions in local JSON files for offline access
final class JSONLLMResultStore: LLMResultStore {
    private let completionsURL: URL
    private let queue = DispatchQueue(label: "JSONLLMResultStore")
    
    init(folderName: String = "MaxQ") throws {
        let base = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        ).appending(path: folderName, directoryHint: .isDirectory)
        
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        completionsURL = base.appending(path: "llm_completions.json")
        
        // Ensure file exists
        if !FileManager.default.fileExists(atPath: completionsURL.path) {
            try Data("[]".utf8).write(to: completionsURL)
        }
    }
    
    func fetchCompletions(for sessionId: UUID) async throws -> [LLMCompletion] {
        let allCompletions = try await loadCompletions()
        return allCompletions.filter { $0.relatedId == sessionId }
    }
    
    func save(completion: LLMCompletion) async throws {
        var allCompletions = try await loadCompletions()
        
        // Remove existing completion of same type for same relatedId to avoid duplicates
        allCompletions.removeAll { existing in
            existing.type == completion.type && 
            existing.relatedId == completion.relatedId
        }
        
        allCompletions.append(completion)
        try await saveCompletions(allCompletions)
    }
    
    func purgeOld(maxAgeDays: Int) async throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxAgeDays, to: Date()) ?? Date()
        var allCompletions = try await loadCompletions()
        
        let countBefore = allCompletions.count
        allCompletions.removeAll { $0.createdAt < cutoffDate }
        
        if allCompletions.count != countBefore {
            try await saveCompletions(allCompletions)
        }
    }
    
    func fetchWarmup(for dayId: UUID) async throws -> LLMCompletion? {
        let allCompletions = try await loadCompletions()
        return allCompletions
            .filter { $0.type == .warmupSuggestion && $0.relatedId == dayId }
            .max(by: { $0.createdAt < $1.createdAt }) // Most recent
    }
    
    func fetchProgressAnalysis() async throws -> LLMCompletion? {
        let allCompletions = try await loadCompletions()
        return allCompletions
            .filter { $0.type == .progressAnalysis }
            .max(by: { $0.createdAt < $1.createdAt }) // Most recent
    }
    
    // MARK: - Private Methods
    
    private func loadCompletions() async throws -> [LLMCompletion] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let data = try Data(contentsOf: self.completionsURL)
                    let completions = try JSONDecoder().decode([LLMCompletion].self, from: data)
                    continuation.resume(returning: completions)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func saveCompletions(_ completions: [LLMCompletion]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    encoder.dateEncodingStrategy = .iso8601
                    
                    let data = try encoder.encode(completions)
                    try data.write(to: self.completionsURL, options: .atomic)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
