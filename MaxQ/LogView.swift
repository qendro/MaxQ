//
//  LogView.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import SwiftUI
import CoreData

/// Log screen displaying workout history in editable text format
struct LogView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: LogViewModel = LogViewModel(context: CoreDataManager.shared.viewContext)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isEditing {
                    editingToolbar
                }
                
                ScrollView {
                    if viewModel.logText.isEmpty {
                        emptyState
                    } else {
                        textEditor
                    }
                }
            }
            .navigationTitle("Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.isEditing {
                        Button("Edit") {
                            viewModel.isEditing = true
                        }
                        .font(DS.Typography.bodyMedium)
                        .foregroundColor(DS.brand)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .onAppear {
                viewModel.loadWorkoutLog()
            }
        }
    }
    
    private var editingToolbar: some View {
        HStack {
            Button("Cancel") {
                viewModel.discardChanges()
            }
            .foregroundColor(DS.brand)
            
            Spacer()
            
            Text("Editing Workout Log")
                .font(DS.Typography.captionMedium)
                .foregroundColor(DS.textSecondary)
            
            Spacer()
            
            Button("Done") {
                viewModel.saveChanges()
            }
            .foregroundColor(DS.brand)
            .fontWeight(.semibold)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.md)
        .background(DS.card)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(DS.separator),
            alignment: .bottom
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Workout Logs")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Complete some workouts to see your log history here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private var textEditor: some View {
        Group {
            if viewModel.isEditing {
                TextEditor(text: $viewModel.logText)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(2)
                    .padding()
                    .background(Color(.systemBackground))
            } else {
                Text(viewModel.logText)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .textSelection(.enabled)
                    .background(Color(.systemBackground))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let context = Database.preview.viewContext
    
    // Create sample data
    let program = Program(context: context)
    program.id = UUID()
    program.name = "Sample Program"
    
    let pushDay = WorkoutDay(context: context)
    pushDay.id = UUID()
    pushDay.name = "Push"
    pushDay.program = program
    
    let benchPress = Exercise(context: context)
    benchPress.id = UUID()
    benchPress.name = "Bench Press"
    benchPress.day = pushDay
    benchPress.order = 0
    
    let dbPress = Exercise(context: context)
    dbPress.id = UUID()
    dbPress.name = "DB Press"
    dbPress.day = pushDay
    dbPress.order = 1
    
    // Create sample logs
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    
    let log1 = ExerciseLog(context: context)
    log1.id = UUID()
    log1.exercise = benchPress
    log1.dateNormalizedToLocalMidnight = yesterday.normalizedToLocalMidnight
    log1.set1Weight = 185
    log1.set1Reps = 3
    log1.set2Weight = 225
    log1.set2Reps = 8
    log1.set3Weight = 225
    log1.set3Reps = 8
    
    let log2 = ExerciseLog(context: context)
    log2.id = UUID()
    log2.exercise = dbPress
    log2.dateNormalizedToLocalMidnight = yesterday.normalizedToLocalMidnight
    log2.set1Weight = 50
    log2.set1Reps = 10
    log2.set2Weight = 60
    log2.set2Reps = 10
    log2.set3Weight = 70
    log2.set3Reps = 10
    
    return LogView()
        .environment(\.managedObjectContext, context)
}
