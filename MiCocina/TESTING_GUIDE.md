# MiCocina Testing Guide

## Overview

This document provides guidance for testing MiCocina MVP on physical devices. It covers manual testing procedures, test cases, and expected behaviors for all major features.

## Prerequisites

### Device Requirements
- iOS 17.0 or later
- Physical iOS device (iPhone or iPad)
- Development profile configured in Xcode

### Setup Steps
1. Connect your iOS device via USB
2. Open MiCocina project in Xcode
3. Select your device from the scheme selector
4. Build and run (⌘R)
5. Trust the developer certificate on device if prompted

## Feature Testing Checklist

### 1. Home Module (Recipe Discovery)

#### Initial State
- [ ] App launches successfully
- [ ] Home tab is selected by default
- [ ] Empty state message displays when no recipes exist
- [ ] "+" button visible in top-right toolbar

#### Adding a Recipe
- [ ] Tap "+" button opens New Recipe form
- [ ] Can enter recipe name
- [ ] Can select meal type (Breakfast, Lunch, Dinner, Other)
- [ ] Can add ingredients to recipe
- [ ] Can set ingredient quantities
- [ ] Save button creates recipe
- [ ] New recipe appears in appropriate meal type section
- [ ] Recipe list is sorted correctly

#### Viewing Recipes
- [ ] Recipes grouped by meal type (Breakfast, Lunch, Dinner, Other)
- [ ] Section headers display localized meal type names
- [ ] Each recipe shows name
- [ ] "Can Cook" badge shows green for cookable recipes
- [ ] "Cannot Cook" badge shows orange for non-cookable recipes
- [ ] Favorite recipes show heart icon

#### Recipe Details
- [ ] Tap recipe navigates to detail view
- [ ] Detail view shows complete ingredient list
- [ ] Detail view shows quantities needed
- [ ] Detail view indicates missing ingredients
- [ ] Can mark recipe as favorite
- [ ] Can edit recipe details
- [ ] Can delete recipe with confirmation
- [ ] Back button returns to home

#### Search
- [ ] Search bar accessible from home screen
- [ ] Typing filters recipes in real-time
- [ ] Search works across all meal types
- [ ] Clear button resets search
- [ ] "No results" message when search finds nothing

### 2. My Pantry Module

#### Initial State
- [ ] My Pantry tab accessible from bottom tabs
- [ ] Empty state message when pantry is empty
- [ ] "+" button visible in toolbar

#### Adding Ingredients
- [ ] Tap "+" opens Add Ingredient form
- [ ] Can enter ingredient name
- [ ] Can set quantity
- [ ] Duplicate ingredient names prevented
- [ ] New ingredient appears in list
- [ ] List alphabetically sorted

#### Viewing Pantry
- [ ] Ingredients display in alphabetical order
- [ ] Each row shows ingredient name and quantity
- [ ] Quantity indicator is red when ≤3
- [ ] Quantity indicator is green when >3
- [ ] Quantities display correctly

#### Managing Ingredients
- [ ] Tap ingredient opens detail view
- [ ] Can edit ingredient name
- [ ] Can edit quantity
- [ ] Changes save correctly
- [ ] Swipe left reveals actions
- [ ] "Buy" action available (prepared for future)
- [ ] "Delete" action shows confirmation alert
- [ ] Confirming delete removes ingredient
- [ ] Canceling delete keeps ingredient

#### Search
- [ ] Search bar filters ingredients
- [ ] Results update as you type
- [ ] Case-insensitive search
- [ ] Partial matches work
- [ ] "No results" message when appropriate

### 3. Planner Module

#### Initial State
- [ ] Planner tab accessible from bottom tabs
- [ ] Current week displays by default
- [ ] Week navigation controls present (< Week >)
- [ ] Days of week shown with dates
- [ ] Empty days show helpful message

#### Planning Meals
- [ ] Tap empty day opens recipe selection
- [ ] Available recipes listed
- [ ] Can select recipe to add to day
- [ ] Recipe appears on selected day
- [ ] Can add multiple recipes to same day
- [ ] Each recipe displays correctly

