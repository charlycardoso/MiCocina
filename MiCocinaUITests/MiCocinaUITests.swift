//
//  MiCocinaUITests.swift
//  MiCocinaUITests
//
//  Created by Carlos Cardoso on 28/04/26.
//
//  End-to-end UI tests that replicate real human flows for each app module.
//  The app is launched with --uitesting so it uses an in-memory SwiftData
//  store, giving every test a completely clean slate.
//

import XCTest

// MARK: - Base Test Case

/// Shared setup, teardown, and helper flows used by all UI test suites.
class MiCocinaUITestCase: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // In-memory store + force English locale for reliable label matching
        app.launchArguments = [
            "--uitesting",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    // MARK: - Element helpers

    /// Finds the first element with the given accessibility identifier across all element types.
    func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    /// Waits for an element to exist and asserts it does.
    @discardableResult
    func waitAndAssert(
        _ id: String,
        timeout: TimeInterval = 5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCUIElement {
        let el = element(id)
        XCTAssertTrue(
            el.waitForExistence(timeout: timeout),
            "Expected element '\(id)' to exist",
            file: file,
            line: line
        )
        return el
    }

    // MARK: - Reusable flows

    /// Creates a new recipe via the Home tab.
    /// The recipe meal type is "Other" (the default in NewRecipeView).
    @discardableResult
    func createRecipe(name: String = "Test Recipe", ingredient: String = "Eggs") -> Bool {
        app.tabBars.buttons["contentView.homeTab"].tap()

        guard app.buttons["homeContent.addButton"].waitForExistence(timeout: 5) else { return false }
        app.buttons["homeContent.addButton"].tap()

        let nameField = app.textFields["newRecipe.recipeNameField"]
        guard nameField.waitForExistence(timeout: 5) else { return false }
        nameField.tap()
        nameField.typeText(name)

        let ingredientField = app.textFields["newRecipe.ingredientTextField"]
        ingredientField.tap()
        ingredientField.typeText(ingredient)
        app.buttons["newRecipe.addIngredientButton"].tap()

        app.buttons["newRecipe.saveButton"].tap()

        // Sheet dismisses; HomeContent refreshes and shows the recipe list
        return app.scrollViews["homeContent.recipeList"].waitForExistence(timeout: 5)
    }

    /// Adds an ingredient to the pantry via the My Ingredients tab.
    @discardableResult
    func addIngredientToPantry(name: String = "Tomato") -> Bool {
        app.tabBars.buttons["contentView.pantryTab"].tap()

        guard app.buttons["myPantry.addButton"].waitForExistence(timeout: 5) else { return false }
        app.buttons["myPantry.addButton"].tap()

        let nameField = app.textFields["addIngredient.nameField"]
        guard nameField.waitForExistence(timeout: 5) else { return false }
        nameField.tap()
        nameField.typeText(name)
        app.buttons["addIngredient.saveButton"].tap()

        // Dismiss the success alert — this triggers sheet dismissal
        let okButton = app.alerts.buttons["OK"]
        guard okButton.waitForExistence(timeout: 5) else { return false }
        okButton.tap()

        // Wait for the ingredient list to appear after the refresh delay
        return app.tables["myPantry.ingredientList"].waitForExistence(timeout: 5)
    }

    /// Adds a recipe to today's plan via the Planner tab.
    /// Requires at least one "Other" meal-type recipe to already exist.
    @discardableResult
    func addRecipeToTodayInPlanner() -> Bool {
        app.tabBars.buttons["contentView.plannerTab"].tap()

        guard app.buttons["planner.addButton"].waitForExistence(timeout: 5) else { return false }
        app.buttons["planner.addButton"].tap()

        let picker = app.segmentedControls["addRecipes.mealTypePicker"]
        guard picker.waitForExistence(timeout: 5) else { return false }
        picker.buttons["Other"].tap()

        let recipeRow = app.cells.matching(
            NSPredicate(format: "identifier BEGINSWITH 'addRecipes.recipeRow.'")
        ).firstMatch
        guard recipeRow.waitForExistence(timeout: 5) else { return false }
        recipeRow.tap()

        let addButton = app.buttons["addRecipes.addButton"]
        guard addButton.waitForExistence(timeout: 3) else { return false }
        addButton.tap()

        return app.scrollViews["planner.recipesList"].waitForExistence(timeout: 5)
    }
}

// MARK: - App Launch

final class AppLaunchUITests: MiCocinaUITestCase {

    func testAppLaunchWithoutCrash() {
        // If the app launched and the tab bar is visible, the launch succeeded
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
    }

    func testAllTabsArePresent() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        XCTAssertTrue(tabBar.buttons["contentView.homeTab"].exists)
        XCTAssertTrue(tabBar.buttons["contentView.pantryTab"].exists)
        XCTAssertTrue(tabBar.buttons["contentView.plannerTab"].exists)
        XCTAssertTrue(tabBar.buttons["contentView.shoppingListTab"].exists)
    }
}

