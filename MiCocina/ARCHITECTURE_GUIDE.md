# MiCocina Architecture Guide

## 🏗️ Clean Architecture Overview

MiCocina follows Clean Architecture principles with clear separation of concerns across multiple layers. This document explains the critical architectural decisions and patterns used throughout the application.

---

## 🎯 Critical Architectural Distinction: Recipe Ingredients vs Pantry Ingredients

### The Core Separation

MiCocina maintains a **strict separation** between two different concepts:

1. **Recipe Ingredients** - What a recipe **needs**
2. **Pantry Ingredients** - What you **actually have**

This separation is fundamental to the app's architecture and prevents data leakage between modules.

### Why This Matters

**❌ WRONG Approach (Data Leakage):**
```swift
// If recipes and pantry share the same Ingredient reference:
let recipe = Recipe(ingredients: [Ingredient(name: "Eggs")])
recipeRepository.save(recipe)  
// ❌ This would accidentally add "Eggs" to your pantry!
```

**✅ CORRECT Approach (Proper Separation):**
```swift
// Recipe ingredients are just names
let recipe = Recipe(ingredients: [
    RecipeIngredient(ingredientName: "Eggs")
])
recipeRepository.save(recipe)  
// ✅ Recipe is saved, pantry remains unchanged

// Separately manage pantry
pantryRepository.add(Ingredient(name: "Eggs", quantity: 12))
// ✅ Only this explicitly adds to pantry
```

---

## 📦 Domain Models

### RecipeIngredient
**Purpose:** Represents an ingredient **needed** for a recipe

**Properties:**
```swift
struct RecipeIngredient {
    let id: UUID
    let ingredientName: String  // ← Just the name!
    let isRequired: Bool        // Required or optional
}
```

