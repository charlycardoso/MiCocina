# Changelog

All notable changes to the MiCocina project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-04-14 - Architecture Refactoring

### 🎯 Major Breaking Changes

#### Architectural Separation: Recipe Ingredients vs Pantry Ingredients

**Critical Change:** Complete separation of recipe ingredients and pantry ingredients to prevent data leakage.

**Before (v1.0):**
- Recipe ingredients and pantry items shared the same `Ingredient` model
- Adding recipes accidentally added ingredients to pantry
- Tight coupling between recipes and pantry data

**After (v2.0):**
- `RecipeIngredient`: Stores only ingredient **name** (what recipes need)
- `Ingredient`: Stores name + **quantity** (what you have in pantry)
- Complete separation prevents data leakage

### Changed

#### Domain Models
- **RecipeIngredient**: Now stores `ingredientName: String` instead of `Ingredient` object
- **Ingredient**: Added `quantity: Int` property for pantry tracking
- Removed shared reference between recipe and pantry ingredients

#### Storage Models (SwiftData)
- **SDRecipeIngredient**: Now stores `ingredientName: String` instead of `SDIngredient` reference
- **SDIngredient**: Added `quantity: Int` property
- No foreign key relationship between recipe ingredients and pantry items

#### Repository Layer
- **SDPantryRepository**: Filters queries by `quantity > 0` to return only pantry items
- **SDRecipeRepository**: Stores ingredient names directly, no pantry references
- **StorageMapper**: Updated to handle name-based ingredient storage for recipes

#### Business Logic
- **RecipeMatcher**: Compares ingredient **names** instead of objects
- **RecipeMapper**: Uses name-based comparison for missing ingredient calculation
- Recipe matching now filters pantry by `quantity > 0`

#### UI Layer
- **NewRecipeView**: Uses `RecipeIngredient(ingredientName:)` API
- **RecipeDetailView**: Displays `ingredientName` instead of `ingredient.name`
- **AddIngredientView**: Barcode scanning now correctly adds only to pantry

### Added
- **ARCHITECTURE_GUIDE.md**: Comprehensive guide explaining ingredient separation
- Camera permission support for barcode scanning (`NSCameraUsageDescription`)
- Barcode scanner integration using VisionKit's `DataScannerViewController`
- Product lookup via Open Food Facts API for barcode scanning

### Fixed
- ✅ **Critical:** Adding recipes no longer adds ingredients to pantry
- ✅ **Critical:** Recipe ingredients and pantry items are now independent
- ✅ Data persistence issues with ModelContext autosave
- ✅ ShoppingListView now receives proper modelContext injection
- ✅ Camera permission crash when scanning barcodes
- ✅ Recipe matching logic uses correct ingredient comparison
- ✅ Pantry refresh after add/edit/delete operations

### Migration Notes

**⚠️ Breaking Database Schema Change**

Users must **delete the app** and reinstall to migrate from v1.0 to v2.0:

1. Delete MiCocina from device
2. Rebuild and reinstall
3. All previous data will be lost (schema incompatible)
4. Add camera permission to Info.plist for barcode scanning

**Required Info.plist Change:**
```xml
<key>NSCameraUsageDescription</key>
<string>MiCocina necesita acceso a la cámara para escanear códigos de barras</string>
```

### Technical Improvements
- Enabled ModelContext autosave for better data persistence
- Added explicit `allowsSave: true` in ModelConfiguration
- Improved ViewMod el refresh after data operations
- Better state synchronization in views using `.onChange`

### Testing
- Updated all integration tests to use new `ingredientName` API
- Updated all storage mapper tests for new architecture
- Updated all repository tests for separated models
- Added test coverage for no-leakage between recipes and pantry

---

## [1.0.0] - 2026-04-13 - MVP Release

### Added

#### Core Navigation
- Tab-based navigation system with four main sections
- `NavigationViews` enum for type-safe navigation management
- Each tab contains independent `NavigationStack` for proper navigation state
- Localized tab labels using `.xcstrings` localization

