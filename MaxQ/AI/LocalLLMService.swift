//
//  LocalLLMService.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

/// Local, rules-based LLM service that provides deterministic coaching insights
/// No network required - keeps the app offline-first and shippable
struct LocalLLMService: LLMService {
    
    func suggestWarmup(for dayId: UUID, recent: [SetEntryModel]) async throws -> String {
        // Simulate brief processing time
        try await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        guard !recent.isEmpty else {
            return "Start with 5-10 minutes general warmup, then 2×10 at 40% of your working weight."
        }
        
        // Calculate volume trend from recent entries
        let recentVolume = recent.reduce(0.0) { total, entry in
            total + (entry.weight * Double(entry.reps))
        }
        
        if recentVolume > 1000 { // High volume session
            return "Higher volume detected. Warm up thoroughly:\n• 2×12 at 30%\n• 1×8 at 50%\n• 1×5 at 70%\n• 1×3 at 85%"
        } else if recentVolume > 500 { // Moderate volume
            return "Moderate session ahead:\n• 2×10 at 40%\n• 1×6 at 60%\n• 1×3 at 75%"
        } else { // Light session
            return "Light session warmup:\n• 2×8 at 40%\n• 1×5 at 60%"
        }
    }
    
    func summarizeSession(_ session: WorkoutSessionModel) async throws -> String {
        // Simulate processing time
        try await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        let totalVolume = session.entries.reduce(0.0) { total, entry in
            total + (entry.weight * Double(entry.reps))
        }
        
        let exerciseCount = Set(session.entries.map { $0.exerciseId }).count
        let setCount = session.entries.count
        
        var insights: [String] = []
        
        // Volume assessment
        if totalVolume > 2000 {
            insights.append("🔥 High volume session (\(Int(totalVolume))lbs)")
        } else if totalVolume > 1000 {
            insights.append("💪 Solid session (\(Int(totalVolume))lbs)")
        } else {
            insights.append("✅ Light session (\(Int(totalVolume))lbs)")
        }
        
        // Exercise variety
        if exerciseCount >= 5 {
            insights.append("Great exercise variety")
        } else if exerciseCount >= 3 {
            insights.append("Good focus on key movements")
        }
        
        // Set density
        if setCount >= 20 {
            insights.append("High training density")
        }
        
        // Recovery suggestion based on volume
        if totalVolume > 1500 {
            insights.append("Consider 48-72h recovery before similar intensity")
        }
        
        // RPE coaching (simulated based on volume)
        if totalVolume > 2000 {
            insights.append("Next session: target RPE 7-8 for top sets")
        } else {
            insights.append("Good foundation - push intensity next session")
        }
        
        return insights.joined(separator: " • ")
    }
    
    func analyzeProgress(sessions: [WorkoutSessionModel], exercises: [ExerciseModel]) async throws -> String {
        // Simulate analysis time
        try await Task.sleep(nanoseconds: 400_000_000) // 400ms
        
        guard sessions.count >= 3 else {
            return "Complete 3+ sessions for meaningful progress analysis."
        }
        
        let recentSessions = sessions.suffix(3)
        let volumes = recentSessions.map { session in
            session.entries.reduce(0.0) { total, entry in
                total + (entry.weight * Double(entry.reps))
            }
        }
        
        var progressInsights: [String] = []
        
        // Volume trend analysis
        let volumeChange = volumes.last! - volumes.first!
        let volumePercentChange = (volumeChange / volumes.first!) * 100
        
        if volumePercentChange > 10 {
            progressInsights.append("📈 Volume trending up (\(String(format: "%.1f", volumePercentChange))%)")
        } else if volumePercentChange < -10 {
            progressInsights.append("📉 Volume declining - consider deload week")
        } else {
            progressInsights.append("📊 Volume stable - good consistency")
        }
        
        // Frequency analysis
        let daysBetween = sessions.suffix(2).reduce(0) { _, sessions in
            // Simplified - assume consistent training
            return 2 // Average days between sessions
        }
        
        if daysBetween <= 2 {
            progressInsights.append("High frequency training")
        } else if daysBetween >= 4 {
            progressInsights.append("Consider increasing frequency for faster progress")
        }
        
        // Exercise selection feedback
        let totalExercises = Set(sessions.flatMap { $0.entries.map { $0.exerciseId } }).count
        if totalExercises < 8 {
            progressInsights.append("Try adding 1-2 accessory movements")
        }
        
        return progressInsights.joined(separator: " • ")
    }
}
