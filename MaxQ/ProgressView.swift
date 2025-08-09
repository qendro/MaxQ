import SwiftUI

struct ProgressViewScreen: View {
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("This Week's Volume")) {
                    HStack { Image(systemName: "chart.bar.fill"); Text("\(Int(viewModel.weeklyVolume)) total") }
                        .font(.title3.weight(.semibold))
                }
                Section(header: Text("Top PRs")) {
                    if viewModel.topPRs.isEmpty { Text("No PRs yet").foregroundColor(.secondary) }
                    ForEach(Array(viewModel.topPRs.enumerated()), id: \.offset) { _, pr in
                        HStack { Text(pr.exercise); Spacer(); Text("\(Int(pr.weight))×\(pr.reps)") }
                    }
                }
                Section(header: Text("Streak")) {
                    HStack { Image(systemName: "flame.fill"); Text("\(viewModel.streakDays) days") }
                        .font(.title3.weight(.semibold))
                }
            }
            .navigationTitle("Progress")
            .onAppear { viewModel.refresh() }
        }
    }
}


