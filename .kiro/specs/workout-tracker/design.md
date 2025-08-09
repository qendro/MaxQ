# Design Document

## Overview

The iOS Workout Tracker is a native SwiftUI application that provides a minimalist, Excel-like interface for tracking workout data. The app follows **MVVM architecture with Core Data persistence** for local storage. It targets iOS 17+ devices and includes a **Program Library** with multiple preloaded workout programs and a **Progress Tracking** view. Authentication and cloud sync are deferred to Phase 2.

The design emphasizes speed and simplicity, allowing users to quickly input and view workout data with minimal navigation overhead. The UI supports both **light and dark mode** with SwiftUI and iOS system colors for optimal user experience across all device sizes.

## Architecture

### MVVM Pattern
- **Models**: Core Data entities (Program, WorkoutDay, Exercise, ExerciseLog)
- **ViewModels**: Business logic and data transformation layer
- **Views**: SwiftUI views with declarative UI

### Core Components
- **CoreDataManager**: Singleton managing Core Data stack with lightweight migration using NSPersistentContainer
- **SeedDataManager**: Handles first-launch data seeding with version control
- **WorkoutRepository**: Data access layer abstracting Core Data operations
- **ProgressManager**: Computes progress metrics (Weekly Volume, PRs, Streak)
- **AuthManager**: *(Phase 2)* Will handle Sign in with Apple and authentication state
- **CloudKit Integration**: *(Phase 2)* Will provide cross-device sync capabilities

## Components and Interfaces

### Core Data Stack

#### Entities

**Program**
```swift
@Entity Program {
    @Attribute var id: UUID
    @Attribute var name: String
    @Attribute var isPreloaded: Bool
    @Attribute var createdAt: Date
    @Relationship(deleteRule: .cascade) var days: [WorkoutDay]
}
```

**WorkoutDay**
```swift
@Entity WorkoutDay {
    @Attribute var id: UUID
    @Attribute var name: String
    @Attribute var order: Int16
    @Attribute var createdAt: Date
    @Attribute var isActive: Bool = true
    @Relationship var program: Program
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]
}
```

**Exercise**
```swift
@Entity Exercise {
    @Attribute var id: UUID
    @Attribute var name: String
    @Attribute var order: Int16
    @Attribute var isBaseline: Bool
    
    // Recommended sets template
    @Attribute var recSet1Weight: Double?
    @Attribute var recSet1Reps: Int16?
    @Attribute var recSet2Weight: Double?
    @Attribute var recSet2Reps: Int16?
    @Attribute var recSet3Weight: Double?
    @Attribute var recSet3Reps: Int16?
    @Attribute var recSet4Weight: Double?
    @Attribute var recSet4Reps: Int16?
    
    // Future compatibility
    @Attribute var setsJSON: String?
    
    @Relationship var day: WorkoutDay
    @Relationship(deleteRule: .cascade) var logs: [ExerciseLog]
}
```

**ExerciseLog**
```swift
@Entity ExerciseLog {
    @Attribute var id: UUID
    @Attribute var dateNormalizedToLocalMidnight: Date
    
    // Actual performed sets
    @Attribute var set1Weight: Double?
    @Attribute var set1Reps: Int16?
    @Attribute var set2Weight: Double?
    @Attribute var set2Reps: Int16?
    @Attribute var set3Weight: Double?
    @Attribute var set3Reps: Int16?
    @Attribute var set4Weight: Double?
    @Attribute var set4Reps: Int16?
    
    // Future compatibility
    @Attribute var setsJSON: String?
    
    @Relationship var exercise: Exercise
}
```

**Unique Constraint**: (exerciseId, dateNormalizedToLocalMidnight)  
**Units**: Default to lbs for MVP (future kg toggle possible)

### View Models

#### HomeViewModel
- Manages workout days list for active program
- Shows only active days (isActive = true)
- Handles day reordering, adding, removing with soft delete (isActive = false) and 5-second undo
- Provides edit mode state

#### DayDetailViewModel
- Manages exercise table data (baseline and user-added exercises)
- Handles in-place editing logic with numeric keypad and Return key navigation
- Autofills today's values from recommended sets when first editing
- Manages exercise addition (isBaseline = false) and deletion with 5-second undo
- Validates inputs: weight ≥ 0 (decimal), reps ≥ 0 (integer)

#### ExerciseDetailViewModel
- Manages individual exercise data
- Handles today's editable sets with autofill
- Fetches and formats exactly 3 most recent distinct log dates (excluding today unless it has a log)
- Displays historical entries in .secondaryLabel (grayed out)
- Provides "Update Recommended from Today" functionality

#### OnboardingViewModel
- Handles initial program selection (no authentication in MVP)
- Saves chosen program as active

#### SettingsViewModel
- Allows switching active program
- (Optional) Exports logs to CSV
- *(Phase 2)* Will show account status and authentication options

#### ProgressViewModel
- Calculates:
  - **Weekly Volume** = Σ(weight × reps)
  - **Top PR** per exercise
  - **Streak** = consecutive days with ≥1 set logged
- Data is derived from logs (no extra schema)

### Repository Layer

