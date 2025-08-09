# MaxQ

A **SwiftUI-based iOS workout tracker** designed for clarity, speed, and progress tracking.

MaxQ combines a minimalist, Excel-like interface with structured data management, making it easy to plan, log, and review workouts.

---

## Overview

MaxQ is currently in early development, evolving from the Core Data template into a **full-featured fitness management tool**.

The MVP focuses on local storage with Core Data, multi-program support, and progress tracking.

Future updates will introduce authentication, iCloud sync, and cross-device capabilities.

---

## Features (MVP)

- **Program Library** – Select from multiple preloaded workout programs (Push/Pull/Arms/Full Body, etc.)
- **Customizable Workout Days** – Rename, add, remove, or reorder workout days
- **Baseline & Added Exercises** – Preloaded exercises with option to add custom exercises
- **In-Place Editing** – Quickly update today's weight/reps without leaving the table view
- **Historical Tracking** – View the last 3 weeks of performance, visually de-emphasized for clarity
- **Progress View** – Track weekly volume, personal records, and streaks
- **Light & Dark Mode** – Fully adaptive UI for system appearance

---

## Technology Stack

- **SwiftUI** – Declarative UI framework
- **Core Data** – Local data persistence
- **MVVM** – Clean architecture pattern for separation of concerns
- **Xcode** – Development environment

---

## Getting Started

### Prerequisites
- Xcode (latest version recommended)
- macOS for development
- iOS 17+ device or simulator

### Installation
1. Clone the repository
   ```bash
   git clone [repository_url]
   ```
2. Open `MaxQ.xcodeproj` in Xcode
3. Build & run the project (`Cmd+R`)

### Development Commands
- **Build** – `Cmd+B`
- **Run** – `Cmd+R`
- **Test** – `Cmd+U`

## Project Structure

```
MaxQ/
├── MaxQ/                     # Main app source code
│   ├── App/                  # App entry & configuration
│   ├── Models/               # Core Data entities & Swift models
│   ├── ViewModels/           # MVVM logic layer
│   ├── Views/                # SwiftUI screens & components
│   ├── Persistence/          # Core Data stack & seeding
│   └── Resources/            # Assets & constants
├── MaxQTests/                # Unit tests
└── MaxQUITests/              # UI tests
```

## Contributing

When contributing:
- Follow SwiftUI and MVVM best practices
- Keep Core Data models consistent with xcdatamodeld
- Write unit/UI tests for new features
- Use system colors and typography for accessibility

## Roadmap

### Phase 1 (MVP)
- Local Core Data persistence
- Preloaded workout programs
- Customizable days & exercises
- Historical tracking (3 weeks)
- Progress dashboard

### Phase 2
- iCloud sync with CloudKit
- Sign in with Apple
- Data export/import (CSV)
- Advanced analytics