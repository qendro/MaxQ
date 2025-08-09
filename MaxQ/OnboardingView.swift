import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var didComplete: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Choose Your Program")) {
                    Picker("Program", selection: Binding(get: {
                        viewModel.selectedProgramId ?? viewModel.programs.first?.id
                    }, set: { viewModel.selectedProgramId = $0 })) {
                        ForEach(viewModel.programs, id: \.id) { program in
                            Text(program.name ?? "Program").tag(program.id)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                Section(footer: Text("You can change this later in Settings.")) { EmptyView() }
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Continue") {
                        viewModel.confirmSelection()
                        // Dismiss the onboarding full-screen cover
                        didComplete = false
                    }
                    .disabled(viewModel.selectedProgramId == nil)
                }
            }
        }
    }
}


