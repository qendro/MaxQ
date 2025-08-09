import SwiftUI
import CoreData

struct SettingsView: View {
    @State private var programs: [Program] = []
    @State private var selectedProgramId: UUID?
    private let repository = WorkoutRepository.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Active Program")) {
                    if programs.isEmpty {
                        Text("No programs available")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Program", selection: Binding(get: {
                            selectedProgramId ?? programs.first?.id
                        }, set: { newValue in
                            selectedProgramId = newValue
                            if let id = newValue, let program = programs.first(where: { $0.id == id }) {
                                UserDefaults.standard.set(id.uuidString, forKey: "activeProgram")
                            }
                        })) {
                            ForEach(programs, id: \.id) { program in
                                Text(program.name ?? "Program").tag(program.id)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
                
                Section(header: Text("Units")) {
                    HStack {
                        Text("Weight Units")
                        Spacer()
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundColor(.secondary)
                    }
                    Button("Export Logs to CSV") {
                        exportCSV()
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear(perform: loadPrograms)
        }
    }
    
    private func loadPrograms() {
        programs = repository.fetchPrograms()
        if let saved = UserDefaults.standard.string(forKey: "activeProgram"),
           let id = UUID(uuidString: saved) {
            selectedProgramId = id
        } else {
            selectedProgramId = programs.first?.id
        }
    }

    private func exportCSV() {
        // Placeholder: in-app share sheet can be added later; write to tmp and log path
        // This is sufficient to meet MVP optional requirement hook
        // Real UI share omitted to keep changes minimal
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("logs.csv")
        let context = CoreDataManager.shared.viewContext
        let request: NSFetchRequest<ExerciseLog> = ExerciseLog.fetchRequest()
        do {
            let logs = try context.fetch(request)
            var csv = "date,exercise,set1,set2,set3,set4\n"
            let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
            for log in logs {
                let name = log.exercise?.name ?? "Exercise"
                let date = df.string(from: log.dateNormalizedToLocalMidnight ?? Date())
                let s: [(Double?, Int16?)] = [(log.set1Weight, log.set1Reps),(log.set2Weight, log.set2Reps),(log.set3Weight, log.set3Reps),(log.set4Weight, log.set4Reps)]
                func token(_ t: (Double?, Int16?)) -> String { "\(Int(t.0 ?? 0))x\(t.1 ?? 0)" }
                csv += "\(date),\(name),\(token(s[0])),\(token(s[1])),\(token(s[2])),\(token(s[3]))\n"
            }
            try csv.data(using: .utf8)?.write(to: url)
            print("CSV exported to: \(url.path)")
        } catch {
            print("Export failed: \(error)")
        }
    }
}


