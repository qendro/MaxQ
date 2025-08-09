//
//  WorkoutStore.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

public protocol WorkoutStore {
    func loadPrograms() async throws -> [ProgramModel]
    func save(programs: [ProgramModel]) async throws

    func loadSessions() async throws -> [WorkoutSessionModel]
    func append(session: WorkoutSessionModel) async throws
    func replace(session: WorkoutSessionModel) async throws

    // convenience
    func latestSessions(limit: Int) async throws -> [WorkoutSessionModel]
}

public enum StoreError: Error { 
    case notFound, corrupted, io(Error) 
}
