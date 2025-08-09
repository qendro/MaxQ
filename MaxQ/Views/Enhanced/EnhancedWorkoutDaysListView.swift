//
//  EnhancedWorkoutDaysListView.swift
//  MaxQ
//
//  Enhanced home screen with premium visual design
//

import SwiftUI

struct EnhancedWorkoutDaysListView: View {
    @Environment(\.editMode) private var editMode
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddDay = false
    @State private var newDayName = ""
    @State private var editingDay: WorkoutDay?
    @State private var editingDayName = ""
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                DS.bg.ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingState
                } else if viewModel.workoutDays.isEmpty {
                    enhancedEmptyState
                } else {
                    enhancedWorkoutDaysList
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
                    .iconStyle(size: 32)
                    .accessibilityIdentifier("addDayButton")
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showingAddDay) {
                enhancedAddDaySheet
            }
            .sheet(item: $editingDay) { day in
                enhancedEditDaySheet(day: day)
            }
            .onAppear {
                viewModel.fetchActiveDays()
            }
        }
        .dynamicTypeSize(.large ... .accessibility3)
    }
    
    // MARK: - Enhanced Views
    
    private var loadingState: some View {
        VStack(spacing: DS.Spacing.lg) {
            LoadingDots()
            Text("Loading workout days...")
                .font(DS.Typography.body)
                .foregroundColor(DS.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var enhancedEmptyState: some View {
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
    
    private var enhancedWorkoutDaysList: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(viewModel.workoutDays, id: \.id) { day in
                    EnhancedWorkoutDayCard(
                        day: day,
                        exerciseCount: viewModel.getExerciseCount(for: day),
                        isEditMode: viewModel.isEditMode,
                        namespace: animationNamespace,
                        onEdit: { 
                            editingDay = day
                            editingDayName = day.name ?? ""
                            Haptics.select()
                        },
                        onDelete: { 
                            withAnimation(DS.Animation.smooth) {
                                viewModel.deleteDay(day)
                            }
                            Haptics.success()
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                // Add Exercise Button (inline)
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
    
    private var enhancedAddDaySheet: some View {
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
    
    private func enhancedEditDaySheet(day: WorkoutDay) -> some View {
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

// MARK: - Enhanced Workout Day Card

struct EnhancedWorkoutDayCard: View {
    let day: WorkoutDay
    let exerciseCount: Int
    let isEditMode: Bool
    let namespace: Namespace.ID
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Group {
            if isEditMode {
                editModeContent
            } else {
                NavigationLink(destination: DayDetailView(day: day)) {
                    cardContent
                }
                .buttonStyle(.plain)
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DS.Animation.quick, value: isPressed)
        .onLongPressGesture(minimumDuration: 0) {
            // Empty perform - just for the pressing animation
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
    
    private var cardContent: some View {
        HStack(spacing: DS.Spacing.lg) {
            // Day Icon
            VStack {
                Image(systemName: "dumbbell.fill")
                    .font(.title2)
                    .foregroundColor(DS.brand)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(DS.brand.opacity(0.1))
                    )
            }
            
            // Day Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(day.name ?? "Unknown Day")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.text)
                    .matchedGeometryEffect(id: "\(day.objectID)-title", in: namespace)
                
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
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.callout.weight(.medium))
                .foregroundColor(DS.textTertiary)
        }
        .padding(DS.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Corner.lg, style: .continuous)
                .fill(DS.cardGradient)
                .shadow(color: DS.Shadow.card, radius: 2, y: 1)
        )
    }
    
    private var editModeContent: some View {
        HStack(spacing: DS.Spacing.lg) {
            // Day Icon (dimmed in edit mode)
            Image(systemName: "dumbbell.fill")
                .font(.title2)
                .foregroundColor(DS.textSecondary)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(DS.textSecondary.opacity(0.1))
                )
            
            // Day Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(day.name ?? "Unknown Day")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.text)
                
                Text("\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.textSecondary)
            }
            
            Spacer()
            
            // Edit Actions
            HStack(spacing: DS.Spacing.md) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.callout.weight(.medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(DS.brand)
                        )
                }
                .accessibilityLabel("Edit \(day.name ?? "day")")
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.callout.weight(.medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(DS.error)
                        )
                }
                .accessibilityLabel("Delete \(day.name ?? "day")")
            }
        }
        .padding(DS.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Corner.lg, style: .continuous)
                .fill(DS.card)
                .stroke(DS.separator.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    EnhancedWorkoutDaysListView()
        .environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
