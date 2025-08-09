//
//  MaxQApp.swift
//  MaxQ
//
//  Created by Qendrim Qeriqi on 8/8/25.
//

import SwiftUI

@main
struct MaxQApp: App {
    let coreDataManager = CoreDataManager.shared
    @State private var showOnboarding: Bool = {
        // Show onboarding if no active program stored
        if let idString = UserDefaults.standard.string(forKey: "activeProgram"), UUID(uuidString: idString) != nil {
            return false
        }
        return true
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                // Inject LLM services for coaching insights  
                .environment(\.llmService, LocalLLMService())
                .environment(\.llmResultStore, (try? JSONLLMResultStore()) ?? {
                    // Fallback to in-memory store - create inline to avoid complex initialization
                    final class InMemoryStore: LLMResultStore {
                        private var completions: [LLMCompletion] = []
                        func fetchCompletions(for sessionId: UUID) async throws -> [LLMCompletion] { completions.filter { $0.relatedId == sessionId } }
                        func save(completion: LLMCompletion) async throws { completions.append(completion) }
                        func purgeOld(maxAgeDays: Int) async throws { /* no-op for memory store */ }
                        func fetchWarmup(for dayId: UUID) async throws -> LLMCompletion? { completions.first { $0.type == .warmupSuggestion && $0.relatedId == dayId } }
                        func fetchProgressAnalysis() async throws -> LLMCompletion? { completions.first { $0.type == .progressAnalysis } }
                    }
                    return InMemoryStore()
                }())
                .onAppear {
                    // Perform seed data initialization on app launch
                    let seedManager = SeedDataManager(context: coreDataManager.viewContext)
                    seedManager.seedIfNeeded()
                    #if DEBUG
                    // UI-test hooks
                    let args = ProcessInfo.processInfo.arguments
                    if args.contains("-uiTestPreloadHistory") || args.contains("-debugPreloadHistory") {
                        TestUIHooks.preloadHistoryIfPossible(context: coreDataManager.viewContext)
                    }
                    #endif
                    // Always add a few weeks of sample logs once for better initial UX
                    HistoricalSeeder.seedSampleHistoryIfNeeded(context: coreDataManager.viewContext)
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(didComplete: $showOnboarding)
                }
        }
    }
}
