# MiCocina Developer Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- macOS Sonoma or later
- Xcode 15.0+
- iOS 17.0+ device or simulator
- Basic knowledge of SwiftUI and Swift

### Initial Setup

1. **Clone the repository**
```bash
git clone [repository-url]
cd MiCocina
```

2. **Open in Xcode**
```bash
open MiCocina.xcodeproj
```

3. **Build and Run**
- Select target device (simulator or physical device)
- Press `⌘R` or click the Play button
- App should launch successfully

### Project Structure Quick Reference

```
MiCocina/
├── Views/               # SwiftUI views (UI layer)
├── ViewModels/          # ViewModels (presentation logic)
├── Domain/              # Domain models and use cases
├── Data/                # SwiftData models and repositories
├── Localization/        # String catalogs (.xcstrings)
└── Tests/               # Unit and integration tests
```

## 🎯 Key Concepts

### Navigation Flow
```
ContentView (TabView)
    ├── Home (Recipe Discovery)
    ├── My Pantry (Ingredient Management)
    ├── Planner (Meal Planning)
    └── Shopping List (Shopping Management)
```

### Data Models

**Domain Models** (Pure Swift)
- `Recipe` - Business logic recipe
- `Ingredient` - Business logic ingredient
- `MealType` - Enum for meal categories
- `NavigationViews` - Navigation destinations

**SwiftData Models** (Persistence)
- `SDRecipe` - Persisted recipe
- `SDIngredient` - Persisted ingredient
- `SDRecipeIngredient` - Join table

### Architecture Pattern
```
View → ViewModel → Use Case → Repository → SwiftData
```

## 📝 Common Tasks

### Adding a New View

1. **Create the View**
```swift
// Views/MyNewView.swift
struct MyNewView: View {
    @ObservedObject private var viewModel: MyNewViewModel
    
    var body: some View {
        NavigationStack {
            // Your content
        }
        .navigationTitle("My New Feature")
    }
}
```

2. **Create the ViewModel**
```swift
// ViewModels/MyNewViewModel.swift
class MyNewViewModel: ObservableObject {
    @Published var data: [SomeModel] = []
    private let repository: SomeRepository
    
    init(context: ModelContext) {
        self.repository = SomeRepository(context: context)
    }
    
    func loadData() {
        data = repository.fetchData()
    }
}
```

3. **Add to Navigation** (if needed)
```swift
// ContentView.swift
enum NavigationViews {
    case Home
    case MyPantry
    case Planner
    case ShoppingList
    case MyNewFeature  // Add new case
}
```

### Adding a Localized String

1. Open `Localizable.xcstrings`
2. Add new key-value pair
3. Use in code:
```swift
Text(String(localized: "myNewFeature.title"))
```

### Creating a New Domain Model

```swift
// Domain/Models/MyModel.swift
struct MyModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    
    init(id: UUID = .init(), name: String) {
        self.id = id
        self.name = name
    }
}
```

### Adding Repository Methods

```swift
extension MyRepository {
    func fetchAll() throws -> [MyModel] {
        let descriptor = FetchDescriptor<SDMyModel>()
        let models = try context.fetch(descriptor)
        return models.map { $0.toDomain() }
    }
    
    func save(_ model: MyModel) throws {
        let sdModel = SDMyModel(from: model)
        context.insert(sdModel)
        try context.save()
    }
}
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
⌘U in Xcode

# Or via command line
xcodebuild test -scheme MiCocina -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Writing a Test

```swift
import Testing

@Suite("My Feature Tests")
struct MyFeatureTests {
    
    @Test("Should save model successfully")
    func testSaveModel() async throws {
        // Arrange
        let container = try ModelContainer(
            for: SDMyModel.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let repository = MyRepository(context: container.mainContext)
        let model = MyModel(name: "Test")
        
        // Act
        try repository.save(model)
        let fetched = try repository.fetchAll()
        
        // Assert
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Test")
    }
}
```

### Preview Support

```swift
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: SDRecipe.self,
        configurations: config
    )
    
    let viewModel = MyViewModel(context: container.mainContext)
    
    return MyView(viewModel: viewModel)
        .modelContainer(container)
}
```

## 🔧 Debugging Tips

### Common Issues

**Issue: SwiftData not updating UI**
- Ensure you're using `@Query` in views for automatic updates
- Check that `modelContext.save()` is called after changes
- Verify `@ObservedObject` on ViewModel

**Issue: Navigation not working**
- Check `NavigationStack` is present
- Ensure `NavigationLink` destinations are correct
- Verify state binding for TabView selection

**Issue: Localization strings not showing**
- Check key exists in `.xcstrings` file
- Ensure `String(localized:)` syntax correct
- Build clean if needed (`⌘⇧K`)

### Debugging SwiftData

```swift
// Print all recipes in database
let descriptor = FetchDescriptor<SDRecipe>()
let recipes = try? context.fetch(descriptor)
print("Recipes in DB: \(recipes?.count ?? 0)")
recipes?.forEach { print("- \($0.name)") }
```

### Logging

```swift
import OSLog

