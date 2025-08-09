# Implementation Plan

- [x] 1. Set up project structure and Core Data stack
  - Create new iOS project with SwiftUI and Core Data
  - Configure minimum iOS 17+ deployment target
  - Set up Core Data model with WorkoutDay, Exercise, and ExerciseLog entities
  - Implement lightweight migration configuration
  - Create CoreDataManager singleton with persistent container
  - _Requirements: 6.1, 6.4_

- [x] 2. Implement Core Data entities and relationships
  - Define WorkoutDay entity with id, name, order, createdAt, isActive attributes
  - Define Exercise entity with id, name, order, isBaseline, recommended sets, and setsJSON attributes
  - Define ExerciseLog entity with id, dateNormalizedToLocalMidnight, set data, and setsJSON attributes
  - Configure entity relationships and cascade delete rules
  - Implement uniqueness constraint on ExerciseLog(exerciseId, dateNormalizedToLocalMidnight)
  - _Requirements: 6.1, 6.6, 6.7_

- [x] 3. Create repository layer and data access
  - Implement WorkoutRepository protocol with all CRUD operations
  - Create concrete WorkoutRepository implementation using Core Data
  - Implement fetchActiveDays() method with proper sorting (order, then createdAt)
  - Implement soft delete functionality for workout days (isActive = false)
  - Implement exercise management methods with baseline flag handling
  - Implement ExerciseLog creation and retrieval with date normalization
  - _Requirements: 6.1, 6.2, 6.3, 2.2, 2.7_

- [x] 4. Implement data models and validation
  - Create SetData struct with weight/reps and display formatting
  - Create ExerciseDisplayModel for UI representation
  - Create HistoricalEntry model with date formatting and empty placeholder
  - Implement WorkoutError enum with localized error descriptions
  - Create input validation functions for weight ≥ 0 (decimal) and reps ≥ 0 (integer)
  - _Requirements: 3.8, 4.2_

- [x] 5. Create seed data management system
  - Implement SeedVersion enum with integer-based version comparison
  - Create SeedData struct with preloaded multi-program data (Classic, Full Body Beginner, Arms Focus)
  - Implement sample recommended sets for baseline exercises
  - Create SeedDataManager to handle first-launch seeding with version guard
  - Ensure all seeded exercises are marked with isBaseline = true
  - Verify no historical ExerciseLog entries are created during seeding
  - Test seed data versioning to prevent user data overwrites on app updates
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 12.2_

- [x] 6. Implement HomeViewModel and workout day management
  - Create HomeViewModel with ObservableObject conformance
  - Implement fetchActiveDays() with proper sorting (order primary, createdAt tiebreaker)
  - Implement day creation, renaming, and soft deletion functionality
  - Create edit mode state management for day list
  - Implement drag-and-drop reordering with order field updates
  - Create reusable UndoManager helper for 5-second undo functionality (shared with DayDetailViewModel)
  - Add 5-second undo functionality for day deletion using the shared helper
  - _Requirements: 1.1, 1.2, 2.1, 2.3, 2.4, 2.5, 2.6, 2.7_

- [ ] 7. Create Home screen UI (WorkoutDaysListView)
  - Implement vertical list display of active workout days
  - Create day row UI with name and exercise count subtitle
  - Implement navigation to Day Detail screen on tap
  - Add edit mode toggle with reordering, renaming, and deletion controls
  - Implement drag handles for reordering functionality
  - Add "Add Day" button and functionality
  - Style with iOS system colors (.systemBackground, .label, .secondaryLabel) for future dark mode compatibility
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.3, 2.4, 7.1, 7.5, 8.2_

- [ ] 8. Implement DayDetailViewModel and exercise management
  - Create DayDetailViewModel with exercise table data management
  - Implement autofill logic for today's values from recommended sets (without modifying templates)
  - Create in-place editing state management with cell focus tracking
  - Implement exercise addition (isBaseline = false) and deletion using shared UndoManager helper
  - Add input validation for weight and reps with immediate feedback
  - Implement "Update Recommended from Today" functionality
  - _Requirements: 3.2, 3.6, 3.7, 3.8, 4.1, 4.3, 4.4, 4.5, 4.6_

- [ ] 9. Create Day Detail screen UI (DayDetailView)
  - Implement Excel-like table with Exercise | Set 1 | Set 2 | Set 3 | Set 4 columns
  - Create editable cells with numeric keypad input
  - Implement Return key navigation between cells (next cell, last cell commits)
  - Add exercise rows with today's values autofilled from recommended sets
  - Implement "Add Exercise" button and inline exercise addition
  - Add swipe-to-delete with 5-second undo for exercises using shared UndoManager helper
  - Style table with iOS system colors (.separator, .systemBackground) for future dark mode compatibility
  - _Requirements: 3.1, 3.3, 3.4, 3.5, 3.7, 4.1, 4.4, 7.1, 7.3, 8.2_