**Key Points:**
- ✅ Stores **only the ingredient name** as a String
- ✅ Does **NOT** reference Ingredient objects
- ✅ Does **NOT** have quantity (recipes don't track inventory)
- ✅ Independent from pantry data
- ✅ Immutable (let properties)

**Usage:**
```swift
let recipeIngredient = RecipeIngredient(
    ingredientName: "Tomato",
    isRequired: true
)
```

---

### Ingredient (Pantry Item)
**Purpose:** Represents an ingredient you **actually have** in your pantry

**Properties:**
```swift
struct Ingredient {
    let id: UUID
    let name: String
    let quantity: Int  // ← How many you have!
}
```

**Key Points:**
- ✅ Stores **name AND quantity**
- ✅ Represents actual inventory
- ✅ Independent from recipes
- ✅ Quantity determines if you have it (quantity > 0)
- ✅ Immutable (let properties)

**Usage:**
```swift
let pantryIngredient = Ingredient(
    name: "Tomato",
    quantity: 5  // You have 5 tomatoes
)
```

---

## 🔄 Recipe Matching Logic

The `RecipeMatcher` compares **ingredient names** between recipes and pantry:

```swift
// Recipe needs
let recipeNeeds = ["Pasta", "Tomato", "Basil"]

// Pantry has (quantity > 0)
let pantryHas = ["Pasta", "Tomato"]  

// Missing ingredients
let missing = ["Basil"]  // 1 missing

// Can cook? (missing count ≤ 3)
canCook = true  ✅
```

**Algorithm:**
1. Extract required ingredient names from recipe
2. Extract available ingredient names from pantry (where quantity > 0)
3. Calculate missing = recipe ingredients - pantry ingredients
4. Recipe is "cookable" if missing ≤ 3

---

## 💾 Data Layer (SwiftData)

### SDRecipeIngredient
**Purpose:** Persist recipe ingredient information

**Properties:**
```swift
@Model
final class SDRecipeIngredient {
    var id: UUID
    var recipe: SDRecipe
    var ingredientName: String  // ← Stored as String!
    var quantity: String?       // e.g., "2 cups" (for future)
    var isRequired: Bool
}
```

**Key Points:**
- ✅ Stores `ingredientName` as a **String**
- ✅ Does **NOT** reference `SDIngredient`
- ✅ Maintains relationship with `SDRecipe` only
- ✅ No connection to pantry data

---

### SDIngredient
**Purpose:** Persist pantry ingredient information

**Properties:**
```swift
@Model
final class SDIngredient {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var quantity: Int  // ← Pantry quantity!
}
```

**Key Points:**
- ✅ Stores **name AND quantity**
- ✅ Represents pantry inventory only
- ✅ Filtered by `quantity > 0` for pantry queries
- ✅ Completely separate from recipe storage

---

## 🗂️ Repository Pattern

### Recipe Repository
**Responsibility:** Manage recipe data (NO pantry interaction)

```swift
protocol RecipeProtocolRepository {
    func save(_ recipe: Recipe) throws
    // Saves recipe with ingredient NAMES only
    // Does NOT create pantry entries
}
```

### Pantry Repository
**Responsibility:** Manage pantry inventory (NO recipe interaction)

```swift
protocol PantryProtocolRepository {
    func add(_ ingredient: Ingredient) throws
    // Adds ingredient with quantity to pantry
    // Completely independent of recipes
    
    func getPantry() -> Set<Ingredient>
    // Returns only items with quantity > 0
}
```

---

## 🧪 Testing Strategy

### Critical Test: No Ingredient Leakage
```swift
@Test
func adding_recipe_does_not_add_to_pantry() throws {
    // Given
    let recipe = Recipe(ingredients: [
        RecipeIngredient(ingredientName: "Eggs")
    ])
    
    // When
    try recipeRepository.save(recipe)
    
    // Then
    let pantry = pantryRepository.getPantry()
    #expect(pantry.isEmpty == true)  // ✅ Pantry stays empty!
}
```

---

## 🎨 UI Layer Patterns

### Adding a Recipe
```swift
// NewRecipeView.swift
let recipeIngredients = ingredients.map { name in
    RecipeIngredient(ingredientName: name, isRequired: true)
}

let recipe = Recipe(
    name: recipeName,
    ingredients: Set(recipeIngredients),
    mealType: selectedMealType
)

try viewModel.save(recipe)  // ✅ Only saves recipe
```

### Adding to Pantry
```swift
// AddIngredientView.swift
let ingredient = Ingredient(
    name: name,
    quantity: quantity
)

try viewModel.add(ingredient)  // ✅ Only adds to pantry
```

---

## 🔍 Data Flow Examples

### Example 1: Creating a Recipe
```
User Input: "Pasta Carbonara" needs ["Pasta", "Eggs", "Bacon"]
     ↓
RecipeIngredient objects created with ingredient names
     ↓
Recipe domain model created
     ↓
StorageMapper converts to SDRecipe + SDRecipeIngredient
     ↓
SDRecipeIngredient stores ingredient names as Strings
     ↓
✅ Recipe saved
❌ Pantry unchanged
```

### Example 2: Adding to Pantry
```
User Input: "Eggs" with quantity = 12
     ↓
Ingredient domain model created
     ↓
StorageMapper converts to SDIngredient with quantity
     ↓
SDIngredient persisted with quantity = 12
     ↓
✅ Pantry updated
❌ Recipes unchanged
```

### Example 3: Recipe Matching
```
Recipe: ["Pasta", "Eggs", "Bacon"] (all required)
Pantry: [Pasta(qty: 2), Eggs(qty: 12)]
     ↓
RecipeMatcher extracts names:
  - Recipe needs: ["Pasta", "Eggs", "Bacon"]
  - Pantry has: ["Pasta", "Eggs"] (quantity > 0)
     ↓
Missing calculation:
  - Missing: ["Bacon"]
  - Count: 1
     ↓
✅ Can cook! (1 ≤ 3)
```

---

## 🚫 Anti-Patterns to Avoid

### ❌ DON'T: Share Ingredient objects
```swift
// ❌ WRONG
let sharedIngredient = Ingredient(name: "Eggs", quantity: 12)
let recipeIngredient = RecipeIngredient(ingredient: sharedIngredient)
// This creates coupling!
```

### ✅ DO: Use separate models
```swift
// ✅ CORRECT
// For recipes - just the name
let recipeIngredient = RecipeIngredient(ingredientName: "Eggs")

// For pantry - name + quantity
let pantryIngredient = Ingredient(name: "Eggs", quantity: 12)
```

### ❌ DON'T: Create SDIngredient in recipe mapping
```swift
// ❌ WRONG
let sdIngredient = SDIngredient(name: "Eggs", quantity: 0)
let sdRecipeIngredient = SDRecipeIngredient(ingredient: sdIngredient)
// This creates unnecessary database entries!
```

### ✅ DO: Store ingredient name directly
```swift
// ✅ CORRECT
let sdRecipeIngredient = SDRecipeIngredient(
    ingredientName: "Eggs",
    isRequired: true
)
// Clean and simple!
```

---

## 📊 Database Schema

### Tables Overview

```
┌─────────────────────────────────────────────┐
│  SDRecipe                                   │
│  - id: UUID (unique)                        │
│  - name: String                             │
│  - mealType: String                         │
│  - isFavorite: Bool                         │
│  - ingredients: [SDRecipeIngredient] ───┐   │
└─────────────────────────────────────────│───┘
                                          │
                    ┌─────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  SDRecipeIngredient                         │
│  - id: UUID (unique)                        │
│  - recipe: SDRecipe                         │
│  - ingredientName: String  ← JUST NAME!     │
│  - quantity: String? (future)               │
│  - isRequired: Bool                         │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  SDIngredient (SEPARATE TABLE)              │
│  - id: UUID (unique)                        │
│  - name: String                             │
│  - quantity: Int  ← PANTRY QUANTITY!        │
└─────────────────────────────────────────────┘
```

**Key Insight:** `SDRecipeIngredient` and `SDIngredient` are **completely separate**. No foreign key relationship exists between them.

---

## 🎯 Benefits of This Architecture

### 1. **Clear Separation of Concerns**
- Recipes know what they need
- Pantry knows what you have
- No confusion or coupling

### 2. **Prevents Data Leakage**
- Adding recipes doesn't affect pantry
- Adding to pantry doesn't affect recipes
- Each module is independent

### 3. **Flexible Matching**
- Can compare recipe needs vs pantry availability
- Easy to calculate missing ingredients
- Simple string-based comparison

### 4. **Easy to Maintain**
- Changes to recipes don't affect pantry logic
- Changes to pantry don't affect recipe logic
- Clear boundaries make debugging easier

### 5. **Testable**
- Each component can be tested independently
- Mock data is simple to create
- Integration tests verify separation

---

## 📝 Developer Guidelines

### When Creating a Recipe
1. Use `RecipeIngredient(ingredientName:isRequired:)`
2. **Never** create `Ingredient` objects for recipes
3. Store only names and metadata

### When Managing Pantry
1. Use `Ingredient(name:quantity:)`
2. **Always** include quantity
3. **Never** reference recipes

### When Matching Recipes
1. Extract ingredient names from both sources
2. Compare as simple strings
3. Filter pantry by `quantity > 0`

### When Testing
1. Verify recipes don't affect pantry
2. Verify pantry doesn't affect recipes
3. Test matching logic with name comparison

---

## 🔄 Migration Notes

### From Old Architecture (Shared Ingredient)
If you have code using the old pattern:

**Before:**
```swift
let ingredient = Ingredient(name: "Eggs")
let recipeIngredient = RecipeIngredient(ingredient: ingredient)
```

**After:**
```swift
// For recipes
let recipeIngredient = RecipeIngredient(ingredientName: "Eggs")

// For pantry (separate)
let pantryIngredient = Ingredient(name: "Eggs", quantity: 12)
```

### Database Migration
When updating the app:
1. **Delete the app** from device (clears old schema)
2. Rebuild and reinstall
3. Old data will be lost (schema changed)
4. This is expected for the architectural improvement

---

## 📚 Related Documentation

- `README.md` - General project overview
- `ARCHITECTURE.md` - Detailed architecture documentation
- `DEVELOPER_GUIDE.md` - Development practices
- `TESTING_GUIDE.md` - Testing strategies

---

## ✅ Checklist for New Features

When adding new features, ensure:

- [ ] Recipe ingredients use `RecipeIngredient` with `ingredientName`
- [ ] Pantry items use `Ingredient` with `quantity`
- [ ] No shared references between recipes and pantry
- [ ] Repository methods maintain separation
- [ ] Tests verify no data leakage
- [ ] UI properly distinguishes between the two concepts

---

**Last Updated:** April 14, 2026  
**Architecture Version:** 2.0 (Clean Separation)