let logger = Logger(subsystem: "com.example.MiCocina", category: "Recipe")

logger.info("Loading recipes")
logger.error("Failed to save: \(error.localizedDescription)")
```

## 📚 Code Style Guide

### Naming Conventions

- **Types**: PascalCase (`Recipe`, `MyViewModel`)
- **Variables/Functions**: camelCase (`fetchRecipes`, `userName`)
- **Constants**: camelCase with `let` (`maxIngredients`)
- **Enums**: PascalCase for enum, camelCase for cases

### SwiftUI View Structure

```swift
struct MyView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var viewModel: MyViewModel
    @State private var showSheet = false
    
    // MARK: - Initialization
    init(viewModel: MyViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Title")
                .toolbar {
                    toolbarContent
                }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var contentView: some View {
        // Content
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Toolbar items
    }
    
    // MARK: - Methods
    private func performAction() {
        // Action logic
    }
}
```

### Documentation

```swift
/// Brief description of what this does.
///
/// Longer description with more details about behavior,
/// edge cases, and usage examples.
///
/// - Parameters:
///   - param1: Description of param1
///   - param2: Description of param2
/// - Returns: Description of return value
/// - Throws: Description of errors thrown
///
/// - Note: Additional notes
/// - Important: Critical information
/// - Warning: Warnings about potential issues
func myFunction(param1: String, param2: Int) throws -> Bool {
    // Implementation
}
```

## 🎨 UI Guidelines

### Colors
- Use system colors for consistency: `.blue`, `.green`, `.red`, `.gray`
- Respect color scheme (light/dark mode)

### Typography
- `.title`, `.headline`, `.body`, `.caption` for semantic sizes
- Use `.fontWeight()` sparingly

### Spacing
- Standard padding: `.padding()` (16pt)
- Custom padding: `.padding(.horizontal, 20)`

### SF Symbols
```swift
Image(systemName: "house.fill")
Image(systemName: "cart")
Image(systemName: "calendar")
```

## 🔐 Best Practices

### SwiftData
- ✅ Use `@Query` for automatic updates
- ✅ Create in-memory containers for testing
- ✅ Call `save()` after mutations
- ❌ Don't hold strong references to model objects

### State Management
- ✅ Use `@State` for view-local state
- ✅ Use `@ObservedObject` for ViewModels
- ✅ Use `@Environment` for dependency injection
- ❌ Don't mutate `@Published` properties from views

### Performance
- ✅ Use `@ViewBuilder` for conditional views
- ✅ Lazy load with `LazyVStack`/`LazyHStack`
- ✅ Extract subviews to reduce body complexity
- ❌ Don't perform heavy computation in body

## 📦 Dependencies

Currently the project uses only Apple frameworks:
- SwiftUI - UI framework
- SwiftData - Persistence
- Foundation - Core utilities

**No third-party dependencies!** 🎉

## 🌍 Localization Workflow

1. Add string to `.xcstrings` file
2. Use in code: `String(localized: "key")`
3. Export for translation (if needed)
4. Import translations
5. Test in different languages

## 🚢 Release Checklist

Before releasing a new version:

- [ ] All tests pass (`⌘U`)
- [ ] No compiler warnings
- [ ] Code formatted consistently
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number bumped
- [ ] Tested on physical device
- [ ] Localization complete
- [ ] Performance acceptable
- [ ] No memory leaks

## 📞 Getting Help

### Resources
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)

### Project Documentation
- `README.md` - Project overview and features
- `ARCHITECTURE.md` - Detailed architecture explanation
- `TESTING_GUIDE.md` - Manual testing procedures
- `CHANGELOG.md` - Version history

## 🎓 Learning Path

### For New Developers

1. **Start with Views**
   - Read `ContentView.swift`
   - Understand tab navigation
   - Explore `HomeContent.swift`

2. **Understand Data Flow**
   - Check `HomeContentViewModel`
   - Look at repository pattern
   - Examine SwiftData models

3. **Try Making Changes**
   - Add a new localized string
   - Modify a view layout
   - Add a repository method

4. **Write Tests**
   - Study existing test files
   - Write test for new feature
   - Run tests and fix issues

### Advanced Topics
- Custom SwiftData migrations
- Performance optimization with Instruments
- Advanced SwiftUI animations
- Accessibility improvements

## 💡 Pro Tips

1. **Use Xcode Previews**: Faster than running simulator
2. **Break Down Views**: Keep body under 10 lines when possible
3. **Test Early**: Write tests as you code
4. **Document Why**: Code shows what, comments explain why
5. **Use TODO**: Mark incomplete work with `// TODO:`
6. **Commit Often**: Small, focused commits are better

## 🐛 Known Issues & Workarounds

### SwiftData Preview Crashes
**Issue**: Preview crashes with SwiftData
**Workaround**: Use in-memory container in preview

```swift
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: config)
    return MyView().modelContainer(container)
}
```

---

**Happy Coding! 🎉**

For questions or issues, refer to the documentation or reach out to the team.

---

**Last Updated**: April 13, 2026  
**Version**: 1.0 MVP
