# MiCocina 🍳

MiCocina is an iOS recipe management application that helps users discover what they can cook based on ingredients they have in their pantry. The app provides a complete meal planning and shopping experience, making it easy to manage recipes, plan meals, and track ingredients.

## 📱 Features

### MVP Version 1.0

MiCocina's MVP includes four main modules:

#### 🏠 Home (Recipe Discovery)
- Browse all available recipes organized by meal type (Breakfast, Lunch, Dinner, Other)
- Smart recipe matching based on pantry ingredients
- Visual indicators showing which recipes you can cook
- Filter recipes by cookability (3 or fewer missing ingredients)
- Mark recipes as favorites with heart icon
- Add new recipes with ingredients and meal type classification
- Search functionality to quickly find specific recipes
- Detailed recipe view with ingredients list and cooking status

#### 🥗 My Pantry
- Manage your ingredient inventory
- Add ingredients with quantity tracking
- **Barcode scanning** for quick ingredient lookup using device camera
- Visual quantity indicators (red for low stock ≤3, green for adequate stock)
- Search ingredients in your pantry
- Swipe actions for quick management:
  - Add to shopping list
  - Delete ingredients with confirmation
- Detailed ingredient view with edit capabilities
- Empty state guidance for new users

#### 📅 Planner
- Weekly meal planning calendar
- Assign recipes to specific days
- Navigate through weeks with previous/next controls
- Visual display of planned meals per day
- Move recipes between days
- Quick access to recipe details from planned meals
- Empty state for unplanned days

#### 🛒 Shopping List
- Automatic shopping list generation from planned recipes
- Manual ingredient addition
- Mark items as purchased with checkboxes
- Remove items from shopping list
- Visual grouping of checked/unchecked items
- Search functionality for quick item lookup
- Empty state guidance

## ⚙️ Requirements

- **iOS 17.0+**
- **Camera access** for barcode scanning (Info.plist permission required)
- **SwiftData** for persistence
- **VisionKit** for barcode scanning

### Info.plist Configuration

Add the following key to your Info.plist for camera access:

```xml
<key>NSCameraUsageDescription</key>
<string>MiCocina necesita acceso a la cámara para escanear códigos de barras de productos</string>
```

## 🏗️ Architecture

MiCocina follows Clean Architecture principles with **strict separation between recipe ingredients and pantry items**.

### ⚠️ Critical Architectural Distinction

**Recipe Ingredients** and **Pantry Ingredients** are **completely separate** concepts:

- **RecipeIngredient**: What a recipe **needs** (stores only ingredient name)
- **Ingredient** (Pantry): What you **actually have** (stores name + quantity)

This separation ensures that:
- ✅ Adding recipes does NOT add ingredients to your pantry
- ✅ Recipes and pantry data are independent
- ✅ Recipe matching compares ingredient names correctly

**For detailed explanation, see:** [ARCHITECTURE_GUIDE.md](./ARCHITECTURE_GUIDE.md)

## 🏗️ Architecture

MiCocina follows Clean Architecture principles with clear separation of concerns:

### Layers

```
┌─────────────────────────────────────┐
│           UI Layer (SwiftUI)        │
│  - ContentView                      │
│  - HomeContent                      │
│  - MyPantryView                     │
│  - PlannerView                      │
│  - ShoppingListView                 │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│         ViewModel Layer             │
│  - HomeContentViewModel             │
│  - MyPantryModuleViewModel          │
│  - PlannerViewModel                 │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│        Use Cases Layer              │
│  - RecipeUseCases                   │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│       Repository Layer              │
│  - Recipe Repository                │
│  - Pantry Repository                │
│  - Planner Repository               │
│  - ShoppingList Repository          │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│     Data Layer (SwiftData)          │
│  - SDRecipe                         │
│  - SDIngredient                     │
│  - SDRecipeIngredient               │
└─────────────────────────────────────┘
```

### Domain Models

#### Recipe
Represents a recipe with:
- Unique identifier (UUID)
- Name
- Set of ingredients with quantities (RecipeIngredient)
- Meal type classification
- Favorite status

