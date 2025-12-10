# System Architecture Diagram for Sarisari Store App

This diagram illustrates the layered architecture of the Sarisari Store Flutter application, showing the flow of data and responsibilities across different layers.

```mermaid
graph TB
    subgraph "Presentation Layer (UI)"
        A[AddProductScreen]
        B[ProductsTab]
        C[CheckoutScreen]
        D[AnalyticsTab]
        E[StockManagementTab]
        F[SplashScreen]
        G[Custom Widgets]
    end

    subgraph "Business Logic Layer (Services)"
        H[ProductService]
        I[TransactionService]
        J[AnalyticsService]
        K[ExpenseService]
        L[BarcodeScannerService]
        M[FileService]
        N[DemoModeService]
    end

    subgraph "Data Access Layer (Repositories & DAOs)"
        O[ProductRepository]
        P[TransactionRepository]
        Q[CategoryRepository]
        R[ExpenseRepository]
        S[StockAdjustmentRepository]
        T[ProductDao]
        U[TransactionDao]
        V[CategoryDao]
        W[ExpenseDao]
        X[StockAdjustmentDao]
    end

    subgraph "Data Layer (Models & Database)"
        Y[ProductModel]
        Z[TransactionModel]
        AA[TransactionItemModel]
        BB[CategoryModel]
        CC[ExpenseModel]
        DD[StockAdjustmentModel]
        EE[DatabaseHelper]
        FF[SQLite Database]
    end

    subgraph "External Dependencies"
        GG[Barcode Scanner]
        HH[File System]
        II[Device Storage]
    end

    A --> H
    B --> H
    C --> I
    D --> J
    E --> H
    F -->|Initialization| H

    H --> O
    I --> P
    I --> O
    J --> O
    J --> P
    K --> Q
    L --> GG
    M --> HH
    N -->|Demo Data| O

    O --> T
    P --> U
    Q --> V
    R --> W
    S --> X

    T --> Y
    T --> DD
    U --> Z
    U --> AA
    V --> BB
    W --> CC
    X --> DD

    T --> EE
    U --> EE
    V --> EE
    W --> EE
    X --> EE

    EE --> FF

    GG --> L
    HH --> M
    II --> FF

    style A fill:#e1f5fe
    style H fill:#f3e5f5
    style O fill:#e8f5e8
    style Y fill:#fff3e0
    style GG fill:#fce4ec
```

## Architecture Layers Explanation

### Presentation Layer
- **Screens**: AddProductScreen, ProductsTab, CheckoutScreen, AnalyticsTab, StockManagementTab, SplashScreen
- **Widgets**: Reusable UI components for product cards, search bars, charts, etc.
- **Responsibility**: User interaction, data display, navigation

### Business Logic Layer
- **Services**: ProductService, TransactionService, AnalyticsService, ExpenseService, BarcodeScannerService, FileService, DemoModeService
- **Responsibility**: Business rules validation, data processing, coordination between UI and data layers

### Data Access Layer
- **Repositories**: Abstract data operations, provide clean API for services
- **DAOs**: Direct database operations using SQL queries
- **Responsibility**: Data persistence, query optimization, abstraction of data sources

### Data Layer
- **Models**: Data structures representing business entities
- **DatabaseHelper**: SQLite database management, schema creation, migrations
- **SQLite Database**: Local data storage
- **Responsibility**: Data storage, retrieval, integrity

### External Dependencies
- **Barcode Scanner**: Hardware/camera integration for product scanning
- **File System**: Image storage, export functionality
- **Device Storage**: Persistent data storage

## Data Flow
1. User interacts with UI (Presentation Layer)
2. UI calls Services (Business Logic Layer) for operations
3. Services use Repositories (Data Access Layer) for data operations
4. Repositories delegate to DAOs for database interactions
5. DAOs work with Models and DatabaseHelper to persist/retrieve data
6. Results flow back up the layers to update the UI

This layered architecture ensures separation of concerns, testability, and maintainability.