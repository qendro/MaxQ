# Requirements Document

## Introduction

This document outlines the requirements for a native iOS workout tracker application with an Excel-like table interface for fast viewing and in-place editing of sets, reps, and weights. The interface shall follow a sleek, modern aesthetic using SwiftUI with iOS system colors, SF Pro typography, and Apple's Human Interface Guidelines. The app shall fully support both light and dark mode, adapting color palettes for optimal readability and WCAG AA contrast. All UI elements shall be responsive across iPhone SE through iPhone Pro Max in both portrait and landscape orientations. The app features a simple, minimalist design focused on quick data entry and viewing workout history. It uses Core Data (local storage only) in the MVP; Cloud sync and authentication are deferred to Phase 2. Units default to lbs (future kg toggle possible).

## Requirements

### Requirement 1

**User Story:** As a fitness enthusiast, I want to see a vertical list of my workout days when I open the app, so that I can quickly navigate to today's workout.

#### Acceptance Criteria

1. WHEN the app launches THEN the system SHALL display a vertical list of all active workout days in their defined order (primary sort: order, tiebreaker: createdAt)
2. WHEN displaying each day row THEN the system SHALL show the day name and a subtitle with the count of exercises
3. WHEN a user taps on a day row THEN the system SHALL navigate to the Day Detail screen for that workout day
4. WHEN the app launches for the first time THEN the system SHALL display the days for the active program (see Requirement 12 seeding)

### Requirement 2

**User Story:** As a user, I want to manage my workout days by renaming, removing, reordering, and adding new days, so that I can customize my workout plan.

#### Acceptance Criteria

1. WHEN a user accesses the edit days function THEN the system SHALL allow renaming any workout day
2. WHEN a user removes a workout day THEN the system SHALL set isActive to false without deleting the data
3. WHEN a user reorders workout days THEN the system SHALL update the order field and persist the new arrangement
4. WHEN a user adds a new workout day THEN the system SHALL create a new WorkoutDay with an empty exercises list
5. WHEN a workout day is removed THEN the system SHALL hide it from the home screen without orphaning associated exercises
6. WHEN deleting a day THEN the system SHALL present a 5-second Undo option
7. WHEN ordering workout days THEN the system SHALL use order as primary sort with createdAt as tiebreaker

### Requirement 3

**User Story:** As a user, I want to view and edit my workout data in an Excel-like table format, so that I can quickly input and modify my sets, reps, and weights.

#### Acceptance Criteria

1. WHEN viewing the Day Detail screen THEN the system SHALL display an Excel-like table with columns: Exercise | Set 1 (W×R) | Set 2 (W×R) | Set 3 (W×R) | Set 4 (W×R)
2. WHEN the Day Detail screen loads THEN the system SHALL autofill today's values from each exercise's recommended sets
3. WHEN a user taps any weight or reps cell THEN the system SHALL enable in-place editing for that cell
4. WHEN a user completes an edit THEN the system SHALL immediately save the data to today's ExerciseLog
5. WHEN displaying the table THEN the system SHALL show each exercise as a row with today's editable values
6. WHEN editing today's values THEN the system SHALL NOT change the recommended template unless the user selects "Update Recommended from Today"
7. WHEN in-place editing THEN the system SHALL use a numeric keypad with Return key moving to the next cell and the last cell committing and dismissing the keyboard
8. WHEN validating inputs THEN the system SHALL ensure weight ≥ 0 (decimal allowed) and reps ≥ 0 (integer)

### Requirement 4

**User Story:** As a user, I want to add and manage exercises within each workout day, so that I can customize my routine beyond the baseline exercises.

#### Acceptance Criteria

1. WHEN a user adds an exercise to a day THEN the system SHALL create a new Exercise with isBaseline set to false
2. WHEN a user edits an exercise THEN the system SHALL allow modification of the exercise name and order
3. WHEN a user deletes an exercise THEN the system SHALL remove it from the workout day
4. WHEN an exercise is added THEN the system SHALL immediately display it in the table as editable
5. WHEN managing exercises THEN the system SHALL maintain the distinction between baseline and user-added exercises
6. WHEN deleting an exercise THEN the system SHALL present a 5-second Undo option

