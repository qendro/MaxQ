//
//  ExerciseDetailView.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    let dayName: String
    
    @StateObject private var viewModel: ExerciseDetailViewModel
    
    init(exercise: Exercise, dayName: String) {
        self.exercise = exercise
        self.dayName = dayName
        _viewModel = StateObject(wrappedValue: ExerciseDetailViewModel(exercise: exercise))
    }
    
    var body: some View {
        List {
            headerSection
            todaySection
            historySection
        }
        .listStyle(.insetGrouped)
        .listRowSeparatorTint(Color(.separator))
        .navigationTitle("Exercise")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update Recommended") { viewModel.updateRecommendedFromToday() }
                    .font(.subheadline)
            }
        }
        .dynamicTypeSize(.large ... .accessibility3)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage { Text(error) }
        }
        .onAppear { viewModel.load() }
    }
    
    // MARK: - Sections
    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Exercise name", text: $viewModel.exerciseName)
                    .font(.title3.weight(.semibold))
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit { viewModel.rename(to: viewModel.exerciseName) }
                    .accessibilityLabel("Exercise name")
                Text(dayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Day: \(dayName)")
            }
        }
    }
    
    private var todaySection: some View {
        Section(header: Text("Today")) {
            // One-line editable tokens: Set1 W×R | Set2 W×R | Set3 W×R | Set4 W×R
            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { idx in
                    let set = viewModel.todaysSets[idx]
                    HStack(spacing: 6) {
                        Text("Set \(idx + 1)")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                        TextField("W", text: Binding(get: {
                            set.weight.map { String(format: "%.0f", $0) } ?? ""
                        }, set: { viewModel.updateWeight(setIndex: idx, weightString: $0) }))
                        .keyboardType(.decimalPad)
                        .frame(width: 44)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke((set.weight ?? 0) < 0 ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .accessibilityLabel("Set \(idx + 1) weight")
                        Text("×").foregroundColor(Color(.secondaryLabel))
                        TextField("R", text: Binding(get: {
                            set.reps.map { String($0) } ?? ""
                        }, set: { viewModel.updateReps(setIndex: idx, repsString: $0) }))
                        .keyboardType(.numberPad)
                        .frame(width: 36)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke((set.reps ?? 0) < 0 ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .accessibilityLabel("Set \(idx + 1) reps")
                    }
                    if idx < 3 { Text("|").foregroundColor(Color(.separator)) }
                }
                Spacer()
            }
            HStack {
                Spacer()
                Button("Save Today") { viewModel.commitTodaysSets() }
                    .font(.body.weight(.medium))
                    .accessibilityLabel("Save today's sets")
                    .accessibilityIdentifier("saveTodayButton")
            }
        }
    }
    
    private var historySection: some View {
        Section(header: Text("History")) {
            if viewModel.history.isEmpty {
                Text("No past logs yet")
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(viewModel.history.enumerated()), id: \.offset) { _, entry in
                    Text("Week \(entry.weekNumber) (\(formatted(entry.date))): \(formattedSets(entry.sets))")
                        .font(.body)
                        .foregroundColor(Color(.secondaryLabel))
                        .accessibilityLabel("Week \(entry.weekNumber), date \(formatted(entry.date)), sets \(formattedSets(entry.sets))")
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    private func formattedSets(_ sets: [SetData]) -> String {
        func one(_ s: SetData) -> String {
            guard let w = s.weight, let r = s.reps else { return "" }
            return "\(Int(w))×\(r)"
        }
        return sets.map(one).joined(separator: " | ")
    }
}

#Preview {
    let context = Database.preview.viewContext
    let sampleDay = WorkoutDay(context: context)
    sampleDay.id = UUID(); sampleDay.name = "Push Day"; sampleDay.isActive = true
    let ex = Exercise(context: context)
    ex.id = UUID(); ex.name = "Bench Press"; ex.day = sampleDay; ex.isBaseline = true
    return NavigationStack { ExerciseDetailView(exercise: ex, dayName: sampleDay.name ?? "") }
        .environment(\.managedObjectContext, context)
}


