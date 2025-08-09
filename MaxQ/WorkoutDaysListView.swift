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
                            withAnimation(DS.Animation.bouncy) {
                                viewModel.toggleEditMode()
                                editMode?.wrappedValue = viewModel.isEditMode ? .active : .inactive
                            }
                            Haptics.select()
                        }
                        .font(DS.Typography.bodyMedium)
                        .foregroundColor(DS.brand)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddDay = true
                        Haptics.select()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.medium))
                            .foregroundColor(DS.brand)
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
        EmptyStateView(
            icon: "dumbbell.fill",
            title: "Ready to Lift?",
            subtitle: "Create your first workout day and start tracking your fitness journey.",
            actionTitle: "Add Workout Day"
        ) {
            showingAddDay = true
            Haptics.success()
        }
    }
    
    private var workoutDaysList: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(viewModel.workoutDays, id: \.id) { day in
                    Group {
                        if viewModel.isEditMode {
                            WorkoutDayRow(
                                day: day,
                                exerciseCount: viewModel.getExerciseCount(for: day),
                                isEditMode: true,
                                onEdit: { 
                                    editingDay = day
                                    editingDayName = day.name ?? ""
                                },
                                onDelete: { 
                                    withAnimation(DS.Animation.smooth) {
                                        viewModel.deleteDay(day)
                                    }
                                }
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
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                // Add Workout Day Button (inline)
                if !viewModel.isEditMode {
                    Button {
                        showingAddDay = true
                        Haptics.select()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(DS.brand)
                            
                            Text("Add Workout Day")
                                .font(DS.Typography.bodyMedium)
                                .foregroundColor(DS.brand)
                            
                            Spacer()
                        }
                        .padding(DS.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Corner.lg, style: .continuous)
                                .stroke(DS.brand.opacity(0.3), lineWidth: 2)
                                .fill(DS.brand.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.xxxl)
        }
        .animation(DS.Animation.gentle, value: viewModel.workoutDays.count)
        .animation(DS.Animation.bouncy, value: viewModel.isEditMode)
    }
    
    private var addDaySheet: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xxl) {
                VStack(spacing: DS.Spacing.lg) {
                    Text("Add Workout Day")
                        .font(DS.Typography.title)
                        .foregroundColor(DS.text)
                    
                    Text("Give your workout day a memorable name")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Day Name")
                        .font(DS.Typography.captionMedium)
                        .foregroundColor(DS.textSecondary)
                        .textCase(.uppercase)
                    
                    TextField("e.g., Push Day, Leg Day", text: $newDayName)
                        .font(DS.Typography.bodyMedium)
                        .padding(DS.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous)
                                .fill(DS.card)
                                .stroke(DS.separator.opacity(0.5), lineWidth: 1)
                        )
                        .submitLabel(.done)
                        .onSubmit(addDay)
                        .accessibilityIdentifier("addDayTextField")
                }
                
                Spacer()
                
                Button("Add Workout Day", action: addDay)
                    .primaryStyle()
                    .disabled(newDayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("confirmAddDayButton")
            }
            .padding(DS.Spacing.xxl)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddDay = false
                        newDayName = ""
                    }
                    .foregroundColor(DS.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func editDaySheet(day: WorkoutDay) -> some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xxl) {
                VStack(spacing: DS.Spacing.lg) {
                    Text("Edit Workout Day")
                        .font(DS.Typography.title)
                        .foregroundColor(DS.text)
                    
                    Text("Update the name for this workout day")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Day Name")
                        .font(DS.Typography.captionMedium)
                        .foregroundColor(DS.textSecondary)
                        .textCase(.uppercase)
                    
                    TextField("Enter day name", text: $editingDayName)
                        .font(DS.Typography.bodyMedium)
                        .padding(DS.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous)
                                .fill(DS.card)
                                .stroke(DS.separator.opacity(0.5), lineWidth: 1)
                        )
                        .submitLabel(.done)
                        .onSubmit { saveEditedDay(day) }
                }
                
                Spacer()
                
                Button("Save Changes") { saveEditedDay(day) }
                    .primaryStyle()
                    .disabled(editingDayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(DS.Spacing.xxl)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        editingDay = nil
                        editingDayName = ""
                    }
                    .foregroundColor(DS.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            editingDayName = day.name ?? ""
        }
    }
    
    // MARK: - Actions
    
    private func addDay() {
        viewModel.createDay(name: newDayName)
        showingAddDay = false
        newDayName = ""
        Haptics.success()
    }
    
    private func saveEditedDay(_ day: WorkoutDay) {
        viewModel.renameDay(day, to: editingDayName)
        editingDay = nil
        editingDayName = ""
        Haptics.success()
    }
}

// MARK: - Workout Day Row

struct WorkoutDayRow: View {
    let day: WorkoutDay
    let exerciseCount: Int
    let isEditMode: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: DS.Spacing.lg) {
            // Day Icon
            Image(systemName: "dumbbell.fill")
                .font(.title2)
                .foregroundColor(isEditMode ? DS.textSecondary : DS.brand)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isEditMode ? DS.textSecondary.opacity(0.1) : DS.brand.opacity(0.1))
                )
            
            // Day Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(day.name ?? "Unknown Day")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.text)
                
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: "list.bullet")
                        .font(.caption)
                        .foregroundColor(DS.textSecondary)
                    
                    Text("\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.textSecondary)
                }
            }
            
            Spacer()
            
            if isEditMode {
                HStack(spacing: DS.Spacing.md) {
                    Button(action: {
                        onEdit()
                        Haptics.select()
                    }) {
                        Image(systemName: "pencil")
                            .font(.callout.weight(.medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(DS.brand))
                    }
                    .accessibilityLabel("Edit \(day.name ?? "day")")
                    
                    Button(action: {
                        onDelete()
                        Haptics.success()
                    }) {
                        Image(systemName: "trash")
                            .font(.callout.weight(.medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(DS.error))
                    }
                    .accessibilityLabel("Delete \(day.name ?? "day")")
                }
            } else {
                Image(systemName: "chevron.right")
                    .font(.callout.weight(.medium))
                    .foregroundColor(DS.textTertiary)
            }
        }
        .padding(DS.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Corner.lg, style: .continuous)
                .fill(isEditMode ? AnyShapeStyle(DS.card) : AnyShapeStyle(DS.cardGradient))
                .stroke(isEditMode ? DS.separator.opacity(0.3) : Color.clear, lineWidth: 1)
                .shadow(color: isEditMode ? Color.clear : DS.Shadow.card, radius: 2, y: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DS.Animation.quick, value: isPressed)
        .if(isEditMode) { view in
            view.onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {
                // Handle tap in edit mode
            }, onPressingChanged: { pressing in
                isPressed = pressing
            })
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue({
            let name = day.name ?? "Unknown Day"
            return "\(name), \(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"
        }())
    }
}

// MARK: - Preview

#Preview {
    WorkoutDaysListView()
        .environment(\.managedObjectContext, Database.preview.viewContext)
}