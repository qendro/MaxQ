//
//  DayDetailView.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import SwiftUI
import CoreData

/// Day Detail: manages exercises and today's sets
struct DayDetailView: View {
    let day: WorkoutDay
    @StateObject private var viewModel: DayDetailViewModel
    @State private var showingAddExercise = false
    @State private var newExerciseName = ""
    @FocusState private var focused: DayDetailViewModel.FocusedCell?
    
    init(day: WorkoutDay) {
        self.day = day
        _viewModel = StateObject(wrappedValue: DayDetailViewModel(day: day))
    }
    
    var body: some View {
        List {
            Section {
                if viewModel.exercises.isEmpty {
                    Text("No exercises yet. Add one to get started.")
                        .foregroundColor(Color(.secondaryLabel))
                } else {
                    ForEach(viewModel.exercises, id: \.objectID) { exercise in
                        DisclosureGroup {
                            historyAndTodayEditor(for: exercise)
                        } label: {
                            tableRow(for: exercise)
                        }
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                }
                addExerciseInlineRow
            } header: {
                Text("Exercises")
            }
        }
        .listStyle(.insetGrouped)
        .listRowSeparatorTint(Color(.separator))
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .navigationTitle(day.name ?? "Day")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .accessibilityIdentifier("editExercisesButton")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddExercise = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("addExerciseButton")
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            addExerciseSheet
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage { Text(error) }
        }
        .onAppear { viewModel.loadExercises() }
        .onChange(of: focused) { _, newValue in
            viewModel.focusedCell = newValue
        }
        .undoSupport(viewModel.undoManager)
        .dynamicTypeSize(.large ... .accessibility3)
    }
    
    // Removed old exerciseRow and setsGrid in favor of compact table UX
    
    @ViewBuilder
    private func tableRow(for exercise: Exercise) -> some View {
        // Compact, non-editable row: Exercise | Set1 W×R | Set2 | Set3 | Set4
        let model = viewModel.displayModel(for: exercise)
        HStack(spacing: 8) {
            Text(model.name)
                .font(.body.weight(.medium))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 100, alignment: .leading)
            let sets = model.todaysSets
            ForEach(0..<4, id: \.self) { idx in
                Text(sets[idx].displayString.isEmpty ? "—" : sets[idx].displayString)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .frame(width: 50, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
    }

    private func historyAndTodayEditor(for exercise: Exercise) -> some View {
        let history = viewModel.lastThreeWeeks(for: exercise)
        let sets = viewModel.todaysSets(for: exercise)
        return VStack(alignment: .leading, spacing: 6) {
            // Inline 3-row history
            if history.isEmpty {
                Text("No past logs yet").font(.caption).foregroundColor(.secondary)
            } else {
                ForEach(Array(history.enumerated()), id: \.offset) { _, entry in
                    HStack(spacing: 8) {
                        Text(formatDate(entry.date))
                            .font(.caption2)
                            .foregroundColor(Color(.secondaryLabel))
                            .frame(width: 60, alignment: .leading)
                        ForEach(0..<4, id: \.self) { idx in
                            Text(entry.sets[idx].displayString.isEmpty ? "—" : entry.sets[idx].displayString)
                                .font(.caption2)
                                .foregroundColor(Color(.secondaryLabel))
                                .frame(width: 50, alignment: .leading)
                        }
                    }
                }
            }
            Divider()
            // Inline editable today row
            HStack(spacing: 8) {
                Text("Today")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
                ForEach(0..<4, id: \.self) { idx in
                    HStack(spacing: 2) {
                        TextField("W", text: Binding(get: {
                            sets[idx].weight.map { String(format: "%.0f", $0) } ?? ""
                        }, set: { viewModel.updateWeight(for: exercise, setIndex: idx, weightString: $0) }))
                        .keyboardType(.decimalPad)
                        .frame(width: 28)
                        .textFieldStyle(.roundedBorder)
                        Text("×").font(.caption2).foregroundColor(Color(.secondaryLabel))
                        TextField("R", text: Binding(get: {
                            sets[idx].reps.map { String($0) } ?? ""
                        }, set: { viewModel.updateReps(for: exercise, setIndex: idx, repsString: $0) }))
                        .keyboardType(.numberPad)
                        .frame(width: 22)
                        .textFieldStyle(.roundedBorder)
                    }
                    .frame(width: 50, alignment: .leading)
                }
                Spacer()
                Button("Save") { viewModel.commitTodaysSets(for: exercise) }
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter(); df.dateFormat = "MM/dd/yy"
        return df.string(from: date)
    }
    
    private var addExerciseInlineRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill").foregroundColor(.accentColor)
            TextField("Add exercise", text: $newExerciseName)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onSubmit { addExercise() }
                .accessibilityIdentifier("inlineAddExerciseTextField")
            Button("Add") { addExercise() }
                .disabled(newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("inlineAddExerciseButton")
        }
        .padding(.vertical, 4)
    }
    
    private func delete(at offsets: IndexSet) {
        for i in offsets { viewModel.deleteExercise(viewModel.exercises[i]) }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        // Update local order then persist
        var updated = viewModel.exercises
        updated.move(fromOffsets: source, toOffset: destination)
        day.updateExerciseOrder(updated)
        for e in updated { WorkoutRepository.shared.updateExercise(e) }
        viewModel.loadExercises()
    }
    
    private var addExerciseSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add Exercise").font(.title2).fontWeight(.semibold).padding(.top)
                TextField("Exercise name", text: $newExerciseName)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit { addExercise() }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showingAddExercise = false; newExerciseName = "" }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { addExercise() }
                        .disabled(newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func addExercise() {
        viewModel.addExercise(named: newExerciseName)
        showingAddExercise = false
        newExerciseName = ""
    }
}

#Preview {
    let context = Database.preview.viewContext
    let sampleDay = WorkoutDay(context: context)
    sampleDay.id = UUID()
    sampleDay.name = "Push Day"
    sampleDay.isActive = true
    return NavigationStack { DayDetailView(day: sampleDay) }
        .environment(\.managedObjectContext, context)
}