- [ ] 10. Implement ExerciseDetailViewModel and history management
  - Create ExerciseDetailViewModel with individual exercise data management
  - Implement today's sets editing with autofill from recommended template
  - Create history fetching logic for exactly 3 most recent distinct log dates
  - Implement history exclusion logic (exclude today unless it has a log)
  - Add "No past logs yet" placeholder for empty history
  - Implement exercise name editing functionality
  - Add "Update Recommended from Today" template modification
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 11. Create Exercise Detail screen UI (ExerciseDetailView)
  - Implement editable exercise name header with day name caption
  - Create today's section with 4 editable set rows
  - Implement history section with exactly 3 most recent entries
  - Style historical entries with .secondaryLabel color (WCAG AA compliant)
  - Format historical entries as "Week N (MM/DD/YY): s1W×s1R | s2W×s2R | s3W×s3R | s4W×s4R"
  - Add "Update Recommended from Today" button and functionality
  - Ensure proper font sizing (history matches today's font size)
  - _Requirements: 5.1, 5.2, 5.3, 5.6, 5.7, 7.4, 7.6_

- [ ] 12. Implement data persistence and ExerciseLog management
  - Create ExerciseLog creation/update logic for today's date (normalized to local midnight)
  - Implement single log per (exercise, date) constraint enforcement
  - Add date normalization utilities for consistent midnight timestamps
  - Implement recent logs fetching with proper date filtering
  - Create data persistence for all user edits with immediate save
  - Ensure app relaunch restores all saved data correctly
  - _Requirements: 6.2, 6.3, 6.5, 6.6, 3.4_

- [ ] 13. Add accessibility support and Dynamic Type
  - Implement VoiceOver labels for day names, exercise names, and set cells
  - Add descriptive labels like "Set 1 weight" and "Set 1 reps" for screen readers
  - Configure Dynamic Type support with minimum Large size
  - Ensure all tap targets meet 44pt minimum requirement
  - Test and verify all critical functionality works with assistive technologies
  - Add high contrast and reduced motion support
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 14. Implement error handling and validation UI
  - Add real-time input validation with user-friendly error messages
  - Implement error state UI for invalid weight/reps inputs
  - Create error handling for Core Data operations with graceful degradation
  - Add validation for empty exercise names with trimmed whitespace
  - Implement error recovery and retry mechanisms
  - Test error scenarios and edge cases
  - _Requirements: 3.8, 4.2_

- [ ] 15. Create comprehensive unit tests
  - Write Core Data entity tests for creation, relationships, and constraints
  - Create repository tests for CRUD operations and data consistency
  - Implement ViewModel tests for business logic and state management
  - Add validation tests for input rules and error handling
  - Create seed data tests to verify first-launch behavior
  - Test date normalization and uniqueness constraint enforcement
  - _Requirements: 6.1, 6.2, 6.6, 9.5_

- [ ] 16. Implement UI tests for key user flows
  - Create tests for seed data creation and first-launch experience
  - Test SeedVersion enum to verify it doesn't overwrite user data on app updates
  - Test navigation flow: Home → Day Detail → Exercise Detail
  - Implement in-place editing tests with keyboard navigation and data persistence
  - Test history display with exactly 3 most recent entries
  - Create accessibility tests with VoiceOver and Dynamic Type
  - Test undo functionality for day and exercise deletion using shared UndoManager helper
  - Verify autofill behavior and template protection
  - Test program switching to ensure isolation of logs and days between programs
  - _Requirements: 1.4, 3.2, 3.6, 5.4, 8.1, 2.6, 4.6, 9.5, 12.6_

- [ ] 17. Polish UI styling and system color implementation
  - Apply iOS system colors (.systemBackground, .label, .secondaryLabel, .separator) throughout app
  - Implement proper typography hierarchy with SF Pro system fonts
  - Add subtle separators using .separator color and avoid heavy borders
  - Ensure WCAG AA contrast for secondary text (historical data) using .secondaryLabel
  - Apply generous row heights and clear column separation
  - Implement proper cell padding and spacing following HIG guidelines
  - Test visual consistency across all screens in both light and dark mode to ensure system colors work correctly
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 15.1, 15.2_

- [ ] 18. Final integration testing and bug fixes
  - Test complete user workflows from seeding to data entry
  - Verify data persistence across app launches
  - Test edge cases like empty states, data validation, low-storage scenarios, and first run with no seed data
  - Test program switching isolation to ensure logs and days don't leak between programs
  - Ensure proper memory management and Core Data performance
  - Test accessibility features with real assistive technologies
  - Verify SeedVersion enum prevents data overwrites during app updates
  - Test shared UndoManager helper functionality across different ViewModels
  - Verify all requirements are met and acceptance criteria satisfied
  - Fix any remaining bugs and polish user experience
  - _Requirements: 6.3, 8.5, 9.5, 12.6_