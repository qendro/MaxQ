//
//  TestUIHooks.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import Foundation
import CoreData

#if DEBUG
enum TestUIHooks {
    static func preloadHistoryIfPossible(context: NSManagedObjectContext) {
        // Seed three weeks of history for the first day and its first exercise (create one if missing)
        let dayFetch: NSFetchRequest<WorkoutDay> = WorkoutDay.fetchRequest()
        dayFetch.predicate = NSPredicate(format: "isActive == YES")
        dayFetch.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutDay.createdAt, ascending: true)]
        guard let day = try? context.fetch(dayFetch).first else { return }

        let exFetch: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        exFetch.predicate = NSPredicate(format: "day == %@", day)
        exFetch.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.order, ascending: true)]
        let exercise = (try? context.fetch(exFetch).first) ?? {
            let e = Exercise(context: context)
            e.id = UUID(); e.name = "Bench Press"; e.order = 0; e.isBaseline = true; e.day = day
            e.recSet1Weight = 135; e.recSet1Reps = 8
            e.recSet2Weight = 145; e.recSet2Reps = 6
            e.recSet3Weight = 155; e.recSet3Reps = 4
            e.recSet4Weight = 0;   e.recSet4Reps = 0
            return e
        }()

        let cal = Calendar.current
        let dates = [ -21, -14, -7 ].compactMap { cal.date(byAdding: .day, value: $0, to: Date())?.normalizedToLocalMidnight }
        for (idx, d) in dates.enumerated() {
            let log = ExerciseLog(context: context)
            log.id = UUID()
            log.exercise = exercise
            log.dateNormalizedToLocalMidnight = d
            log.set1Weight = 125 + Double(idx * 5)
            log.set1Reps = 8
            log.set2Weight = 135 + Double(idx * 5)
            log.set2Reps = 6
            log.set3Weight = 145 + Double(idx * 5)
            log.set3Reps = 4
            log.set4Weight = 0
            log.set4Reps = 0
        }
        try? context.save()
    }
}
#endif


