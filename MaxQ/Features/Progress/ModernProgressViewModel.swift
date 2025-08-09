//
//  ModernProgressViewModel.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation
import Observation

/// Modern progress view model with pre-aggregated data for Swift Charts
/// Follows @Observable pattern with efficient data computation
@Observable
final class ModernProgressViewModel {
    // Pre-aggregated chart data
    var weeklyVolumePoints: [WeekPoint] = []
    var exerciseProgressData: [ExerciseProgressPoint] = []
    var strengthMetrics: StrengthMetrics = StrengthMetrics()
    
    // Loading states
    var isLoading = false
    var error: String?
    var lastRefresh: Date?
    
    private let sessionsViewModel: SessionsViewModel
    private let llmService: LLMService
    private let resultStore: LLMResultStore
    
    init(sessionsViewModel: SessionsViewModel, llmService: LLMService, resultStore: LLMResultStore) {
        self.sessionsViewModel = sessionsViewModel
        self.llmService = llmService
        self.resultStore = resultStore
    }
    
    @MainActor
    func refresh() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            // Ensure sessions are loaded
            await sessionsViewModel.load()
            
            // Pre-aggregate all data in parallel
            async let volumeTask = computeWeeklyVolumePoints()
            async let progressTask = computeExerciseProgress()
            async let metricsTask = computeStrengthMetrics()
            
            let (volume, progress, metrics) = try await (volumeTask, progressTask, metricsTask)
            
            weeklyVolumePoints = volume
            exerciseProgressData = progress
            strengthMetrics = metrics
            lastRefresh = Date()
            
        } catch {
            self.error = "Failed to load progress data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Generate AI-powered progress analysis
    @MainActor
    func generateProgressAnalysis() async -> String? {
        do {
            // Check for cached analysis first
            if let cached = try await resultStore.fetchProgressAnalysis(),
               let lastRefresh = lastRefresh,
               Calendar.current.isDate(cached.createdAt, inSameDayAs: lastRefresh) {
                return cached.content
            }
            
            // Generate fresh analysis
            let analysis = try await llmService.analyzeProgress(
                sessions: sessionsViewModel.sessions,
                exercises: sessionsViewModel.exercises
            )
            
            // Cache the result
            let completion = LLMCompletion(
                type: .progressAnalysis,
                content: analysis
            )
            try await resultStore.save(completion: completion)
            
            return analysis
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Computation Methods
    
    private func computeWeeklyVolumePoints() async throws -> [WeekPoint] {
        let sessions = sessionsViewModel.sessions
        let calendar = Calendar.current
        
        // Group sessions by week and compute volume
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.dateInterval(of: .weekOfYear, for: session.date)?.start ?? session.date
        }
        
        return grouped.compactMap { (weekStart, sessions) in
            let totalVolume = sessions.reduce(0.0) { total, session in
                total + session.entries.reduce(0.0) { entryTotal, entry in
                    entryTotal + (entry.weight * Double(entry.reps))
                }
            }
            return WeekPoint(start: weekStart, volume: totalVolume)
        }.sorted { $0.start < $1.start }
    }
    
    private func computeExerciseProgress() async throws -> [ExerciseProgressPoint] {
        let sessions = sessionsViewModel.sessions
        let exercises = sessionsViewModel.exercises
        
        var progressData: [ExerciseProgressPoint] = []
        
        for exercise in exercises.prefix(6) { // Top 6 exercises for cleaner charts
            let exerciseSessions = sessions.filter { session in
                session.entries.contains { $0.exerciseId == exercise.id }
            }.sorted { $0.date < $1.date }
            
            for session in exerciseSessions {
                let exerciseEntries = session.entries.filter { $0.exerciseId == exercise.id }
                
                // Find max weight for this session
                if let maxEntry = exerciseEntries.max(by: { $0.weight < $1.weight }) {
                    let point = ExerciseProgressPoint(
                        id: UUID(),
                        exerciseName: exercise.name,
                        date: session.date,
                        maxWeight: maxEntry.weight,
                        volume: exerciseEntries.reduce(0.0) { total, entry in
                            total + (entry.weight * Double(entry.reps))
                        }
                    )
                    progressData.append(point)
                }
            }
        }
        
        return progressData
    }
    
    private func computeStrengthMetrics() async throws -> StrengthMetrics {
        let sessions = sessionsViewModel.sessions
        let exercises = sessionsViewModel.exercises
        
        // Weekly volume (last 7 days)
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyVolume = sessions
            .filter { $0.date >= weekAgo }
            .flatMap { $0.entries }
            .reduce(0.0) { total, entry in
                total + (entry.weight * Double(entry.reps))
            }
        
        // Personal records (max weight per exercise)
        var personalRecords: [PersonalRecord] = []
        for exercise in exercises {
            let maxEntry = sessions
                .flatMap { $0.entries }
                .filter { $0.exerciseId == exercise.id }
                .max { $0.weight < $1.weight }
            
            if let entry = maxEntry {
                personalRecords.append(PersonalRecord(
                    exerciseName: exercise.name,
                    weight: entry.weight,
                    reps: entry.reps,
                    date: sessions.first { $0.entries.contains(entry) }?.date ?? Date()
                ))
            }
        }
        
        // Workout streak
        let streak = calculateWorkoutStreak(sessions: sessions)
        
        return StrengthMetrics(
            weeklyVolume: weeklyVolume,
            personalRecords: personalRecords.sorted { $0.weight > $1.weight }.prefix(5).map { $0 },
            workoutStreak: streak
        )
    }
    
    private func calculateWorkoutStreak(sessions: [WorkoutSessionModel]) -> Int {
        let dates = Set(sessions.map { Calendar.current.startOfDay(for: $0.date) })
        let today = Calendar.current.startOfDay(for: Date())
        
        var streak = 0
        var currentDate = today
        
        while dates.contains(currentDate) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
}

// MARK: - Supporting Data Types

struct ExerciseProgressPoint: Identifiable {
    let id: UUID
    let exerciseName: String
    let date: Date
    let maxWeight: Double
    let volume: Double
}

struct StrengthMetrics {
    let weeklyVolume: Double
    let personalRecords: [PersonalRecord]
    let workoutStreak: Int
    
    init(weeklyVolume: Double = 0, personalRecords: [PersonalRecord] = [], workoutStreak: Int = 0) {
        self.weeklyVolume = weeklyVolume
        self.personalRecords = personalRecords
        self.workoutStreak = workoutStreak
    }
}

struct PersonalRecord: Identifiable {
    let id = UUID()
    let exerciseName: String
    let weight: Double
    let reps: Int
    let date: Date
}
