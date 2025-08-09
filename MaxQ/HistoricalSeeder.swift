import Foundation
import CoreData

enum HistoricalSeeder {
    private static let seededKey = "sampleHistoryV1"

    static func seedSampleHistoryIfNeeded(context: NSManagedObjectContext) {
        if UserDefaults.standard.bool(forKey: seededKey) { return }
        let exerciseFetch: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        // Prefer baseline exercises so history looks realistic
        exerciseFetch.predicate = NSPredicate(format: "isBaseline == YES")
        exerciseFetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \Exercise.day?.order, ascending: true),
            NSSortDescriptor(keyPath: \Exercise.order, ascending: true)
        ]
        exerciseFetch.fetchLimit = 24
        guard let exercises = try? context.fetch(exerciseFetch), !exercises.isEmpty else { return }

        let cal = Calendar.current
        let dates = [ -21, -14, -7 ].compactMap { cal.date(byAdding: .day, value: $0, to: Date())?.normalizedToLocalMidnight }

        for exercise in exercises {
            for (weekIndex, d) in dates.enumerated() {
                // Skip if a log already exists for this date
                let req: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
                req.predicate = NSPredicate(format: "exercise == %@ AND dateNormalizedToLocalMidnight == %@", exercise, d as CVarArg)
                req.fetchLimit = 1
                if let existing = try? context.fetch(req), existing.first != nil { continue }

                let log = ExerciseLog(context: context)
                log.id = UUID()
                log.exercise = exercise
                log.dateNormalizedToLocalMidnight = d

                // Use recommended sets as a baseline and vary slightly per week
                let w1 = (exercise.recSet1Weight ?? 0) + Double(weekIndex * 5)
                let r1 = (exercise.recSet1Reps ?? 0)
                let w2 = (exercise.recSet2Weight ?? 0) + Double(weekIndex * 5)
                let r2 = (exercise.recSet2Reps ?? 0)
                let w3 = (exercise.recSet3Weight ?? 0) + Double(weekIndex * 5)
                let r3 = (exercise.recSet3Reps ?? 0)
                let w4 = (exercise.recSet4Weight ?? 0)
                let r4 = (exercise.recSet4Reps ?? 0)

                log.set1Weight = w1; log.set1Reps = r1
                log.set2Weight = w2; log.set2Reps = r2
                log.set3Weight = w3; log.set3Reps = r3
                log.set4Weight = w4; log.set4Reps = r4
            }
        }

        do {
            if context.hasChanges { try context.save() }
            UserDefaults.standard.set(true, forKey: seededKey)
        } catch {
            // If save fails, do not set the flag so we can retry next launch
            print("Historical seeding failed: \(error)")
        }
    }
}


