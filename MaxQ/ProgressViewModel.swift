import Foundation
import CoreData

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var weeklyVolume: Double = 0
    @Published var topPRs: [(exercise: String, weight: Double, reps: Int16)] = []
    @Published var streakDays: Int = 0
    
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext = Database.shared.viewContext) {
        self.context = context
    }
    
    func refresh() {
        computeWeeklyVolume()
        computeTopPRs()
        computeStreak()
    }
    
    private func computeWeeklyVolume() {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        request.predicate = NSPredicate(format: "dateNormalizedToLocalMidnight >= %@", startOfWeek as CVarArg)
        do {
            let logs = try context.fetch(request)
            weeklyVolume = logs.reduce(0) { sum, log in
                let sets: [(Double?, Int16?)] = [
                    (log.set1Weight, log.set1Reps), (log.set2Weight, log.set2Reps), (log.set3Weight, log.set3Reps), (log.set4Weight, log.set4Reps)
                ]
                let vol = sets.reduce(0) { acc, s in acc + ((s.0 ?? 0) * Double(s.1 ?? 0)) }
                return sum + vol
            }
        } catch { weeklyVolume = 0 }
    }
    
    private func computeTopPRs() {
        // Simple PR: max set1..4 weight, tie by reps, per exercise
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        do {
            let logs = try context.fetch(request)
            var best: [ObjectIdentifier: (String, Double, Int16)] = [:]
            for log in logs {
                let name = log.exercise?.name ?? "Exercise"
                let key = ObjectIdentifier(log.exercise!)
                let sets: [(Double, Int16)] = [
                    (log.set1Weight ?? 0, log.set1Reps ?? 0),
                    (log.set2Weight ?? 0, log.set2Reps ?? 0),
                    (log.set3Weight ?? 0, log.set3Reps ?? 0),
                    (log.set4Weight ?? 0, log.set4Reps ?? 0)
                ]
                let candidate = sets.max { a, b in (a.0, a.1) < (b.0, b.1) } ?? (0,0)
                if let current = best[key] {
                    if (candidate.0, candidate.1) > (current.1, current.2) { best[key] = (name, candidate.0, candidate.1) }
                } else {
                    best[key] = (name, candidate.0, candidate.1)
                }
            }
            topPRs = best.values.sorted { $0.1 > $1.1 }.prefix(5).map { $0 }
        } catch { topPRs = [] }
    }
    
    private func computeStreak() {
        // Count consecutive days with any log starting from today back
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        do {
            let logs = try context.fetch(request)
            let dates = Set(logs.compactMap { $0.dateNormalizedToLocalMidnight })
            var day = Date().normalizedToLocalMidnight
            var count = 0
            while dates.contains(day) {
                count += 1
                if let prev = Calendar.current.date(byAdding: .day, value: -1, to: day) { day = prev } else { break }
            }
            streakDays = count
        } catch { streakDays = 0 }
    }
}


