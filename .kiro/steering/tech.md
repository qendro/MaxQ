# MaxQ Technology Stack

## Frameworks & Libraries
- **SwiftUI**: Primary UI framework for declarative interface development
- **Core Data**: Local persistence and data management
- **Foundation**: Core Swift framework utilities

## Build System
- **Xcode Project**: Standard iOS app project structure
- **Swift Package Manager**: Dependency management (configured but no external dependencies currently)

## Development Environment
- **Language**: Swift
- **Platform**: iOS
- **Minimum Deployment Target**: iOS (check project settings for specific version)
- **Xcode**: Latest version recommended

## Common Commands
Since this is an Xcode project, development is primarily done through Xcode IDE:

### Building & Running
- Open `MaxQ.xcodeproj` in Xcode
- Build: `Cmd+B`
- Run: `Cmd+R`
- Test: `Cmd+U`

### Command Line (if needed)
```bash
# Build from command line
xcodebuild -project MaxQ.xcodeproj -scheme MaxQ build

# Run tests
xcodebuild -project MaxQ.xcodeproj -scheme MaxQ test
```

## Core Data Configuration
- Model file: `MaxQ.xcdatamodeld`
- Persistence controller: `PersistenceController.swift`
- Current entities: `Item` (with timestamp attribute)