### Requirement 5

**User Story:** As a user, I want to view detailed exercise information including today's plan and historical data, so that I can track my progress over time.

#### Acceptance Criteria

1. WHEN a user taps an exercise row THEN the system SHALL navigate to the Exercise Detail screen
2. WHEN the Exercise Detail screen loads THEN the system SHALL display the exercise name (editable) and day name caption
3. WHEN viewing today's section THEN the system SHALL show Today's Plan on a single horizontal line as four editable tokens 'Set1 W×R | Set2 W×R | Set3 W×R | Set4 W×R', prefilled from recommended sets
4. WHEN viewing history THEN the system SHALL display exactly 3 most recent distinct log dates for the exercise, excluding today unless a log exists for today
5. WHEN no history exists THEN the system SHALL display the placeholder "No past logs yet"
6. WHEN displaying historical entries THEN the system SHALL format each as "Week N (MM/DD/YY): s1W×s1R | s2W×s2R | s3W×s3R | s4W×s4R"
7. WHEN showing historical rows THEN the system SHALL use system secondary label color to maintain WCAG AA contrast and match today's font size

### Requirement 6

**User Story:** As a user, I want the app to persist my workout data locally using Core Data, so that my information is saved between app sessions.

#### Acceptance Criteria

1. WHEN the app uses Core Data THEN the system SHALL implement WorkoutDay, Exercise, and ExerciseLog entities with specified relationships
2. WHEN saving today's edits THEN the system SHALL create or update a single ExerciseLog for each (exercise, date) combination
3. WHEN the app relaunches THEN the system SHALL restore all previously saved workout data
4. WHEN implementing Core Data THEN the system SHALL enable lightweight migration for future schema changes
5. WHEN storing exercise logs THEN the system SHALL maintain data for historical viewing (minimum 3 weeks)
6. WHEN enforcing data integrity THEN the system SHALL implement a uniqueness constraint on ExerciseLog(exerciseId, dateNormalizedToLocalMidnight) with date stored normalized to local midnight
7. WHEN designing entities THEN the system SHALL include a setsJSON field in addition to the fixed four set fields for forward compatibility with variable set counts

### Requirement 7

**User Story:** As a user, I want the app to have a clean, minimalist interface optimized for light and dark mode, so that I can focus on my workout without distractions.

#### Acceptance Criteria

1. WHEN designing the interface THEN the system SHALL use SwiftUI with iOS system typography (SF Pro) and generous row heights following Apple's Human Interface Guidelines
2. WHEN navigating the app THEN the system SHALL require no more than two taps to switch between days or reach exercise details
3. WHEN displaying data THEN the system SHALL use iOS system separators (.separator) and avoid heavy borders
4. WHEN showing historical data THEN the system SHALL use iOS system secondary label color (.secondaryLabel) to maintain WCAG AA contrast
5. WHEN implementing the UI THEN the system SHALL fully support both light and dark mode using iOS system colors that automatically adapt and maintain WCAG AA contrast in each mode
6. WHEN displaying weights THEN the system SHALL default to lbs units in MVP (future kg toggle possible)
7. WHEN displaying data in dark mode THEN the system SHALL ensure backgrounds (.systemBackground), borders, and text colors (.label, .secondaryLabel) automatically adjust using iOS system colors
8. WHEN styling interactive elements THEN the system SHALL provide clear affordances using iOS standard tap feedback and focus states while maintaining the minimalist design language

### Requirement 8

**User Story:** As a user with accessibility needs, I want the app to support accessibility features, so that I can use the app regardless of my abilities.

#### Acceptance Criteria

1. WHEN implementing accessibility THEN the system SHALL support Dynamic Type sizing (minimum Large size)
2. WHEN designing interactive elements THEN the system SHALL ensure all tap targets are at least 44pt
3. WHEN using VoiceOver THEN the system SHALL provide appropriate labels for day names, exercise names, and each set cell
4. WHEN announcing set cells THEN the system SHALL use descriptive labels like "Set 1 weight" and "Set 1 reps"
5. WHEN implementing accessibility THEN the system SHALL ensure all critical functionality is accessible via assistive technologies