// MARK: - Pantry Module

final class PantryUITests: MiCocinaUITestCase {

    /// Navigate to the pantry tab and confirm the empty-state message appears.
    func testPantryShowsEmptyStateInitially() {
        app.tabBars.buttons["contentView.pantryTab"].tap()
        waitAndAssert("myPantry.emptyState")
    }

    /// Full "add ingredient" flow: open sheet → type name → save → verify in list.
    func testAddIngredient() {
        XCTAssertTrue(addIngredientToPantry(name: "Tomato"))

        let row = app.cells.matching(
            NSPredicate(format: "identifier BEGINSWITH 'myPantry.ingredientRow.'")
        ).firstMatch
        XCTAssertTrue(row.exists)
    }

    /// Tap an ingredient → open detail view → tap Edit → change name → save.
    func testEditIngredientName() {
        XCTAssertTrue(addIngredientToPantry(name: "Onion"))

        // Tap the row to open IngredientDetailView
        let row = app.cells.matching(
            NSPredicate(format: "identifier BEGINSWITH 'myPantry.ingredientRow.'")
        ).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        // Tap Edit button
        let editButton = app.buttons["ingredientDetail.editButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()

        // Clear and retype the name
        let nameField = app.textFields["ingredientDetail.nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.clearAndTypeText("Garlic")

        // Save
        app.buttons["ingredientDetail.saveButton"].tap()

        // Dismiss success alert
        let okButton = app.alerts.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5))
        okButton.tap()

        // Pantry list is visible again after dismissal
        XCTAssertTrue(app.tables["myPantry.ingredientList"].waitForExistence(timeout: 5))
    }

    /// Open ingredient detail → tap Delete in the Actions section → confirm.
    func testDeleteIngredientFromDetailView() {
        XCTAssertTrue(addIngredientToPantry(name: "Pepper"))

        let row = app.cells.matching(
            NSPredicate(format: "identifier BEGINSWITH 'myPantry.ingredientRow.'")
        ).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        let deleteButton = app.buttons["ingredientDetail.deleteButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()

        // Confirmation dialog — tap the destructive Delete option
        let confirmDelete = app.buttons["Delete"]
        XCTAssertTrue(confirmDelete.waitForExistence(timeout: 5))
        confirmDelete.tap()

        // Pantry should now show the empty state
        XCTAssertTrue(app.staticTexts["myPantry.emptyState"].waitForExistence(timeout: 5))
    }

    /// Swipe left on an ingredient row → tap the destructive Delete swipe action → confirm alert.
    func testDeleteIngredientWithSwipeAction() {
        XCTAssertTrue(addIngredientToPantry(name: "Basil"))

        let row = app.cells.matching(
            NSPredicate(format: "identifier BEGINSWITH 'myPantry.ingredientRow.'")
        ).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))

        // Reveal swipe actions
        row.swipeLeft()

        let swipeDeleteButton = app.buttons["Delete"]
        XCTAssertTrue(swipeDeleteButton.waitForExistence(timeout: 3))
        swipeDeleteButton.tap()

        // The alert asks for confirmation — dismiss it
        let alertConfirm = app.alerts.buttons.matching(
            NSPredicate(format: "label != 'Cancel'")
        ).firstMatch
        if alertConfirm.waitForExistence(timeout: 3) {
            alertConfirm.tap()
        }

        XCTAssertTrue(app.staticTexts["myPantry.emptyState"].waitForExistence(timeout: 5))
    }
}

// MARK: - Recipes Module

final class RecipesUITests: MiCocinaUITestCase {

    /// Home tab should show the empty state on a fresh in-memory store.
    func testRecipesShowsEmptyStateInitially() {
        waitAndAssert("homeContent.emptyState")
    }

