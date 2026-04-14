# MiCocina Architecture Documentation

## Overview

MiCocina follows Clean Architecture principles combined with the MVVM (Model-View-ViewModel) pattern to ensure maintainability, testability, and separation of concerns. The architecture is designed to be scalable, allowing for future feature additions without major refactoring.

## Architecture Layers

### 1. Presentation Layer (SwiftUI Views)

The outermost layer responsible for displaying information to the user and handling user interactions.

#### Main Components

**ContentView** - Root Navigation Container
- Manages tab-based navigation using `TabView`
- Contains four main navigation tabs
- Each tab has independent `NavigationStack`
- Passes `modelContext` to child views for data operations
- Uses localized strings for all labels

```swift
TabView(selection: $navigation) {
    Tab(localized: "homeContent.navigationTitle") {
        NavigationStack {
            HomeContent(viewModel: .init(context: modelContext))
        }
    }
    // ... other tabs
}
```

**HomeContent** - Recipe Discovery View
- Displays recipes grouped by meal type
- Shows cookability status for each recipe
- Provides search and filtering capabilities
- Handles recipe creation flow

**MyPantryView** - Pantry Management View
- Lists all pantry ingredients with quantities
- Provides search functionality
- Implements swipe actions for quick operations
- Manages ingredient creation and deletion

**PlannerView** - Weekly Meal Planning View
- Displays week-based meal calendar
- Allows adding/removing recipes to specific days
- Supports recipe movement between days
- Provides week navigation (previous/next)

**ShoppingListView** - Shopping List Management View
- Shows ingredients needed for planned meals
- Allows manual item additions
- Supports item checking/unchecking
- Implements search for quick item lookup

### 2. ViewModel Layer

Acts as an intermediary between Views and Use Cases/Repositories, transforming data and handling view logic.

#### Responsibilities
- Transform domain models into view-friendly data structures
- Handle user actions and coordinate with use cases
- Manage view state (loading, error, success)
- Provide observable properties for reactive UI updates

#### Key ViewModels

**HomeContentViewModel**
- Manages recipe list state
- Coordinates recipe filtering and sorting
- Handles recipe CRUD operations
- Transforms recipes into `RecipeViewData` for display

**MyPantryModuleViewModel**
- Manages pantry inventory state
- Handles ingredient CRUD operations
- Provides ingredient search functionality
- Coordinates with pantry repository

**PlannerViewModel**
- Manages weekly meal plan state
- Handles recipe-to-day assignments
- Provides date navigation logic
- Coordinates with planner repository

### 3. Use Cases Layer

Contains application-specific business logic, orchestrating data flow between repositories.

#### RecipeUseCases Protocol

```swift
protocol RecipeUseCases {
    /// Get all recipes grouped by meal type
    func getAllRecipes() -> [RecipeGroup]
    
    /// Get only cookable recipes (≤3 missing ingredients)
    func getPossibleRecipes() -> [RecipeGroup]
}
```

**Key Responsibilities:**
- Recipe matching algorithm (comparing pantry with recipe ingredients)
- Recipe grouping by meal type
- Smart sorting (favorites first, cookable next, then by missing ingredients)
- Business rule enforcement

### 4. Repository Layer

Abstracts data access, providing a clean interface for data operations regardless of the underlying data source.

#### Repository Pattern Benefits
- Decouples data access from business logic
- Enables easy testing with mock repositories
- Allows switching data sources without affecting upper layers
- Centralizes data access logic

#### Key Repositories

**RecipeRepository**
- CRUD operations for recipes
- Recipe querying and filtering
- Recipe-ingredient relationship management

**PantryRepository**
- Pantry ingredient management
- Quantity tracking
- Ingredient search and lookup

**PlannerRepository**
- Meal plan persistence
- Day-to-recipe assignments
- Weekly plan retrieval

**ShoppingListRepository**
- Shopping list item management
- Automatic list generation from planned meals
- Item status tracking (purchased/unpurchased)