### Requirement 9

**User Story:** As a new user, I want the app to come with preloaded workout plans and sample data, so that I can start using the app immediately without setup.

#### Acceptance Criteria

1. WHEN the app launches for the first time THEN the system SHALL create 5 workout days within the Classic program with baseline exercises
2. WHEN seeding Push day THEN the system SHALL include: Bench Press, Incline Press, Cable Fly, Overhead Press, Triceps Pushdowns
3. WHEN seeding baseline exercises THEN the system SHALL set recommended sets with sample weight and rep values
4. WHEN seeding data THEN the system SHALL NOT create historical ExerciseLog entries
5. WHEN checking for first launch THEN the system SHALL be guarded by seedVersion (Int) in UserDefaults with seeding running only if stored version is less than current
6. WHEN seeding exercises THEN the system SHALL mark baseline exercises with isBaseline set to true

**Note:** Additional program seeding is defined in Requirement 12.

### Requirement 10

**User Story:** As a user, I want to sign in so my workouts sync across devices.

**Status:** Deferred – Phase 2 (disabled in MVP)

#### Acceptance Criteria

1. WHEN the app launches for the first time THEN the system SHALL provide Sign in with Apple option
2. WHEN a user successfully signs in THEN the system SHALL enable CloudKit sync for the user's data
3. WHEN the app functions offline THEN the system SHALL sync when network becomes available
4. WHEN a user signs out THEN the system SHALL keep local data but pause syncing
5. WHEN viewing Settings THEN the system SHALL show current authentication state

### Requirement 11

**User Story:** As a user, I want my workouts to sync securely across devices.

**Status:** Deferred – Phase 2 (disabled in MVP)

#### Acceptance Criteria

1. WHEN implementing sync THEN the system SHALL use NSPersistentCloudKitContainer for Core Data sync (no custom servers)
2. WHEN syncing entities THEN the system SHALL include Program, WorkoutDay, Exercise, and ExerciseLog
3. WHEN resolving conflicts THEN the system SHALL use last-write-wins for MVP
4. WHEN syncing THEN the system SHALL show a subtle non-blocking sync indicator/state (e.g., syncing/idle)
5. WHEN editing data THEN the system SHALL provide local-first behavior with immediate availability offline and later sync

### Requirement 12

**User Story:** As a user, I want to pick from multiple preloaded programs and switch later.

#### Acceptance Criteria

1. WHEN implementing programs THEN the system SHALL add a Program entity where each WorkoutDay belongs to exactly one Program
2. WHEN seeding programs THEN the system SHALL create three programs: Classic Push/Pull/Arms/Full Body, Full Body Beginner, Arms Focus
3. WHEN onboarding THEN the system SHALL prompt the user to choose an active program (default: Classic)
4. WHEN viewing Home screen THEN the system SHALL list only the active program's days
5. WHEN accessing Settings THEN the system SHALL allow users to switch the active program
6. WHEN fetching days for Home THEN the system SHALL filter by the active program and sort by order (primary) then createdAt (tiebreaker)
7. WHEN implementing program customization THEN the system MAY allow duplicating a preloaded program (optional, not required for MVP)

### Requirement 13

**User Story:** As a user, I want simple progress signals to stay motivated.

#### Acceptance Criteria

1. WHEN computing progress THEN the system SHALL calculate Weekly Volume (sum of weight × reps) per exercise and per week
2. WHEN tracking records THEN the system SHALL track PR set per exercise (max by weight, tie-break by reps)
3. WHEN tracking consistency THEN the system SHALL track Streak: consecutive days with ≥1 logged set
4. WHEN displaying progress THEN the system SHALL add a Progress screen with three cards: This Week's Volume, Top PRs, Streak
5. WHEN deriving progress THEN the system SHALL use existing logs with no extra schema required
6. WHEN styling progress data THEN the system SHALL use .secondaryLabel only for de-emphasis while maintaining WCAG AA contrast

