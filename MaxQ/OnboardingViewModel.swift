import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var programs: [Program] = []
    @Published var selectedProgramId: UUID?
    private let repository: WorkoutRepositoryProtocol
    
    init(repository: WorkoutRepositoryProtocol = WorkoutRepository.shared) {
        self.repository = repository
        loadPrograms()
    }
    
    func loadPrograms() {
        programs = repository.fetchPrograms()
        if let classic = programs.first(where: { ($0.name ?? "").localizedCaseInsensitiveContains("classic") }) {
            selectedProgramId = classic.id
        } else {
            selectedProgramId = programs.first?.id
        }
    }
    
    func confirmSelection() {
        guard let id = selectedProgramId else { return }
        UserDefaults.standard.set(id.uuidString, forKey: "activeProgram")
    }
}