#### Ingredient
Represents a pantry ingredient with:
- Unique identifier (UUID)
- Name (automatically normalized for matching)
- Quantity

#### MealType
Enumeration for meal categorization:
- `.breakFast` - Morning meals
- `.lunch` - Midday meals
- `.dinner` - Evening meals
- `.other` - Snacks and other categories

#### NavigationViews
Enumeration for tab-based navigation:
- `.Home` - Recipe discovery and browsing
- `.MyPantry` - Pantry management
- `.Planner` - Weekly meal planning
- `.ShoppingList` - Shopping list management

## 🛠️ Technical Stack

- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Architecture**: Clean Architecture / MVVM
- **Language**: Swift
- **Minimum iOS Version**: iOS 17.0+
- **Localization**: Full internationalization support with `.xcstrings`

## 🌍 Localization

The app supports full localization with the following key strings:

### Navigation & Tabs
- `homeContent.navigationTitle` - Home tab title
- `myPantry.navigationTitle` - Pantry tab title
- `planner.title` - Planner tab title
- `shoppingList.title` - Shopping list tab title

### Home Content
- `homeContent.emptyState` - Message when no recipes available
- `homeContent.searchPrompt` - Search bar placeholder
- `homeContent.canCook` - Label for cookable recipes
- `homeContent.cannotCook` - Label for non-cookable recipes

### My Pantry
- `myPantry.emptyState` - Message for empty pantry
- `myPantry.noSearchResults` - No search results message
- `myPantry.swipe.buy` - Add to shopping list action
- `myPantry.swipe.delete` - Delete ingredient action
- `myPantry.deleteAlert.title` - Delete confirmation title
- `myPantry.deleteAlert.message` - Delete confirmation message
- `myPantry.deleteAlert.error` - Delete error message

### Planner
- `planner.title` - Navigation title for planner

### Shopping List
- `shoppingList.title` - Navigation title
- `shoppingList.searchPrompt` - Search bar placeholder
- `shoppingList.add.title` - Add item screen title

### Meal Types
- `mealType.breakfast` - Breakfast label
- `mealType.lunch` - Lunch label
- `mealType.dinner` - Dinner label
- `mealType.other` - Other meals label

### Common
- `common.error` - Generic error title

## 📂 Project Structure

```
MiCocina/
├── Views/
│   ├── ContentView.swift           # Main tab-based navigation
│   ├── HomeContent.swift           # Recipe discovery view
│   ├── MyPantryView.swift          # Pantry management view
│   ├── PlannerView.swift           # Weekly meal planner view
│   ├── ShoppingListView.swift      # Shopping list view
│   ├── RecipeDetailView.swift      # Recipe details view
│   ├── IngredientDetailView.swift  # Ingredient details view
│   ├── AddIngredientView.swift     # Add ingredient form
│   ├── AddRecipesToDayView.swift   # Add recipes to planner
│   └── MoveRecipeView.swift        # Move planned recipes
│
├── Domain/
│   ├── Models/
│   │   ├── Recipe.swift            # Recipe domain model
│   │   ├── Ingredient.swift        # Ingredient domain model
│   │   └── MealType.swift          # Meal type enumeration
│   │
│   └── UseCases/
│       └── RecipeUseCases.swift    # Recipe use case protocol
│
├── Data/
│   └── SwiftData Models/
│       ├── SDRecipe.swift
│       ├── SDIngredient.swift
│       └── SDRecipeIngredient.swift
│
└── Localization/
    └── Localizable.xcstrings        # Localization strings
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- macOS Sonoma or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/MiCocina.git
```

2. Open the project in Xcode:
```bash
cd MiCocina
open MiCocina.xcodeproj
```

3. Build and run on your device or simulator:
   - Select your target device
   - Press `Cmd + R` to build and run

### First Time Setup

1. **Add Ingredients to Pantry**:
   - Navigate to "My Pantry" tab
   - Tap the "+" button
   - Add ingredients with quantities

