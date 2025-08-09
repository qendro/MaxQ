//
//  WorkoutDaysListView.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import SwiftUI

/// Home screen displaying the list of workout days
struct WorkoutDaysListView: View {
    @Environment(\.editMode) private var editMode
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddDay = false
    @State private var newDayName = ""
    @State private var editingDay: WorkoutDay?
    @State private var editingDayName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading workout days...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.workoutDays.isEmpty {
                    emptyStateView
                } else {
                    workoutDaysList
                }
            }
            .navigationTitle("Workout Days")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.workoutDays.isEmpty {
                        Button(viewModel.isEditMode ? "Done" : "Edit") {
                            viewModel.toggleEditMode()
                            withAnimation {
                                editMode?.wrappedValue = viewModel.isEditMode ? .active : .inactive
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddDay = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addDayButton")
                }
            }
            .undoSupport(viewModel.undoManager)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showingAddDay) {
                addDaySheet
            }
            .sheet(item: $editingDay) { day in
                editDaySheet(day: day)
            }
            .onAppear {
                viewModel.fetchActiveDays()
            }
        }
        .dynamicTypeSize(.large ... .accessibility3)
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(Color(.secondaryLabel))
            
            VStack(spacing: 8) {
                Text("No Workout Days")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first workout day to get started")
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingAddDay = true
            } label: {
                Label("Add Workout Day", systemImage: "plus")
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
    }
    
    private var workoutDaysList: some View {
        List {
            ForEach(viewModel.workoutDays, id: \.id) { day in
                if viewModel.isEditMode {
                    WorkoutDayRow(
                        day: day,
                        exerciseCount: viewModel.getExerciseCount(for: day),
                        isEditMode: true,
                        onEdit: { editingDay = day; editingDayName = day.name ?? "" },
                        onDelete: { viewModel.deleteDay(day) }
                    )
                } else {
                    NavigationLink(destination: DayDetailView(day: day)) {
                        WorkoutDayRow(
                            day: day,
                            exerciseCount: viewModel.getExerciseCount(for: day),
                            isEditMode: false,
                            onEdit: { },
                            onDelete: { }
                        )
                    }
                }
            }
            .onMove(perform: { indices, newOffset in
                if viewModel.isEditMode {
                    viewModel.reorderDays(from: indices, to: newOffset)
                }
            })
            .moveDisabled(!viewModel.isEditMode)
        }
        .listStyle(.insetGrouped)
        .listRowSeparatorTint(Color(.separator))
        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))

    }
    
    private var addDaySheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add Workout Day")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Day Name")
                        .font(.headline)
                    
                    TextField("Enter day name (e.g., Push Day)", text: $newDayName)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit {
                            addDay()
                        }
                        .accessibilityIdentifier("addDayTextField")
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddDay = false
                        newDayName = ""
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addDay()
                    }
                    .disabled(newDayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("confirmAddDayButton")
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func editDaySheet(day: WorkoutDay) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Workout Day")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Day Name")
                        .font(.headline)
                    
                    TextField("Enter day name", text: $editingDayName)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit {
                            saveEditedDay(day)
                        }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        editingDay = nil
                        editingDayName = ""
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEditedDay(day)
                    }
                    .disabled(editingDayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            editingDayName = day.name ?? ""
        }
    }
    
    // MARK: - Actions
    
    private func addDay() {
        viewModel.createDay(name: newDayName)
        showingAddDay = false
        newDayName = ""
    }
    
    private func saveEditedDay(_ day: WorkoutDay) {
        viewModel.renameDay(day, to: editingDayName)
        editingDay = nil
        editingDayName = ""
    }
}

// MARK: - Workout Day Row

struct WorkoutDayRow: View {
    let day: WorkoutDay
    let exerciseCount: Int
    let isEditMode: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(day.name ?? "Unknown Day")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            Spacer()
            
            if isEditMode {
                HStack(spacing: 12) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Rename \(day.name ?? "day")")
                    .buttonStyle(.plain)
                    
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Delete \(day.name ?? "day")")
                    .buttonStyle(.plain)
                }
            }
        }
        .contentShape(Rectangle())
        .frame(minHeight: 56)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("")
        .accessibilityValue({
            let name = day.name ?? "Unknown Day"
            return "\(name), \(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"
        }())
    }
}

// MARK: - Preview

#Preview {
    WorkoutDaysListView()
        .environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}