### Requirement 14

**User Story:** As a user, I want basic settings to manage my experience.

#### Acceptance Criteria

1. WHEN viewing Settings THEN the system SHALL show account status (Signed in with Apple / not signed in)
2. WHEN managing programs THEN the system SHALL provide a program switcher to select the active program
3. WHEN configuring units THEN the system SHALL display units (lbs; kg toggle may be disabled for MVP)
4. WHEN exporting data THEN the system MAY provide export logs to CSV via share sheet (optional)
5. WHEN viewing app info THEN the system SHALL show app version and privacy information

### Requirement 15

**User Story:** As a user, I want a consistent visual theme across all screens so the experience feels polished and unified.

#### Acceptance Criteria

1. WHEN designing screens THEN the system SHALL use a shared SwiftUI design system with consistent SF Pro typography, iOS standard spacing (8pt, 16pt, 24pt grid), and iOS system color tokens for automatic light and dark mode adaptation
2. WHEN defining colors THEN the system SHALL use iOS system colors (.systemBackground, .label, .secondaryLabel, .systemBlue, etc.) that automatically adapt between light and dark modes
3. WHEN rendering tables THEN the system SHALL use SwiftUI List with iOS standard row separators (.separator) in both modes, avoiding custom harsh borders
4. WHEN showing secondary data (e.g., historical sets) THEN the system SHALL use iOS system secondary label color (.secondaryLabel) for automatic theme adaptation
5. WHEN updating UI in dark mode THEN the system SHALL test in both standard and high contrast accessibility settings using iOS system color variants

### Requirement 16

**User Story:** As a user, I want the app to follow Apple's design standards and work seamlessly across all iPhone sizes and orientations, so that it feels native and familiar.

#### Acceptance Criteria

1. WHEN implementing buttons THEN the system SHALL use SwiftUI Button with iOS standard padding (16pt horizontal, 12pt vertical), corner radius (8pt for primary, 6pt for secondary), and haptic feedback following Apple's Human Interface Guidelines
2. WHEN creating input fields THEN the system SHALL use SwiftUI TextField with iOS standard styling, appropriate keyboard types, and focus states that follow Apple's design patterns
3. WHEN designing table cells THEN the system SHALL use SwiftUI List rows with minimum 44pt tap targets, iOS standard cell padding (16pt leading/trailing, 12pt top/bottom), and proper content hierarchy
4. WHEN implementing animations THEN the system SHALL use subtle SwiftUI animations with iOS standard easing curves (.easeInOut, .spring) for cell focus transitions, save confirmations, and navigation
5. WHEN supporting device sizes THEN the system SHALL ensure all screens adapt responsively from iPhone SE (375pt width) through iPhone Pro Max (428pt width) in both portrait and landscape orientations without layout breaking
6. WHEN defining the design system THEN the system SHALL create a centralized SwiftUI style guide with reusable components for typography (SF Pro Text/Display), spacing tokens (4pt, 8pt, 16pt, 24pt), colors (iOS system colors), and icons (SF Symbols) used consistently throughout the app
7. WHEN handling orientation changes THEN the system SHALL maintain usable layouts in landscape mode with appropriate content reflow and navigation patterns
8. WHEN providing visual feedback THEN the system SHALL use iOS standard loading indicators, progress views, and state changes that integrate seamlessly with the system appearance

## Data Model Extensions

### Program Entity
- **Attributes**: id (UUID), name (String), isPreloaded (Bool), createdAt (Date)
- **Relationships**: days (to-many WorkoutDay)

### WorkoutDay Entity Updates
- **Additional Relationship**: program (to-one Program) - each day belongs to exactly one Program

### CloudKit Compatibility
- All entities include CloudKit-safe attributes
- Maintain setsJSON field for future flexibility
- Preserve uniqueness constraint on ExerciseLog(exerciseId, dateNormalizedToLocalMidnight)