# MaxQ Project Structure

## Root Directory Organization
```
MaxQ/
├── MaxQ/                    # Main app source code
├── MaxQ.xcodeproj/         # Xcode project configuration
├── MaxQTests/              # Unit tests
└── MaxQUITests/            # UI tests
```

## Main App Directory (`MaxQ/`)
```
MaxQ/
├── MaxQApp.swift           # App entry point and configuration
├── ContentView.swift       # Main UI view
├── Persistence.swift       # Core Data stack setup
├── Assets.xcassets/        # App assets (icons, colors, images)
└── MaxQ.xcdatamodeld/      # Core Data model files
```

## File Naming Conventions
- **App files**: `[AppName]App.swift` for main app entry point
- **Views**: Descriptive names ending with `View.swift` (e.g., `ContentView.swift`)
- **Data**: `Persistence.swift` for Core Data configuration
- **Models**: Core Data entities defined in `.xcdatamodeld` files

## Code Organization Patterns
- **App Entry Point**: Single `@main` struct in `MaxQApp.swift`
- **View Structure**: SwiftUI views with clear separation of concerns
- **Data Layer**: Centralized persistence controller with shared instance
- **Environment Injection**: Core Data context passed via SwiftUI environment

## Testing Structure
- **Unit Tests**: `MaxQTests/` - Test business logic and data operations
- **UI Tests**: `MaxQUITests/` - Test user interface interactions and flows

## Asset Organization
- **App Icons**: Stored in `Assets.xcassets/AppIcon.appiconset/`
- **Colors**: Accent colors in `Assets.xcassets/AccentColor.colorset/`
- **Images**: Additional assets should be added to `Assets.xcassets/`