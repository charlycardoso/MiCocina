# MiCocina

A SwiftUI-based iOS application designed to help users discover recipes based on ingredients available in their pantry.

## Overview

MiCocina is a recipe discovery app that intelligently matches recipes with ingredients you have at home. The app uses a smart matching algorithm to suggest recipes you can cook with minimal missing ingredients, making meal planning easier and reducing food waste.

## Project Structure

```
MiCocina/
├── MiCocina/                          # Main app source code
│   ├── ContentView.swift              # Main UI view
│   ├── MiCocinaApp.swift              # App entry point
│   ├── Item.swift                     # Legacy SwiftData model
│   ├── Assets.xcassets/               # App assets and icons
│   │
│   ├── Domain/                        # Domain layer (business logic)
│   │   ├── Model/                     # Data models
│   │   │   ├── Recipe.swift           # Recipe model
│   │   │   ├── Ingredient.swift       # Ingredient model
│   │   │   ├── RecipeIngredient.swift # Recipe ingredient association
│   │   │   ├── MealType.swift         # Meal type enumeration
│   │   │   ├── RecipeGroup.swift      # Grouped recipes
│   │   │   └── RecipeViewData.swift   # UI-ready recipe data
│   │   │
│   │   ├── Services/                  # Business logic services
│   │   │   └── RecipeMatcher.swift    # Recipe matching algorithm
│   │   │
│   │   └── UseCases/                  # Use case abstractions
│   │       ├── RecipeUseCases.swift   # Protocol definition
│   │       └── RecipeUseCasesImpl.swift# Use case implementation
│   │
│   ├── Data/                          # Data layer
│   │   ├── Repository/
│   │   │   ├── RecipeRepository.swift # Recipe data access
│   │   │   └── PantryRepository.swift # Pantry data access
│   │   │
│   │   └── Persistence/               # Local storage
│   │
│   ├── Utils/                         # Utility extensions
│   │   └── String+Extensions.swift    # String utilities
│   │
│   └── Persistence/                   # Persistence layer
│
├── MiCocinaTests/                     # Unit tests
│   ├── GetAllRecipesUseCaseTests.swift
│   └── RecipeMarcherTests.swift
│
└── MiCocina.xcodeproj/               # Xcode project configuration
```

## Architecture

MiCocina follows **Clean Architecture** principles with clear separation of concerns:

### Domain Layer
- **Models**: Core entities (`Recipe`, `Ingredient`, `MealType`, `RecipeGroup`)
- **Services**: Business logic implementation (`RecipeMatcher`)
- **UseCases**: High-level operations (`RecipeUseCases`)

### Data Layer
- **Repositories**: Data access abstractions (`RecipeRepository`, `PantryRepository`)
- **Persistence**: Local data storage implementation

### UI Layer
- **ContentView**: Main SwiftUI view
- **RecipeViewData**: View-specific data models

## Key Features

### 1. Recipe Management
- Store and organize recipes
- Categorize recipes by meal type (Breakfast, Lunch, Dinner, Other)
- Track recipe ingredients

### 2. Pantry Tracking
- Maintain a list of available ingredients in your pantry
- Track what you have at home

### 3. Recipe Matching Algorithm
The `RecipeMatcher` service intelligently suggests recipes based on:
- Available ingredients in your pantry
- Tolerance for missing ingredients (up to 3 missing items)
- Recipe categorization by meal type

### 4. Recipe Discovery
- **Get All Recipes**: View complete recipe collection
- **Get Possible Recipes**: View recipes you can cook with your current pantry

## Core Models

### Recipe
```swift
struct Recipe {
    let id: UUID
    let name: String
    let ingredients: Set<RecipeIngredient>
    let mealType: MealType
}
```

### Ingredient
Core ingredient with unique identification

### MealType
Enumeration: `breakFast`, `lunch`, `dinner`, `other`

### RecipeGroup
Groups recipes by meal type for organized display

### RecipeViewData
Presentation model for recipe display:
- Recipe name
- Count of missing ingredients
- Favorite status
- Meal type

## Use Cases

### RecipeUseCases Protocol

```swift
protocol RecipeUseCases {
    func getAllRecipes() -> [RecipeGroup]
    func getPossibleRecipes() -> [RecipeGroup]
}
```

#### `getAllRecipes()`
Returns all recipes organized by meal type

#### `getPossibleRecipes()`
Returns recipes that can be cooked with ingredients available in your pantry

## Technologies

- **SwiftUI**: Modern iOS UI framework
- **SwiftData**: Data persistence
- **Swift**: Programming language
- **Clean Architecture**: Design pattern
- **MVVM + Repository Pattern**: Software patterns

## Testing

The project includes unit tests for:
- Recipe use cases (`GetAllRecipesUseCaseTests`)
- Recipe matching algorithm (`RecipeMarcherTests`)

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- Swift 5.9+

### Building the Project
1. Open `MiCocina.xcodeproj` in Xcode
2. Select the MiCocina scheme
3. Build and run on simulator or device

### Running Tests
```bash
Cmd + U
```

Or from the command line:
```bash
xcodebuild test -scheme MiCocina
```

## Future Enhancements

Potential features for future development:
- User authentication and cloud sync
- Recipe search and filtering
- Ingredient substitutions
- Nutrition information
- Shopping list generation
- User ratings and reviews
- Favorite recipes management
- Recipe sharing

## Development Notes

- The project uses a mock `PantryRepository` for testing purposes
- The `RecipeMatcher` currently allows up to 3 missing ingredients
- The UI is still under development (ContentView shows placeholder)
- Legacy `Item` model from SwiftData template is present but not in use

## Author

Carlos Cardoso

## License

Proprietary
