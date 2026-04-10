//
//  PlannerDomainRepositoryTests.swift
//  MiCocinaTests
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Testing
import Foundation
@testable import MiCocina

/// Mock implementation of `PlannerProtocolRepository` for testing delegation.
private final class MockPlannerRepository: PlannerProtocolRepository {
    var getResult: PlannerData?
    var savedPlanners: [PlannerData] = []
    var removedDays: [Date] = []
    var movedRecipes: [(recipeID: UUID, from: Date, to: Date)] = []
    var shouldThrowOnSave = false
    var shouldThrowOnRemove = false
    var shouldThrowOnMove = false

    func get(by day: Date) -> PlannerData? {
        getResult
    }

    func save(_ planner: PlannerData) throws {
        if shouldThrowOnSave {
            throw RepositoryError.saveFailed(operation: "test", underlyingError: nil)
        }
        savedPlanners.append(planner)
    }

    func removePlanner(day: Date) throws {
        if shouldThrowOnRemove {
            throw RepositoryError.saveFailed(operation: "test", underlyingError: nil)
        }
        removedDays.append(day)
    }

    func movePlanner(recipeID: UUID, from date: Date, to: Date) throws {
        if shouldThrowOnMove {
            throw RepositoryError.entityNotFound(entityType: "Planner", identifier: "test")
        }
        movedRecipes.append((recipeID, date, to))
    }
}

/// Test suite for `PlannerDomainRepository` delegation to the underlying repository.
///
/// Verifies that all protocol methods are correctly forwarded and errors propagated.
@Suite
struct PlannerDomainRepositoryTests {
    private let mock: MockPlannerRepository
    private let repository: PlannerDomainRepository

    init() {
        mock = MockPlannerRepository()
        repository = PlannerDomainRepository(repo: mock)
    }

    // MARK: - get(by:) Tests

    @Test
    func get_delegates_to_underlying_repo() {
        // Given
        let day = Date()
        let expectedPlanner = PlannerData(day: day, recipes: [])
        mock.getResult = expectedPlanner

        // When
        let result = repository.get(by: day)

        // Then
        #expect(result?.id == expectedPlanner.id)
    }

    @Test
    func get_returns_nil_when_repo_returns_nil() {
        // Given
        mock.getResult = nil

        // When/Then
        #expect(repository.get(by: Date()) == nil)
    }

    // MARK: - save Tests

    @Test
    func save_delegates_to_underlying_repo() throws {
        // Given
        let planner = PlannerData(day: Date(), recipes: [])

        // When
        try repository.save(planner)

        // Then
        #expect(mock.savedPlanners.count == 1)
        #expect(mock.savedPlanners.first?.id == planner.id)
    }

    @Test
    func save_propagates_thrown_error() {
        // Given
        mock.shouldThrowOnSave = true

        // When/Then
        #expect(throws: (any Error).self) {
            try repository.save(PlannerData(day: Date(), recipes: []))
        }
    }

    // MARK: - removePlanner Tests

    @Test
    func removePlanner_delegates_to_underlying_repo() throws {
        // Given
        let day = Date()

        // When
        try repository.removePlanner(day: day)

        // Then
        #expect(mock.removedDays.count == 1)
        #expect(mock.removedDays.first == day)
    }

    @Test
    func removePlanner_propagates_thrown_error() {
        // Given
        mock.shouldThrowOnRemove = true

        // When/Then
        #expect(throws: (any Error).self) {
            try repository.removePlanner(day: Date())
        }
    }

    // MARK: - movePlanner Tests

    @Test
    func movePlanner_delegates_to_underlying_repo() throws {
        // Given
        let recipeID = UUID()
        let fromDay = Date()
        let toDay = Date().addingTimeInterval(86400)

        // When
        try repository.movePlanner(recipeID: recipeID, from: fromDay, to: toDay)

        // Then
        #expect(mock.movedRecipes.count == 1)
        #expect(mock.movedRecipes.first?.recipeID == recipeID)
        #expect(mock.movedRecipes.first?.from == fromDay)
        #expect(mock.movedRecipes.first?.to == toDay)
    }

    @Test
    func movePlanner_propagates_thrown_error() {
        // Given
        mock.shouldThrowOnMove = true

        // When/Then
        #expect(throws: (any Error).self) {
            try repository.movePlanner(recipeID: UUID(), from: Date(), to: Date())
        }
    }
}