### 5. Data Layer (SwiftData)

Handles data persistence using Apple's SwiftData framework.

#### SwiftData Models

**SDRecipe** (SwiftData Model)
```swift
@Model
class SDRecipe {
    var id: UUID
    var name: String
    var mealType: String
    var isFavorite: Bool
    @Relationship var ingredients: [SDRecipeIngredient]
}
```

**SDIngredient** (SwiftData Model)
```swift
@Model
class SDIngredient {
    var id: UUID
    var name: String
    var quantity: Int
}
```

**SDRecipeIngredient** (Join Table Model)
```swift
@Model
class SDRecipeIngredient {
    var id: UUID
    var quantity: Int
    @Relationship var recipe: SDRecipe?
    @Relationship var ingredient: SDIngredient?
}
```

#### Persistence Strategy
- Local-first architecture (no cloud dependency in MVP)
- Automatic persistence with SwiftData
- Schema migration support for future updates
- In-memory storage option for testing

## Domain Models

Pure Swift models representing core business entities, independent of persistence layer.

### Recipe
```swift
struct Recipe: Equatable {
    let id: UUID
    let name: String
    let ingredients: Set<RecipeIngredient>
    let mealType: MealType
    let isFavorite: Bool
}
```

### Ingredient
```swift
struct Ingredient: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String  // Automatically normalized
    let quantity: Int
}
```

### MealType
```swift
enum MealType: Comparable {
    case breakFast
    case lunch
    case dinner
    case other
}
```

### NavigationViews
```swift
enum NavigationViews {
    case Home
    case MyPantry
    case Planner
    case ShoppingList
}
```

## Data Flow

### Reading Data (Query Flow)

```
┌──────────────┐
│  SwiftUI     │
│  View        │
└──────┬───────┘
       │ observes @Published properties
       ↓
┌──────────────┐
│  ViewModel   │
└──────┬───────┘
       │ calls
       ↓
┌──────────────┐
│  Use Case    │
└──────┬───────┘
       │ orchestrates
       ↓
┌──────────────┐
│  Repository  │
└──────┬───────┘
       │ fetches from
       ↓
┌──────────────┐
│  SwiftData   │
│  Model       │
└──────────────┘
```

### Writing Data (Command Flow)

```
┌──────────────┐
│  SwiftUI     │  User taps "Add Recipe"
│  View        │
└──────┬───────┘
       │ calls action
       ↓
┌──────────────┐
│  ViewModel   │  Validates input
└──────┬───────┘
       │ calls
       ↓
┌──────────────┐
│  Repository  │  Transforms to SwiftData model
└──────┬───────┘
       │ persists
       ↓
┌──────────────┐
│  SwiftData   │  Saves to disk
│  Model       │
└──────┬───────┘
       │ @Query auto-updates
       ↓
┌──────────────┐
│  SwiftUI     │  UI refreshes automatically
│  View        │
└──────────────┘
```

## Key Design Patterns

### 1. MVVM (Model-View-ViewModel)
- **Views**: Declare UI structure, observe ViewModel
- **ViewModels**: Transform data, handle user actions
- **Models**: Pure data structures

### 2. Repository Pattern
- Abstracts data access
- Provides consistent interface regardless of data source
- Enables easy testing with mock implementations

### 3. Dependency Injection
- ViewModels receive dependencies through initializers
- `modelContext` injected via SwiftUI environment
- Facilitates testing and decoupling

### 4. Observer Pattern
- SwiftUI's `@Published` and `@ObservedObject`
- Reactive UI updates when data changes
- SwiftData's `@Query` for automatic persistence observation

### 5. Use Case Pattern
- Encapsulates business logic
- Coordinates between multiple repositories
- Keeps ViewModels thin and focused on presentation

## Navigation Architecture

### Tab-Based Navigation

```swift
TabView(selection: $navigation) {
    // Each tab contains independent NavigationStack
    Tab("Home") {
        NavigationStack {
            HomeContent()
        }
    }
}
```

