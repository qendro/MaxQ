//
//  JSONWorkoutStore.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation

extension JSONEncoder {
    func with(_ configure: (JSONEncoder) -> Void) -> JSONEncoder {
        configure(self)
        return self
    }
}

public final class JSONWorkoutStore: WorkoutStore {
    private let programsURL: URL
    private let sessionsURL: URL
    private let queue = DispatchQueue(label: "JSONWorkoutStore")

    public init(folderName: String = "MaxQ") throws {
        let base = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        ).appending(path: folderName, directoryHint: .isDirectory)

        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        programsURL = base.appending(path: "programs.json")
        sessionsURL = base.appending(path: "sessions.json")

        // ensure files exist
        if !FileManager.default.fileExists(atPath: programsURL.path) {
            try Data("[]".utf8).write(to: programsURL)
        }
        if !FileManager.default.fileExists(atPath: sessionsURL.path) {
            try Data("[]".utf8).write(to: sessionsURL)
        }
    }

    public func loadPrograms() async throws -> [ProgramModel] {
        try await read([ProgramModel].self, from: programsURL)
    }

    public func save(programs: [ProgramModel]) async throws {
        try await write(programs, to: programsURL)
    }

    public func loadSessions() async throws -> [WorkoutSessionModel] {
        try await read([WorkoutSessionModel].self, from: sessionsURL)
    }

    public func append(session: WorkoutSessionModel) async throws {
        var all = try await loadSessions()
        all.append(session)
        try await write(all, to: sessionsURL)
    }

    public func replace(session: WorkoutSessionModel) async throws {
        var all = try await loadSessions()
        guard let idx = all.firstIndex(where: { $0.id == session.id }) else { throw StoreError.notFound }
        all[idx] = session
        try await write(all, to: sessionsURL)
    }

    public func latestSessions(limit: Int) async throws -> [WorkoutSessionModel] {
        let all = try await loadSessions()
        return Array(all.sorted(by: { $0.date > $1.date }).prefix(limit))
    }

    // MARK: - IO
    private func read<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    let data = try Data(contentsOf: url)
                    let value = try JSONDecoder().decode(T.self, from: data)
                    cont.resume(returning: value)
                } catch { cont.resume(throwing: StoreError.io(error)) }
            }
        }
    }

    private func write<T: Encodable>(_ value: T, to url: URL) async throws {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    let data = try JSONEncoder().with { $0.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys] }.encode(value)
                    try data.write(to: url, options: .atomic)
                    cont.resume()
                } catch { cont.resume(throwing: StoreError.io(error)) }
            }
        }
    }
}
