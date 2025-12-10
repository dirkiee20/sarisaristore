# Deployment Diagram for Sarisari Store App

This diagram shows the physical deployment of the Sarisari Store Flutter application components across different hardware nodes and environments.

```mermaid
graph TB
    subgraph "Development Environment"
        DEV[Developer Workstation]
        GIT[Git Repository]
        CI[CI/CD Pipeline]
    end

    subgraph "Distribution Platforms"
        PLAY[Google Play Store]
        APPLE[Apple App Store]
    end

    subgraph "User Device (Android/iOS)"
        DEVICE[Mobile Device]
        subgraph "Sarisari Store App"
            UI[Flutter UI Layer]
            BUSINESS[Business Logic<br/>Services]
            DATA[Data Access<br/>Repositories & DAOs]
            DB[(SQLite Database<br/>Local Storage)]
            ASSETS[App Assets<br/>Images, Icons]
        end
        subgraph "Device Hardware/Software"
            CAMERA[Camera<br/>Barcode Scanner]
            STORAGE[Device Storage<br/>File System]
            OS[Operating System<br/>Android/iOS]
        end
    end

    DEV -->|Code Push| GIT
    GIT -->|Trigger Build| CI
    CI -->|APK/IPA| PLAY
    CI -->|APK/IPA| APPLE

    PLAY -->|Download & Install| DEVICE
    APPLE -->|Download & Install| DEVICE

    UI -->|Business Operations| BUSINESS
    BUSINESS -->|Data Operations| DATA
    DATA -->|CRUD Operations| DB
    UI -->|Access| ASSETS

    BUSINESS -->|Barcode Scanning| CAMERA
    BUSINESS -->|File Operations| STORAGE
    DATA -->|Data Persistence| STORAGE
    ASSETS -->|Storage| STORAGE

    UI -->|System APIs| OS
    BUSINESS -->|Platform Services| OS
    DATA -->|Database Engine| OS

    style DEVICE fill:#e3f2fd
    style UI fill:#f3e5f5
    style BUSINESS fill:#e8f5e8
    style DATA fill:#fff3e0
    style DB fill:#fce4ec
    style PLAY fill:#e8eaf6
    style APPLE fill:#fce4ec
```

## Deployment Components

### Development Environment
- **Developer Workstation**: Where the Flutter app is developed using Dart and Flutter SDK
- **Git Repository**: Version control for source code management
- **CI/CD Pipeline**: Automated building, testing, and deployment process

### Distribution Platforms
- **Google Play Store**: Distribution platform for Android APK files
- **Apple App Store**: Distribution platform for iOS IPA files

### User Device
The app runs entirely on the user's mobile device with no external server dependencies:

#### App Components
- **Flutter UI Layer**: User interface screens and widgets
- **Business Logic Services**: Product, Transaction, Analytics, and other services
- **Data Access Layer**: Repositories and DAOs for data operations
- **SQLite Database**: Local relational database for data persistence
- **App Assets**: Images, icons, and other static resources

#### Device Resources
- **Camera**: Used for barcode scanning functionality
- **Device Storage**: File system for database files and user data
- **Operating System**: Android or iOS providing platform APIs

## Deployment Flow
1. Developers write code on workstations and push to Git
2. CI/CD pipeline builds the app for both platforms
3. Built APKs/IPAs are uploaded to respective app stores
4. Users download and install the app on their devices
5. App runs locally with all data stored on device
6. App accesses device hardware (camera, storage) as needed

## Key Characteristics
- **Offline-First**: No internet connection required for core functionality
- **Local Storage**: All data persists locally on device
- **Cross-Platform**: Single codebase deployed to both Android and iOS
- **Self-Contained**: No external APIs or cloud services required