    /// Full "create recipe" flow: open sheet → fill name → add ingredient → save.
    func testCreateNewRecipe() {
        XCTAssertTrue(createRecipe(name: "Pasta Carbonara", ingredient: "Eggs"))

        let recipeRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'homeContent.recipeRow.'")
        ).firstMatch
        XCTAssertTrue(recipeRow.exists)
    }

    /// Tap a recipe row → RecipeDetailView opens → navigate back.
    func testNavigateToRecipeDetailAndBack() {
        XCTAssertTrue(createRecipe(name: "Omelette", ingredient: "Eggs"))

        let recipeRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'homeContent.recipeRow.'")
        ).firstMatch
        XCTAssertTrue(recipeRow.waitForExistence(timeout: 5))
        recipeRow.tap()

        waitAndAssert("recipeDetail.cookingStatusSection")

        // Navigate back using the first navigation bar back button
        app.navigationBars.buttons.firstMatch.tap()

        XCTAssertTrue(app.scrollViews["homeContent.recipeList"].waitForExistence(timeout: 5))
    }

    /// Navigate to recipe detail → delete via the "…" menu → recipe is removed.
    func testDeleteRecipeFromDetail() {
        XCTAssertTrue(createRecipe(name: "Gazpacho", ingredient: "Tomato"))

        let recipeRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'homeContent.recipeRow.'")
        ).firstMatch
        XCTAssertTrue(recipeRow.waitForExistence(timeout: 5))
        recipeRow.tap()

        waitAndAssert("recipeDetail.cookingStatusSection")

        // Open the "…" menu in the navigation bar
        app.navigationBars.buttons["ellipsis.circle"].tap()
        let deleteMenuItem = app.buttons["Delete"]
        XCTAssertTrue(deleteMenuItem.waitForExistence(timeout: 3))
        deleteMenuItem.tap()

        // Confirmation alert
        let alertDelete = app.alerts.buttons["Delete"]
        XCTAssertTrue(alertDelete.waitForExistence(timeout: 3))
        alertDelete.tap()

        // Home screen shows the empty state after deletion
        XCTAssertTrue(app.staticTexts["homeContent.emptyState"].waitForExistence(timeout: 5))
    }

    /// Create a recipe → mark it as favorite from the detail view.
    func testMarkRecipeAsFavorite() {
        XCTAssertTrue(createRecipe(name: "Salad", ingredient: "Lettuce"))

        let recipeRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'homeContent.recipeRow.'")
        ).firstMatch
        XCTAssertTrue(recipeRow.waitForExistence(timeout: 5))
        recipeRow.tap()

        waitAndAssert("recipeDetail.cookingStatusSection")

        app.buttons["recipeDetail.favoriteButton"].tap()

        // Confirm in the alert
        let confirmButton = app.alerts.buttons["Confirm"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()

        // Still on detail view with no crash
        XCTAssertTrue(app.buttons["recipeDetail.favoriteButton"].waitForExistence(timeout: 3))
    }
}

// MARK: - Planner Module

final class PlannerUITests: MiCocinaUITestCase {

    /// Planner starts with the empty state for today.
    func testPlannerShowsEmptyStateInitially() {
        app.tabBars.buttons["contentView.plannerTab"].tap()
        waitAndAssert("planner.emptyState")
    }

    /// Create a recipe → add it to today's plan → planner shows the recipe.
    func testAddRecipeToPlannerDay() {
        XCTAssertTrue(createRecipe(name: "Paella", ingredient: "Arroz"))
        XCTAssertTrue(addRecipeToTodayInPlanner())

        XCTAssertTrue(app.scrollViews["planner.recipesList"].exists)
    }

    /// Create recipe → add to today → tap Move → confirm move to tomorrow → today is empty.
    func testMoveRecipeToAnotherDay() {
        XCTAssertTrue(createRecipe(name: "Ramen", ingredient: "Noodles"))
        XCTAssertTrue(addRecipeToTodayInPlanner())

        // Find and tap the Move button (date is pre-set to tomorrow in MoveRecipeView)
        let moveButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'planner.recipeRowView.moveButton.'")
        ).firstMatch
        XCTAssertTrue(moveButton.waitForExistence(timeout: 5))
        moveButton.tap()

        // MoveRecipeView — tap the confirm button without changing the date
        let confirmMoveButton = app.buttons["moveRecipe.moveButton"]
        XCTAssertTrue(confirmMoveButton.waitForExistence(timeout: 5))
        confirmMoveButton.tap()

        // Today's planner is now empty
        XCTAssertTrue(element("planner.emptyState").waitForExistence(timeout: 5))
    }

    /// Create recipe → add to today → delete from planner → today is empty.
    func testDeleteRecipeFromPlannerDay() {
        XCTAssertTrue(createRecipe(name: "Soup", ingredient: "Carrot"))
        XCTAssertTrue(addRecipeToTodayInPlanner())

        let deleteButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'planner.recipeRowView.deleteButton.'")
        ).firstMatch
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()

        XCTAssertTrue(element("planner.emptyState").waitForExistence(timeout: 5))
    }
}

