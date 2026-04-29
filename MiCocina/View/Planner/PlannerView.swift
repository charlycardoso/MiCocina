//
//  PlannerView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import SwiftUI
import SwiftData

/// Represents a single day in the week planner view.
///
/// Contains the formatted day initial (e.g., "L" for Lunes/Monday),
/// the day number (e.g., "15"), and the full date for data operations.
struct WeekDay {
    /// Single-letter initial of the day name (e.g., "L", "M", "M")
    let initial: String
    
    /// Two-digit day number (e.g., "01", "15", "31")
    let dayNumber: String
    
    /// The full date object for this day
    let date: Date
}

/// Main view for the meal planner feature.
///
/// `PlannerView` allows users to plan their meals for each day of the week.
/// It provides a week calendar selector showing the current week, and displays
/// all planned recipes grouped by meal type (breakfast, lunch, dinner, other).
///
/// Key features:
/// - Interactive week calendar with today highlighting
/// - Recipe grouping by meal type
/// - Add recipes to specific days
/// - Move recipes between days
/// - Delete recipes from days
/// - Navigate to recipe details
/// - Empty state with call-to-action
///
/// The view integrates with `PlannerViewModel` for data management and uses
/// SwiftData for persistence through the model context.
///
/// - Example:
/// ```swift
/// let viewModel = PlannerViewModel(context: modelContext)
/// PlannerView(viewModel: viewModel)
/// ```
struct PlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var viewModel: PlannerViewModel
    @State private var showAddRecipesSheet: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var selectedRecipeForMove: RecipeViewData?

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var currentWeekOffset: Int = 0
    @State private var showDatePicker: Bool = false
    @State private var weekScrollPosition: Int? = Self.todayWeekOffset

    private static let weekRange = -12...24  // 3 months back, 6 months forward
    private static let todayWeekOffset = 0

    private var currentMonthYearLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate).capitalized
    }

    /// Returns the week offset (relative to the current week) for the week containing the given date.
    private func weekOffset(for date: Date) -> Int {
        let calendar = Calendar(identifier: .iso8601)
        let todayStart = calendar.startOfWeek(for: Date())
        let targetStart = calendar.startOfWeek(for: date)
        return calendar.dateComponents([.weekOfYear], from: todayStart, to: targetStart).weekOfYear ?? 0
    }

    /// Initializes the planner view with a view model.
    ///
    /// - Parameter viewModel: The view model managing planner data and operations
    init(viewModel: PlannerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month label — tapping opens full calendar picker
                Button {
                    showDatePicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text(currentMonthYearLabel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Scrollable Week Planner with Paging
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Self.weekRange, id: \.self) { offset in
                                WeekPlannerView(weekOffset: offset)
                                    .frame(width: UIScreen.main.bounds.width)
                                    .id(offset)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $weekScrollPosition)
                    .frame(height: 90)
                    .onAppear {
                        proxy.scrollTo(Self.todayWeekOffset, anchor: .center)
                    }
                    .onChange(of: selectedDate) { _, newDate in
                        let offset = weekOffset(for: newDate)
                        let clamped = max(Self.weekRange.lowerBound, min(Self.weekRange.upperBound, offset))
                        withAnimation {
                            proxy.scrollTo(clamped, anchor: .center)
                        }
                    }

                }
                .sheet(isPresented: $showDatePicker) {
                    DatePickerSheet(selectedDate: $selectedDate, isPresented: $showDatePicker)
                        .presentationDetents([.medium])
                }

                Divider()

                if viewModel.recipeGroups.isEmpty {
                    emptyStateView
                } else {
                    recipesListView
                }
            }
            .navigationTitle(NSLocalizedString("planner.title", comment: "Navigation title for the planner view"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("planner.goToToday", comment: "Button to scroll planner to today")) {
                        withAnimation {
                            selectedDate = Date()
                            weekScrollPosition = Self.todayWeekOffset
                        }
                    }
                    .font(.subheadline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddRecipesSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("planner.addButton")
                }
            }
            .sheet(isPresented: $showAddRecipesSheet) {
                refreshRecipes()
            } content: {
                AddRecipesToDayView(
                    viewModel: viewModel,
                    selectedDate: selectedDate,
                    onSave: {
                        refreshRecipes()
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedRecipeForMove) { recipe in
                MoveRecipeView(
                    viewModel: viewModel,
                    recipe: recipe,
                    currentDate: selectedDate,
                    onMove: { newDate in
                        moveRecipe(recipe, to: newDate)
                    }
                )
                .onDisappear {
                    refreshRecipes()
                }
            }
            .alert(NSLocalizedString("common.information", comment: "Alert title"), isPresented: $showAlert) {
                Button(NSLocalizedString("common.ok", comment: "OK button")) { }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: selectedDate) { _, _ in
                refreshRecipes()
            }
            .onAppear {
                refreshRecipes()
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(NSLocalizedString("planner.emptyState.title", comment: "Title when no recipes are planned"))
                .font(.title3)
                .fontWeight(.medium)
            
            Text(NSLocalizedString("planner.emptyState.message", comment: "Message prompting user to add recipes"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .accessibilityIdentifier("planner.emptyState")
    }
    
    @ViewBuilder
    private var recipesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.recipeGroups, id: \.mealType) { group in
                    Section {
                        ForEach(group.recipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(
                                    recipe: recipe,
                                    viewModel: HomeContentViewModel(context: modelContext)
                                )
                            } label: {
                                RecipeRowView(
                                    recipe: recipe,
                                    onMove: {
                                        selectedRecipeForMove = recipe
                                    },
                                    onDelete: {
                                        deleteRecipe(recipe)
                                    }
                                )
                                .glassEffect(.identity)
                            }
                            .accessibilityIdentifier("planner.recipeRow.\(recipe.id.uuidString)")
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                    } header: {
                        HStack {
                            Text(mealTypeTitle(group.mealType))
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text("\(group.recipes.count)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                    }
                }
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .accessibilityIdentifier("planner.recipesList")
    }

    @ViewBuilder
    private func WeekPlannerView(weekOffset: Int) -> some View {
        let weekPlanning = currentWeekDaysFormatted(weekOffset: weekOffset)
        HStack {
            ForEach(Array(weekPlanning), id: \.date) { day in
                let isToday = Calendar.current.isDateInToday(day.date)
                let isDaySelected = Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text(day.initial)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(day.dayNumber)
                        .foregroundStyle(isDaySelected ? .white : .primary)
                        .fontWeight(.medium)
                        .frame(width: 40, height: 40)
                        .background {
                            Circle()
                                .fill(isDaySelected ? Color.cPrimary : Color.cPrimary.opacity(0.1))
                        }
                        .overlay {
                            if isToday && !isDaySelected {
                                Circle()
                                    .stroke(Color.cPrimary, lineWidth: 2)
                            }
                        }
                        .accessibilityIdentifier("planner.weekDay.\(day.dayNumber)")
                        .onTapGesture {
                            withAnimation(.interactiveSpring) {
                                selectedDate = day.date
                            }
                        }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Helper Methods
    
    /// Refreshes the recipe groups for the currently selected date.
    private func refreshRecipes() {
        viewModel.fetchRecipeGroups(with: selectedDate)
    }
    
    /// Deletes a recipe from the selected day's plan.
    ///
    /// If this is the last recipe for the day, the entire planner entry is removed.
    /// Otherwise, the recipe is filtered out and the plan is updated.
    ///
    /// - Parameter recipe: The recipe to delete from the plan
    private func deleteRecipe(_ recipe: RecipeViewData) {
        do {
            // Get current planner data
            guard var plannerData = viewModel.get(by: selectedDate) else { return }
            
            // Remove the recipe from the list
            let updatedRecipes = plannerData.recipes.filter { $0.id != recipe.id }
            
            // If no recipes left, remove the planner day
            if updatedRecipes.isEmpty {
                try viewModel.removePlanner(day: selectedDate)
            } else {
                // Update with filtered recipes
                plannerData = PlannerData(id: plannerData.id, day: selectedDate, recipes: updatedRecipes)
                try viewModel.save(plannerData)
            }
            
            refreshRecipes()
        } catch {
            alertMessage = String(format: NSLocalizedString("planner.error.deleteRecipe", comment: "Error deleting recipe"), error.localizedDescription)
            showAlert = true
        }
    }
    
    /// Moves a recipe from the current selected date to a new date.
    ///
    /// - Parameters:
    ///   - recipe: The recipe to move
    ///   - newDate: The destination date for the recipe
    private func moveRecipe(_ recipe: RecipeViewData, to newDate: Date) {
        do {
            try viewModel.movePlanner(recipeID: recipe.id, from: selectedDate, to: newDate)
            selectedRecipeForMove = nil
            refreshRecipes()
        } catch {
            alertMessage = String(format: NSLocalizedString("planner.error.moveRecipe", comment: "Error moving recipe"), error.localizedDescription)
            showAlert = true
        }
    }
    
    /// Returns the localized display name for a meal type.
    ///
    /// - Parameter mealType: The meal type to get the title for
    /// - Returns: Localized string for the meal type
    private func mealTypeTitle(_ mealType: MealType) -> String {
        switch mealType {
        case .breakFast:
            return NSLocalizedString("mealType.breakfast", comment: "Breakfast meal type")
        case .lunch:
            return NSLocalizedString("mealType.lunch", comment: "Lunch meal type")
        case .dinner:
            return NSLocalizedString("mealType.dinner", comment: "Dinner meal type")
        case .other:
            return NSLocalizedString("mealType.other", comment: "Other meal type")
        }
    }

    /// Generates an array of formatted week days for the current week.
    ///
    /// The week starts on Monday following ISO 8601 standard. Each day includes
    /// a single-letter initial, two-digit day number, and the full date.
    ///
    /// - Parameter weekOffset: The number of weeks to offset from the current week (e.g., -1 for previous week, 0 for current, 1 for next)
    /// - Returns: Array of `WeekDay` objects representing the specified week
    func currentWeekDaysFormatted(weekOffset: Int = 0) -> [WeekDay] {
        let calendar = Calendar(identifier: .iso8601)
        let today = Date()

        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
              let offsetWeekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek) else {
            return []
        }

        let formatterInitial = DateFormatter()
        formatterInitial.locale = Locale.current
        formatterInitial.dateFormat = "EEEEE" // inicial del día

        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "dd"

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: offsetWeekStart) else {
                return nil
            }

            return WeekDay(
                initial: formatterInitial.string(from: date).uppercased(),
                dayNumber: formatterDay.string(from: date),
                date: date
            )
        }
    }
}

// MARK: - DatePickerSheet

/// A sheet that presents a graphical date picker for navigating to a specific week.
private struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(String(localized: "planner.datePicker.title"))
                    .font(.headline)
                Spacer()
                Button(String(localized: "common.done")) {
                    isPresented = false
                }
                .fontWeight(.semibold)
            }
            .padding(.horizontal, 32)

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal)
            .onChange(of: selectedDate) { _, _ in
                isPresented = false
            }

            Spacer()
        }
        .padding(.top, 32)
    }
}

// MARK: - Calendar Extension

private extension Calendar {
    /// Returns the start of the ISO week (Monday) containing the given date.
    func startOfWeek(for date: Date) -> Date {
        dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }
}

#Preview {
    let schema = Schema([
        SDPantryItem.self,
        SDRecipe.self,
        SDIngredient.self,
        SDRecipeIngredient.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let mockVM = PlannerViewModel(context: container.mainContext)
    mockVM.recipeGroups = PlannerViewModel.mockForPreview()
    
    return PlannerView(viewModel: mockVM)
        .modelContainer(container)
}