#### Home Module (Recipe Discovery)
- Recipe browsing organized by meal type (Breakfast, Lunch, Dinner, Other)
- Smart recipe matching based on pantry ingredients
- Visual indicators showing cookable vs. non-cookable recipes
- Favorite recipes marking with heart icon
- Search functionality for quick recipe lookup
- Add new recipe capability with ingredient selection and meal type
- Detailed recipe view with full ingredient list
- Recipe sorting algorithm prioritizing favorites and cookable recipes

#### My Pantry Module
- Ingredient inventory management system
- Add ingredients with quantity tracking
- Visual quantity indicators (red ≤3, green >3)
- Search ingredients in pantry
- Swipe actions for quick operations:
  - Add to shopping list (prepared for future implementation)
  - Delete with confirmation alert
- Detailed ingredient view with edit capabilities
- Empty state messaging for better UX
- Real-time search filtering

#### Planner Module
- Weekly meal planning calendar
- Navigate between weeks with previous/next controls
- Add multiple recipes to specific days
- Visual display of planned meals per day
- Move recipes between days functionality
- Quick access to recipe details from planner
- Empty state for unplanned days
- Date-based organization

#### Shopping List Module
- Automatic shopping list generation from planned recipes
- Manual ingredient addition capability
- Mark items as purchased with checkboxes
- Remove items from list
- Search functionality for item lookup
- Visual separation of checked/unchecked items
- Empty state guidance

#### Architecture & Technical
- Clean Architecture implementation with clear layer separation
- MVVM pattern with dedicated ViewModels per module
- SwiftData integration for local persistence
- Repository pattern for data access abstraction
- Use Cases layer for business logic encapsulation
- Comprehensive unit test coverage for repositories and mappers

#### Domain Models
- `Recipe` model with ingredients, meal type, and favorite status
- `Ingredient` model with automatic name normalization
- `MealType` enum with Comparable conformance
- `RecipeIngredient` for ingredient-recipe relationships
- `NavigationViews` enum for navigation state management

#### Localization
- Full internationalization support using `.xcstrings`
- Localized strings for all UI labels and messages
- Localized error messages and alerts
- Localized meal type labels
- Localized navigation titles

#### Data Persistence
- SwiftData schema with three main entities:
  - `SDRecipe` - Recipe persistence model
  - `SDIngredient` - Ingredient persistence model
  - `SDRecipeIngredient` - Recipe-ingredient relationship model
- Automatic schema migration support
- Offline-first architecture (no network dependency)

#### User Experience
- Consistent design language across all modules
- Empty states with helpful guidance
- Real-time search across all major views
- Swipe gestures for common actions
- Confirmation dialogs for destructive actions
- Visual feedback for all user interactions
- Accessibility considerations

### Technical Details

#### Dependencies
- iOS 17.0+ minimum deployment target
- SwiftUI for declarative UI
- SwiftData for persistence
- Swift 5.9+ language features

#### Testing
- Unit tests for SwiftData repositories
- Domain repository test coverage
- Shopping list mapper tests
- Planner domain repository tests
- Mock data generators for preview and testing

### Documentation
- Comprehensive README with:
  - Feature overview and descriptions
  - Architecture diagrams and explanations
  - Technical stack details
  - Localization key reference
  - Project structure documentation
  - Getting started guide
  - Testing instructions
  - Data flow examples
- Inline code documentation for all major components
- Updated ContentView documentation with navigation details
- CHANGELOG for tracking development progress

### Known Limitations (MVP Scope)
- Shopping list "buy" action in pantry not fully implemented
- No recipe instructions/cooking steps
- No recipe images or photos
- No serving size adjustments
- No nutritional information
- No recipe sharing capabilities
- No cloud synchronization
- Single device only (no multi-device sync)

---

## [Unreleased]

### Planned for Future Releases
- Recipe instructions and step-by-step cooking guide
- Photo support for recipes
- Serving size calculator
- Nutritional information tracking
- Recipe import from websites
- iCloud sync for multi-device support
- Home Screen widgets
- Share recipes with friends
- Custom meal categories
- Cooking timer integration
- Grocery store aisle organization
- Price tracking for ingredients
- Seasonal recipe suggestions
- Dietary restriction filters

---

**Note**: This changelog reflects the MVP (Minimum Viable Product) release. All features are designed for local-first operation with a focus on core recipe discovery and meal planning functionality.