**Benefits:**
- Independent navigation state per tab
- Preserved state when switching tabs
- Clear separation of feature modules
- Standard iOS pattern users expect

### Navigation State Management
- `@State private var navigation: NavigationViews`
- Bound to TabView selection
- Type-safe with enum
- Easily extended for new tabs

## Testing Strategy

### Unit Tests

**Repository Tests**
- Mock SwiftData with in-memory containers
- Test CRUD operations
- Verify data transformations
- Test error handling

**Mapper Tests**
- Verify domain ↔ SwiftData transformations
- Test edge cases and nil handling
- Ensure data integrity

**Use Case Tests**
- Mock repositories
- Test business logic (recipe matching, sorting)
- Verify correct repository coordination

### Preview Support
- Mock ViewModels for SwiftUI previews
- In-memory SwiftData containers
- Sample data generators

## Localization Architecture

### Localization Strategy
- All user-facing strings externalized to `.xcstrings`
- `String(localized:)` for type-safe access
- Organized by feature module
- Supports multiple languages with single source of truth

### Key Localization Areas
- Navigation titles
- Tab labels  
- Empty state messages
- Error messages
- Meal type labels
- Action button labels

## Scalability Considerations

### Adding New Features

**New View Module:**
1. Create SwiftUI View
2. Create ViewModel
3. Create Repository if needed
4. Add to navigation enum
5. Add tab in ContentView

**New Domain Model:**
1. Create Swift struct/enum
2. Create SwiftData model
3. Create mapper
4. Add to repository
5. Update use cases if needed

### Future Enhancements

**Cloud Sync**
- Repository pattern allows adding cloud repository
- Use cases can coordinate local + cloud
- No view changes required

**Recipe Photos**
- Add to domain model
- Update SwiftData model
- Modify repository layer
- Views can observe new property

**Offline/Online Modes**
- Repository can switch between local/remote
- Use cases handle syncing logic
- UI remains unchanged

## Error Handling

### Strategy
- Repository throws Swift errors
- ViewModel catches and converts to user-friendly messages
- View displays alerts with localized messages
- Logging for debugging (future enhancement)

### Error Types
```swift
enum RepositoryError: Error {
    case notFound
    case saveFailed
    case deleteFailed
    case invalidData
}
```

## Performance Considerations

### Optimization Techniques
- SwiftData `@Query` for efficient database access
- Lazy loading with SwiftUI's built-in mechanisms
- Set-based ingredient lookup (O(1) contains check)
- Normalized ingredient names for fast matching

### Memory Management
- Value types (structs) for domain models
- SwiftData handles object lifecycle
- ViewModels as `ObservableObject` (class)
- Automatic memory management with ARC

## Security Considerations

### Data Privacy
- All data stored locally on device
- No network transmission (MVP version)
- Uses iOS sandbox for data isolation
- User controls all data

### Future Security Enhancements
- Keychain for sensitive data
- App Transport Security for cloud sync
- End-to-end encryption for shared recipes
- Biometric authentication for app access

## Deployment Architecture

### Build Configuration
- Development: In-memory database, mock data
- Testing: Separate database instance
- Production: Persistent local database

### Version Management
- Semantic versioning (MAJOR.MINOR.PATCH)
- SwiftData schema migration for updates
- Backward compatible data models

---

## Summary

MiCocina's architecture is designed with the following principles:

1. **Separation of Concerns**: Clear boundaries between layers
2. **Testability**: Easy to test with mocks and dependency injection
3. **Maintainability**: Well-organized, documented code
4. **Scalability**: Easy to add features without major refactoring
5. **Type Safety**: Leverages Swift's type system for compile-time safety
6. **Modern Swift**: Uses latest Swift and SwiftUI features
7. **Offline First**: Works without network connectivity

This architecture provides a solid foundation for the MVP while enabling future enhancements and scaling.

---

**Last Updated**: April 13, 2026  
**Version**: 1.0 MVP
