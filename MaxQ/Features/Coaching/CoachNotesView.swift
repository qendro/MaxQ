//
//  CoachNotesView.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import SwiftUI

/// Collapsible coaching notes section that provides AI-generated insights
/// Designed for use in workout finish flows and session summaries
struct CoachNotesView: View {
    let session: WorkoutSessionModel
    let dayId: UUID?
    
    @Environment(\.llmService) private var llmService
    @Environment(\.llmResultStore) private var resultStore
    
    @State private var isExpanded = false
    @State private var sessionSummary: String?
    @State private var warmupSuggestion: String?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        DisclosureGroup("Coach Notes", isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                // Session Summary Section
                if let summary = sessionSummary {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Session Summary")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.text)
                        
                        Text(summary)
                            .font(DS.Typography.body)
                            .foregroundColor(DS.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .cardStyle()
                } else if isLoading {
                    HStack(spacing: DS.Spacing.sm) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Analyzing your session...")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.textSecondary)
                    }
                    .cardStyle()
                }
                
                // Next Session Warmup
                if let warmup = warmupSuggestion {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Next Session Warmup")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.text)
                        
                        Text(warmup)
                            .font(DS.Typography.body)
                            .foregroundColor(DS.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .cardStyle()
                }
                
                // Error State
                if let error = error {
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Insights temporarily unavailable")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.textSecondary)
                    }
                    .cardStyle()
                }
            }
        }
        .font(DS.Typography.headline)
        .foregroundColor(DS.brand)
        .onChange(of: isExpanded) { _, expanded in
            if expanded && sessionSummary == nil && !isLoading {
                loadCoachingInsights()
            }
        }
        .onAppear {
            // Pre-load cached insights immediately
            loadCachedInsights()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadCachedInsights() {
        Task {
            do {
                // Try to load cached session summary
                let cachedSummaries = try await resultStore.fetchCompletions(for: session.id)
                if let summary = cachedSummaries.first(where: { $0.type == .sessionSummary }) {
                    await MainActor.run {
                        sessionSummary = summary.content
                    }
                }
                
                // Try to load cached warmup for this day
                if let dayId = dayId {
                    if let warmup = try await resultStore.fetchWarmup(for: dayId) {
                        await MainActor.run {
                            warmupSuggestion = warmup.content
                        }
                    }
                }
            } catch {
                // Silently fail for cached data - we'll generate fresh insights if needed
            }
        }
    }
    
    private func loadCoachingInsights() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                // Generate session summary if not cached
                if sessionSummary == nil {
                    let summary = try await llmService.summarizeSession(session)
                    let completion = LLMCompletion(
                        type: .sessionSummary,
                        content: summary,
                        relatedId: session.id
                    )
                    
                    try await resultStore.save(completion: completion)
                    
                    await MainActor.run {
                        sessionSummary = summary
                        Haptics.success()
                    }
                }
                
                // Generate warmup suggestion if not cached and we have a day
                if let dayId = dayId, warmupSuggestion == nil {
                    let warmup = try await llmService.suggestWarmup(for: dayId, recent: session.entries)
                    let completion = LLMCompletion(
                        type: .warmupSuggestion,
                        content: warmup,
                        relatedId: dayId
                    )
                    
                    try await resultStore.save(completion: completion)
                    
                    await MainActor.run {
                        warmupSuggestion = warmup
                    }
                }
                
            } catch {
                await MainActor.run {
                    self.error = error
                    Haptics.error()
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    let sampleSession = WorkoutSessionModel(
        date: Date(),
        entries: [
            SetEntryModel(exerciseId: UUID(), weight: 185, reps: 8),
            SetEntryModel(exerciseId: UUID(), weight: 225, reps: 6),
            SetEntryModel(exerciseId: UUID(), weight: 225, reps: 5)
        ]
    )
    
    return CoachNotesView(session: sampleSession, dayId: UUID())
        .padding()
        .environment(\.llmService, LocalLLMService())
}
