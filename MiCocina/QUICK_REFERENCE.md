# MiCocina - Quick Reference Card

## 🚀 Quick Commands

### Build & Run
```bash
⌘R          # Build and run
⌘B          # Build only
⌘.          # Stop running
⌘⇧K         # Clean build folder
⌘U          # Run tests
⌘I          # Profile with Instruments
```

### Navigation
```bash
⌘0          # Toggle navigator
⌘⌥0         # Toggle inspectors
⌘⇧Y         # Toggle debug area
⌘T          # New tab
⌘⇧]         # Next file
⌘⇧[         # Previous file
```

## 📱 App Navigation

```
TabView (Root)
├── Home Tab (house.fill)
│   └── Recipe Discovery & Browsing
├── My Pantry Tab (refrigerator.fill)
│   └── Ingredient Inventory
├── Planner Tab (calendar)
│   └── Weekly Meal Planning
└── Shopping List Tab (cart.fill)
    └── Shopping List Management
```

## 🏗️ Architecture Layers

```
View → ViewModel → Use Case → Repository → SwiftData
```

| Layer | Responsibility | Examples |
|-------|---------------|----------|
| View | UI Display | `ContentView`, `HomeContent` |
| ViewModel | Presentation Logic | `HomeContentViewModel` |
| Use Case | Business Logic | `RecipeUseCases` |
| Repository | Data Access | `RecipeRepository` |
| SwiftData | Persistence | `SDRecipe`, `SDIngredient` |

## 📦 Key Models

### Domain Models (Pure Swift)
```swift
Recipe           // Business recipe model
Ingredient       // Business ingredient model
MealType         // Enum: .breakFast, .lunch, .dinner, .other
NavigationViews  // Enum: .Home, .MyPantry, .Planner, .ShoppingList
```

### SwiftData Models (Persistence)
```swift
SDRecipe          // Persisted recipe
SDIngredient      // Persisted ingredient
SDRecipeIngredient // Relationship join table
```

## 🎨 Common UI Patterns

### Standard View Structure
```swift
struct MyView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var viewModel: MyViewModel
    @State private var showSheet = false
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Title")
                .toolbar { toolbarContent }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        // Content here
    }
}
```

### Localized Strings
```swift
Text(String(localized: "key.name"))
.navigationTitle("key.title")
```

### SwiftData Query
```swift
@Query private var recipes: [SDRecipe]
@Query(sort: \SDIngredient.name) private var ingredients: [SDIngredient]
```

## 🔑 Localization Keys

### Navigation
- `homeContent.navigationTitle`
- `myPantry.navigationTitle`
- `planner.title`
- `shoppingList.title`

### Home
- `homeContent.emptyState`
- `homeContent.searchPrompt`
- `homeContent.canCook`
- `homeContent.cannotCook`

### Pantry
- `myPantry.emptyState`
- `myPantry.swipe.buy`
- `myPantry.swipe.delete`
- `myPantry.deleteAlert.title`

### Meal Types
- `mealType.breakfast`
- `mealType.lunch`
- `mealType.dinner`
- `mealType.other`

## 🧪 Testing

### Run Tests
```bash
⌘U                    # Run all tests
⌘⌃⌥U                  # Run last test
```

### Test Structure
```swift
import Testing

@Suite("Feature Tests")
struct MyTests {
    @Test("Should do something")
    func testSomething() async throws {
        #expect(value == expected)
    }
}
```

### Preview with SwiftData
```swift
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SDRecipe.self, configurations: config)
    return MyView().modelContainer(container)
}
```

## 🎯 Recipe Matching Rules

- **Can Cook (Green)**: Has all ingredients OR missing ≤3 ingredients
- **Cannot Cook (Orange)**: Missing >3 ingredients
- Updates automatically when pantry changes

## 📊 Data Flow Examples

### Adding a Recipe
```
User Input → ViewModel validates → Repository saves → SwiftData persists → @Query updates UI
```