#### Week Navigation
- [ ] ">" button advances to next week
- [ ] "<" button goes to previous week
- [ ] Week label updates correctly
- [ ] Can navigate multiple weeks forward/backward
- [ ] Planned meals persist when changing weeks

#### Managing Planned Meals
- [ ] Tap planned recipe shows options
- [ ] Can view recipe details from planner
- [ ] Can move recipe to different day
- [ ] Can remove recipe from day
- [ ] Removal shows confirmation
- [ ] Changes reflect immediately

#### Recipe Movement
- [ ] Move recipe option available
- [ ] Can select destination day
- [ ] Recipe removed from original day
- [ ] Recipe added to destination day
- [ ] Move operation completes successfully

### 4. Shopping List Module

#### Initial State
- [ ] Shopping List tab accessible
- [ ] Empty state when no items
- [ ] "+" button to add items manually

#### Automatic List Generation
- [ ] Items automatically added from planned recipes
- [ ] Only missing ingredients appear
- [ ] Quantities calculated correctly
- [ ] Ingredients from pantry excluded
- [ ] Multiple recipes combine ingredient quantities

#### Manual Item Addition
- [ ] Tap "+" opens add item form
- [ ] Can enter item name
- [ ] Can set quantity
- [ ] New item appears in list
- [ ] Manual and auto items both shown

#### Managing Items
- [ ] Each item has checkbox
- [ ] Tap checkbox marks item as purchased
- [ ] Checked items move to bottom (or separate section)
- [ ] Visual differentiation for checked items
- [ ] Can uncheck items
- [ ] Can remove items from list
- [ ] Removal shows confirmation if needed

#### Search
- [ ] Search filters shopping list items
- [ ] Real-time filtering
- [ ] Works for checked and unchecked items

### 5. Navigation & UI

#### Tab Navigation
- [ ] All four tabs accessible
- [ ] Selected tab highlighted
- [ ] Tab icons display correctly
- [ ] Tab labels localized properly
- [ ] Switching tabs preserves state
- [ ] Each tab has independent navigation

#### General UI
- [ ] No crashes or freezes
- [ ] Smooth scrolling in lists
- [ ] Responsive tap targets
- [ ] Animations smooth
- [ ] Alerts display properly
- [ ] Sheets present/dismiss correctly
- [ ] Status bar visible
- [ ] Safe area respected on all devices

### 6. Data Persistence

#### Saving Data
- [ ] Recipes persist after app restart
- [ ] Pantry ingredients persist
- [ ] Planned meals persist
- [ ] Shopping list persists
- [ ] All quantities persist correctly
- [ ] Recipe favorites persist

#### Updating Data
- [ ] Recipe edits save
- [ ] Ingredient quantity changes save
- [ ] Recipe movements save
- [ ] Shopping list changes save
- [ ] No data loss during updates

#### Deleting Data
- [ ] Deleted recipes don't reappear
- [ ] Deleted ingredients removed permanently
- [ ] Removed planned meals stay removed
- [ ] Shopping list removals persist

### 7. Recipe Matching Logic

#### Cookability Detection
- [ ] Recipe with all ingredients marked "Can Cook"
- [ ] Recipe missing 1-3 ingredients marked "Can Cook" (green)
- [ ] Recipe missing >3 ingredients marked "Cannot Cook" (orange)
- [ ] Status updates when pantry changes

#### Dynamic Updates
- [ ] Adding ingredient updates recipe status
- [ ] Removing ingredient updates recipe status
- [ ] Changes reflect in real-time
- [ ] Home screen refreshes appropriately

### 8. Localization

#### Language Support
- [ ] All navigation titles localized
- [ ] Tab labels localized
- [ ] Meal type labels localized
- [ ] Empty state messages localized
- [ ] Alert messages localized
- [ ] Button labels localized

#### Testing Different Languages
1. Go to iOS Settings > General > Language & Region
2. Change device language
3. Relaunch app
4. Verify all strings display in new language

### 9. Edge Cases & Error Handling