// MARK: - Shopping List Module

final class ShoppingListUITests: MiCocinaUITestCase {

    /// Shopping list starts empty.
    func testShoppingListShowsEmptyStateInitially() {
        app.tabBars.buttons["contentView.shoppingListTab"].tap()
        waitAndAssert("shoppingList.emptyState")
    }

    /// Add an item manually via the + button → item appears in the "To Buy" section.
    func testAddItemManuallyToShoppingList() {
        app.tabBars.buttons["contentView.shoppingListTab"].tap()

        // Tap the simple + button (visible when list is empty)
        let addButton = app.buttons["shoppingList.toolbar.addButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Sheet: type ingredient name
        let ingredientField = app.textFields["shoppingList.add.ingredientField"]
        XCTAssertTrue(ingredientField.waitForExistence(timeout: 5))
        ingredientField.tap()
        ingredientField.typeText("Milk")

        app.buttons["shoppingList.add.addButton"].tap()

        // Item appears in the unbought section
        let unboughtRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'shoppingList.unboughtRow.'")
        ).firstMatch
        XCTAssertTrue(unboughtRow.waitForExistence(timeout: 5))
    }

    /// Add an item → tap its toggle → item moves to the "Bought" section.
    func testToggleItemAsBought() {
        app.tabBars.buttons["contentView.shoppingListTab"].tap()
        app.buttons["shoppingList.toolbar.addButton"].tap()

        let field = app.textFields["shoppingList.add.ingredientField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Cheese")
        app.buttons["shoppingList.add.addButton"].tap()

        // Toggle the item as bought
        let toggleButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'shoppingList.toggleButton.'")
        ).firstMatch
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5))
        toggleButton.tap()

        // Item should now appear in the bought section
        let boughtRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'shoppingList.boughtRow.'")
        ).firstMatch
        XCTAssertTrue(boughtRow.waitForExistence(timeout: 5))
    }

    /// Add item → open "…" menu → Clear List → confirm → empty state shown.
    func testClearShoppingList() {
        app.tabBars.buttons["contentView.shoppingListTab"].tap()
        app.buttons["shoppingList.toolbar.addButton"].tap()

        let field = app.textFields["shoppingList.add.ingredientField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Bread")
        app.buttons["shoppingList.add.addButton"].tap()

        // List has items → toolbar shows the "…" menu
        let menuButton = app.buttons["shoppingList.toolbar.menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5))
        menuButton.tap()

        let clearListOption = app.buttons["Clear List"]
        XCTAssertTrue(clearListOption.waitForExistence(timeout: 3))
        clearListOption.tap()

        // Confirmation dialog
        let confirmClear = app.buttons["Clear All Items"]
        XCTAssertTrue(confirmClear.waitForExistence(timeout: 3))
        confirmClear.tap()

        waitAndAssert("shoppingList.emptyState")
    }

    /// Add item → toggle as bought → swipe bought row → Add to Pantry → list is empty.
    func testAddBoughtItemToPantry() {
        app.tabBars.buttons["contentView.shoppingListTab"].tap()
        app.buttons["shoppingList.toolbar.addButton"].tap()

        let field = app.textFields["shoppingList.add.ingredientField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Butter")
        app.buttons["shoppingList.add.addButton"].tap()

        // Toggle as bought
        let toggleButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'shoppingList.toggleButton.'")
        ).firstMatch
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5))
        toggleButton.tap()

        // Swipe bought row to reveal "Add to Pantry"
        let boughtRow = app.cells.matching(
            NSPredicate(format: "identifier BEGINSWITH 'shoppingList.boughtRow.'")
        ).firstMatch
        XCTAssertTrue(boughtRow.waitForExistence(timeout: 5))
        boughtRow.swipeLeft()

        let addToPantryButton = app.buttons["Add to Pantry"]
        XCTAssertTrue(addToPantryButton.waitForExistence(timeout: 3))
        addToPantryButton.tap()

        waitAndAssert("shoppingList.emptyState")
    }
}

// MARK: - XCUIElement helpers

private extension XCUIElement {
    /// Clears existing text and types new text into a text field.
    func clearAndTypeText(_ text: String) {
        guard let currentValue = value as? String, !currentValue.isEmpty else {
            typeText(text)
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(deleteString)
        typeText(text)
    }
}
