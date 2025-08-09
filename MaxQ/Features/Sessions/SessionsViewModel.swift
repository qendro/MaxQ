//
//  SessionsViewModel.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation
import Observation

@Observable
final class SessionsViewModel {
    private let store: WorkoutStore
    var sessions: [WorkoutSessionModel] = []
    var programs: [ProgramModel] = []
    var exercises: [ExerciseModel] = []
    var loading = false
    var error: String?

    init(store: WorkoutStore) { 
        self.store = store 
    }

    @MainActor
    func load() async {
        loading = true
        defer { loading = false }
        
        do { 
            async let sessionsTask = store.latestSessions(limit: 50)
            async let programsTask = store.loadPrograms()
            
            sessions = try await sessionsTask
            programs = try await programsTask
            exercises = SeedService.defaultExercises() // For now, use default exercises
        } catch { 
            self.error = "Failed to load data: \(error.localizedDescription)" 
        }
    }

    @MainActor
    func add(entry: SetEntryModel, to sessionId: UUID) async {
        do {
            guard let existing = sessions.first(where: { $0.id == sessionId }) else { return }
            var updated = existing
            updated.entries.append(entry)
            try await store.replace(session: updated)
            await load()
            Haptics.success()
        } catch { 
            self.error = "Failed to save entry: \(error.localizedDescription)"
            Haptics.error()
        }
    }
    
    @MainActor
    func createSession(for dayId: UUID, programId: UUID) async {
        let session = WorkoutSessionModel(
            date: Date(),
            programId: programId,
            dayId: dayId
        )
        
        do {
            try await store.append(session: session)
            await load()
            Haptics.success()
        } catch {
            self.error = "Failed to create session: \(error.localizedDescription)"
            Haptics.error()
        }
    }
    
    @MainActor
    func savePrograms() async {
        do {
            try await store.save(programs: programs)
            Haptics.success()
        } catch {
            self.error = "Failed to save programs: \(error.localizedDescription)"
            Haptics.error()
        }
    }
    
    // MARK: - Computed Properties
    var weeklyVolumePoints: [WeekPoint] {
        sessions.weeklyVolumePoints()
    }
    
    func exerciseName(for id: UUID) -> String {
        exercises.first { $0.id == id }?.name ?? "Unknown Exercise"
    }
    
    func program(for id: UUID) -> ProgramModel? {
        programs.first { $0.id == id }
    }
    
    func day(for id: UUID, in programId: UUID) -> WorkoutDayModel? {
        program(for: programId)?.days.first { $0.id == id }
    }
}