#### WorkoutRepository
```swift
protocol WorkoutRepositoryProtocol {
    func fetchActiveDays(for program: Program) -> [WorkoutDay]
    func createDay(name: String, program: Program) -> WorkoutDay
    func updateDay(_ day: WorkoutDay)
    func softDeleteDay(_ day: WorkoutDay)
    
    func fetchExercisesForDay(_ day: WorkoutDay) -> [Exercise]
    func createExercise(name: String, day: WorkoutDay) -> Exercise
    func updateExercise(_ exercise: Exercise)
    func deleteExercise(_ exercise: Exercise)
    
    func fetchTodaysLog(for exercise: Exercise) -> ExerciseLog?
    func createOrUpdateTodaysLog(for exercise: Exercise, sets: [(weight: Double?, reps: Int16?)]) -> ExerciseLog
    func fetchRecentLogs(for exercise: Exercise, limit: Int) -> [ExerciseLog]
}
```

## Data Models

### Set Data Structure
```swift
struct SetData {
    let weight: Double?
    let reps: Int16?
    
    var displayString: String {
        guard let weight = weight, let reps = reps else { return "" }
        return "\(Int(weight))×\(reps)"
    }
}
```

### Historical Entry Model
```swift
struct HistoricalEntry {
    let date: Date
    let sets: [SetData]
    
    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dateString = formatter.string(from: date)
        let setsString = sets.map { $0.displayString }.joined(separator: " | ")
        return "\(dateString): \(setsString)"
    }
}
```

## Phase 2 Features (Deferred)

### AuthManager *(Phase 2)*
- Will integrate Sign in with Apple
- Will expose `isSignedIn` and `userId`
- Will trigger CloudKit sync on sign-in

### CloudKit Integration *(Phase 2)*
- Will use NSPersistentCloudKitContainer
- Conflict policy: last-write-wins
- Local-first edits with sync indicator in UI

## UI/UX Design Specifications

### SwiftUI Design System
Create a sleek, modern SwiftUI interface that works flawlessly in both light and dark mode using iOS system colors and typography (SF Pro Text/Display) with Dynamic Type support. Follow Apple's Human Interface Guidelines for spacing, padding, and component sizing, ensuring 44pt minimum tap targets and WCAG AA contrast. Use native SwiftUI elements (List, Button, TextField, NavigationStack) with clean visual hierarchy, subtle separators instead of heavy borders, and responsive layouts for iPhone SE through Pro Max in portrait and landscape.

- **Typography**: SF Pro Text/Display with Dynamic Type support
- **Colors**: iOS system colors (.systemBackground, .label, .secondaryLabel) for automatic light/dark mode adaptation
- **Spacing**: iOS standard spacing grid (4pt, 8pt, 16pt, 24pt)
- **Components**: SwiftUI native components (List, Button, TextField, NavigationStack) following Apple's Human Interface Guidelines

### Device Support
- **Screen Sizes**: iPhone SE (375pt) through iPhone Pro Max (428pt)
- **Orientations**: Portrait and landscape support with responsive layouts
- **Accessibility**: Dynamic Type, VoiceOver, 44pt minimum tap targets

### Screens

#### Onboarding
- Choose active program from seeded list (no authentication in MVP)

#### Home
- Vertical list of workout days for active program
- SwiftUI List with iOS standard row styling

#### Day Detail
- Excel-like table with SwiftUI components using proper column and row alignment
- Fixed column headers: Exercise | Set 1 (W×R) | Set 2 (W×R) | Set 3 (W×R) | Set 4 (W×R)
- Columns maintain consistent width ratios across iPhone SE through Pro Max
- Row alignment ensures data readability on small devices with proper text truncation
- Today's plan with in-place editing using numeric keypad
- Historical data in .secondaryLabel color

#### Exercise Detail
- One-line Today's Plan: "Set1 W×R | Set2 W×R | Set3 W×R | Set4 W×R"
- Edit today's sets with numeric keypad
- View last 3 logs in grayed out format

#### Progress
- 3 cards: Weekly Volume, Top PRs, Streak
- Card design: rounded corners (12pt radius), subtle shadows (.shadow(radius: 2)), proper spacing between cards
- Each card uses SF Symbols for icons (chart.bar.fill, trophy.fill, flame.fill)
- SwiftUI cards with iOS standard styling and proper content hierarchy
- Cards adapt responsively in grid layout for different screen sizes

#### Settings
- Program switcher
- (Optional) CSV export
- *(Phase 2)* Account status and authentication options

## Data Seeding Strategy

### Program Seeding
Seed 3 programs:
1. **Classic Push/Pull/Arms/Full Body**
2. **Full Body Beginner**
3. **Arms Focus**

Each program has its own WorkoutDays and Exercises (isBaseline = true)  
No ExerciseLogs seeded

### Version Control
- Uses seedVersion (Int) in UserDefaults
- Prevents data overwrites on app updates
- Allows incremental seeding of new programs

## Testing Strategy

### Unit Tests
- Core Data entity tests
- Repository CRUD operations
- ViewModel business logic
- Progress calculations

### UI Tests
- Navigation flows
- In-place editing
- Authentication flow
- Program switching
- Data persistence

### Integration Tests
- Local data persistence
- Program switching
- Multi-program data isolation
- *(Phase 2)* CloudKit sync, authentication, cross-device consistency

This design keeps the MVP simple and focused on local functionality while remaining future-proof. Multi-program support and progress tracking are fully implemented for local use, while authentication and cloud sync are architected but deferred to Phase 2, providing a solid foundation for the iOS workout tracker.