2. **Create Recipes**:
   - Navigate to "Home" tab
   - Tap the "+" button
   - Enter recipe name, select ingredients, and set meal type

3. **Plan Your Week**:
   - Navigate to "Planner" tab
   - Tap on a day
   - Add recipes to your weekly schedule

4. **Generate Shopping List**:
   - Plan meals in the Planner
   - Navigate to "Shopping List" tab
   - Missing ingredients are automatically added

## 🧪 Testing

The project includes comprehensive unit tests for:
- Repository layer (SwiftData operations)
- Domain models
- Use cases
- Mappers

Run tests with:
```bash
Cmd + U
```

Test files:
- `SDRecipeRepositoryTests.swift`
- `RecipeDomainRepositoryTests.swift`
- `PantryDomainRepositoryTests.swift`
- `SDPlannerDomainRepositoryTests.swift`
- `SDShoppingListRepositoryTests.swift`
- `ShoppingListItemTests.swift`
- `ShoppingListMapperTests.swift`

## 📝 Key Implementation Details

### Recipe Matching Algorithm
- Recipes are considered "cookable" if you have all ingredients or are missing 3 or fewer
- Smart sorting prioritizes:
  1. Favorite recipes
  2. Recipes you can cook now
  3. Recipes with fewer missing ingredients

### Ingredient Normalization
- Ingredient names are automatically normalized (lowercase, diacritics removed)
- Ensures consistent matching regardless of input format
- Example: "Tomato", "tomato", "TOMATO" all match

### Data Persistence
- All data is persisted locally using SwiftData
- No network requirements - fully offline capable
- Automatic schema migration support

### Navigation Pattern
- Tab-based navigation with 4 main sections
- Each tab has its own NavigationStack for independent navigation
- Preserves navigation state when switching between tabs

## 🎨 UI/UX Features

### Visual Indicators
- **Recipe Status**: Green badge for "Can Cook", Orange badge for "Cannot Cook"
- **Pantry Quantity**: Red circle (≤3 items), Green circle (>3 items)
- **Favorites**: Heart icon with red fill for favorite recipes
- **Shopping List**: Checkboxes for purchased items

### Gestures & Interactions
- **Swipe Actions**: Quick actions in pantry (buy, delete)
- **Search**: Real-time filtering in all major views
- **Pull to Refresh**: Update data in list views
- **Tap to Edit**: Tap ingredients or recipes for details

### Empty States
- Helpful messages when lists are empty
- Guidance on next steps for new users
- Distinct empty states for search results vs. truly empty lists

## 🔄 Data Flow Example

### Adding a Recipe to Planner
```
User taps day in Planner
    ↓
PlannerView shows AddRecipesToDayView
    ↓
User selects recipe
    ↓
ViewModel calls use case
    ↓
Use case interacts with Repository
    ↓
Repository persists to SwiftData
    ↓
SwiftData triggers @Query update
    ↓
UI automatically refreshes
```

## 🐛 Known Limitations (MVP)

- Shopping list "Add to cart" functionality in pantry is not yet implemented
- Recipe instructions/steps not included (only ingredients)
- No recipe images or photos
- No serving size adjustments
- No nutritional information
- No recipe sharing capabilities
- No cloud sync between devices

## 🗺️ Roadmap

### Planned Features
- [ ] Recipe instructions and cooking steps
- [ ] Recipe photos and images
- [ ] Serving size calculator
- [ ] Nutritional information tracking
- [ ] Recipe import from websites
- [ ] iCloud sync
- [ ] Widget support for today's meals
- [ ] Share recipes with friends
- [ ] Custom meal categories
- [ ] Cooking timers integration

## 📄 License

[Your License Here]

## 👨‍💻 Author

Carlos Cardoso

## 🙏 Acknowledgments

Built with SwiftUI and SwiftData, leveraging Apple's modern declarative frameworks for iOS development.

---

**Version**: 1.0 MVP  
**Last Updated**: April 13, 2026  
**Platform**: iOS 17.0+
