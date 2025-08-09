//
//  UndoManager.swift
//  MaxQ
//
//  Created by Kiro on 8/8/25.
//

import Foundation
import SwiftUI

/// Reusable undo manager for 5-second undo functionality
/// Shared between HomeViewModel and DayDetailViewModel
@MainActor
class UndoManager: ObservableObject {
    @Published var undoAction: UndoAction?
    private var undoTimer: Timer?
    
    /// Represents an undo action with its associated data
    struct UndoAction {
        let message: String
        let action: () -> Void
        let timeRemaining: TimeInterval
        
        init(message: String, action: @escaping () -> Void) {
            self.message = message
            self.action = action
            self.timeRemaining = 5.0
        }
    }
    
    /// Shows an undo action with a 5-second timer
    /// - Parameters:
    ///   - message: The message to display to the user
    ///   - undoAction: The action to perform if undo is triggered
    func showUndo(message: String, undoAction: @escaping () -> Void) {
        // Cancel any existing undo timer
        cancelUndo()
        
        // Set up the new undo action
        self.undoAction = UndoAction(message: message, action: undoAction)
        
        // Start the 5-second timer
        undoTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.hideUndo()
        }
    }
    
    /// Performs the undo action and hides the undo UI
    func performUndo() {
        undoAction?.action()
        hideUndo()
    }
    
    /// Cancels the current undo action without performing it
    func cancelUndo() {
        undoTimer?.invalidate()
        undoTimer = nil
        hideUndo()
    }
    
    /// Hides the undo UI
    private func hideUndo() {
        undoAction = nil
    }
    
    deinit {
        undoTimer?.invalidate()
    }
}

/// SwiftUI view modifier for displaying undo actions
struct UndoViewModifier: ViewModifier {
    @ObservedObject var undoManager: UndoManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let undoAction = undoManager.undoAction {
                    UndoToastView(
                        message: undoAction.message,
                        onUndo: undoManager.performUndo,
                        onDismiss: undoManager.cancelUndo
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: undoManager.undoAction != nil)
                }
            }
    }
}

/// Toast view for displaying undo actions
struct UndoToastView: View {
    let message: String
    let onUndo: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button("Undo") {
                onUndo()
            }
            .font(.body.weight(.medium))
            .foregroundColor(.accentColor)
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

/// Extension to easily apply undo functionality to any view
extension View {
    func undoSupport(_ undoManager: UndoManager) -> some View {
        modifier(UndoViewModifier(undoManager: undoManager))
    }
}