### Planning a Meal
```
Select day → Add recipe → Repository links → Shopping list auto-generates missing ingredients
```

### Pantry Update
```
Change quantity → Repository updates → Recipe status recalculates → UI refreshes
```

## 🔧 Common Tasks

### Add New View
1. Create SwiftUI View file
2. Create ViewModel (if needed)
3. Add navigation (if tab-level)
4. Add localized strings
5. Add preview

### Add Repository Method
```swift
func fetchAll() throws -> [DomainModel] {
    let descriptor = FetchDescriptor<SDModel>()
    let models = try context.fetch(descriptor)
    return models.map { $0.toDomain() }
}
```

### Add Localized String
1. Open `Localizable.xcstrings`
2. Add key-value pair
3. Use: `String(localized: "key")`

## 🐛 Debugging

### Common Issues

**SwiftData not updating**
- Check `@Query` usage
- Verify `modelContext.save()` called
- Ensure `@ObservedObject` on ViewModel

**Preview crashes**
- Use in-memory container
- Check mock data validity

**Localization missing**
- Verify key in `.xcstrings`
- Clean build (`⌘⇧K`)

### Logging
```swift
import OSLog
let logger = Logger(subsystem: "com.micocina", category: "Recipe")
logger.info("Message")
logger.error("Error: \(error)")
```

## 📁 File Organization

```
MiCocina/
├── Views/              # All SwiftUI views
├── ViewModels/         # Presentation layer
├── Domain/             # Business models & use cases
├── Data/               # SwiftData & repositories
├── Localization/       # .xcstrings files
└── Tests/              # Unit tests
```

## 🎨 Design Tokens

### Colors
- Primary: `.blue`
- Success: `.green`
- Warning: `.orange`
- Error: `.red`
- Secondary: `.gray`

### Typography
- Title: `.title`
- Heading: `.headline`
- Body: `.body`
- Caption: `.caption`

### Spacing
- Standard: `.padding()` (16pt)
- Small: `.padding(8)`
- Large: `.padding(24)`

### SF Symbols
- Home: `house.fill`
- Pantry: `refrigerator.fill`
- Planner: `calendar`
- Shopping: `cart.fill`
- Add: `plus`
- Delete: `trash`
- Heart: `heart.fill`

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Project overview & features |
| `ARCHITECTURE.md` | Technical architecture details |
| `CHANGELOG.md` | Version history |
| `TESTING_GUIDE.md` | Manual testing procedures |
| `DEVELOPER_GUIDE.md` | Developer onboarding |
| `PROJECT_SUMMARY.md` | MVP completion summary |

## 🔐 Best Practices

### Do ✅
- Use `@Query` for SwiftData
- Localize all strings
- Write tests for repositories
- Document complex logic
- Use value types (structs)
- Extract subviews
- Handle errors gracefully

### Don't ❌
- Mutate `@Published` from views
- Store strong refs to SwiftData models
- Hardcode strings
- Skip error handling
- Create massive view bodies
- Mix concerns across layers

## ⚡ Performance Tips

- Use `LazyVStack` for long lists
- Extract subviews to reduce body complexity
- Use `@ViewBuilder` for conditional views
- Profile with Instruments regularly
- Optimize SwiftData queries with predicates

## 🎓 Learning Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Testing](https://developer.apple.com/documentation/testing)

## 📞 Getting Help

1. Check `DEVELOPER_GUIDE.md` for detailed info
2. Review `ARCHITECTURE.md` for design decisions
3. See `TESTING_GUIDE.md` for testing help
4. Read inline code documentation

---

## 🎯 Current Status

**Version**: 1.0 MVP  
**Status**: ✅ Complete - Ready for Device Testing  
**Platform**: iOS 17.0+  
**Architecture**: Clean Architecture + MVVM  
**Last Updated**: April 13, 2026

---

**Quick Start**: Open project → Select device → Press ⌘R → Test features

**Happy Coding! 🎉**