#### Edge Cases to Test
- [ ] Very long recipe names (truncation)
- [ ] Very long ingredient names
- [ ] Recipe with 0 ingredients
- [ ] Recipe with 50+ ingredients
- [ ] Pantry with 100+ ingredients
- [ ] Empty search results
- [ ] Rapid tab switching
- [ ] Rapid button tapping
- [ ] Network airplane mode (should work fine)

#### Error Handling
- [ ] Deleting non-existent item shows error
- [ ] Duplicate ingredient names prevented
- [ ] Invalid data entry rejected
- [ ] Error messages are user-friendly
- [ ] Errors don't crash app
- [ ] Can recover from errors

### 10. Performance

#### Responsiveness
- [ ] App launches in <3 seconds
- [ ] Tab switches instant
- [ ] List scrolling smooth with 100+ items
- [ ] Search results appear instantly
- [ ] No lag when adding items
- [ ] No memory warnings

#### Battery & Resources
- [ ] App doesn't cause excessive battery drain
- [ ] Memory usage reasonable
- [ ] No memory leaks during extended use

## Test Scenarios

### Scenario 1: First Time User
1. Launch app for first time
2. Add 5 ingredients to pantry
3. Create 3 recipes using those ingredients
4. Plan meals for the week
5. Check shopping list
6. **Expected**: Smooth onboarding, empty states helpful, shopping list shows missing ingredients

### Scenario 2: Weekly Meal Planning
1. Start on Monday
2. Plan all meals for the week
3. Check shopping list
4. Mark pantry ingredients as purchased
5. Update pantry quantities
6. Verify recipe statuses update
7. **Expected**: Complete workflow works end-to-end

### Scenario 3: Recipe Discovery
1. Add 10 ingredients to pantry
2. Create 20 recipes with varying ingredient overlap
3. Browse home screen
4. Verify cookable vs non-cookable
5. Search for specific recipes
6. Mark favorites
7. **Expected**: Recipe matching accurate, favorites persist

### Scenario 4: Data Persistence
1. Add recipes, ingredients, and plans
2. Force quit app
3. Relaunch app
4. Verify all data present
5. **Expected**: No data loss

### Scenario 5: Heavy Usage
1. Add 50 ingredients
2. Create 100 recipes
3. Plan entire month
4. Navigate through all features
5. **Expected**: App remains responsive

## Bug Reporting Template

When you find a bug, document it using this template:

```
**Title**: [Short description]

**Severity**: Critical / High / Medium / Low

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [...]

**Expected Result**: [What should happen]

**Actual Result**: [What actually happens]

**Device**: [iPhone/iPad model]

**iOS Version**: [e.g., iOS 17.4]

**App Version**: 1.0 MVP

**Screenshots/Videos**: [If applicable]

**Additional Notes**: [Any other relevant information]
```

## Performance Benchmarks

### Target Metrics
- App launch: <3 seconds
- Tab switch: <200ms
- Search results: <100ms
- Recipe save: <500ms
- List scroll: 60fps

### Monitoring
- Use Xcode Instruments for profiling
- Check Time Profiler for bottlenecks
- Use Allocations for memory leaks
- Verify no retain cycles

## Regression Testing

Before any release, run through all test cases in this document to ensure:
- No features broken
- All workflows functional
- Data integrity maintained
- UI rendering correct
- Performance acceptable

## Automated Testing

### Unit Tests
Run with: `⌘U` in Xcode

Test coverage includes:
- Repository layer
- Mappers
- Domain models
- Use cases

### UI Tests (Future)
- Planned for post-MVP
- Will automate critical user flows

## Sign-Off Checklist

Before declaring MVP ready for release:

- [ ] All feature tests pass
- [ ] All edge cases handled
- [ ] No critical bugs
- [ ] No high-priority bugs
- [ ] Performance acceptable
- [ ] Data persistence verified
- [ ] Localization complete
- [ ] UI polished
- [ ] Unit tests pass
- [ ] Tested on multiple devices
- [ ] Tested on different iOS versions
- [ ] User flow feels natural
- [ ] App icon present
- [ ] Launch screen configured

---

**Testing Coordinator**: Carlos Cardoso  
**Last Updated**: April 13, 2026  
**Version**: 1.0 MVP
