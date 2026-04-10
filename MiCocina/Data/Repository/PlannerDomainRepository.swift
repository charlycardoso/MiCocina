//
//  PlannerDomainRepository.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import Foundation

/// A domain-level repository that delegates all planner operations to an underlying repository.
///
/// `PlannerDomainRepository` acts as the primary entry point for the Planner module's
/// data access from the domain and presentation layers. It conforms to `PlannerProtocolRepository`
/// and forwards every call to the injected `repo`, enabling clean dependency inversion and
/// easy substitution of the backing store (e.g. SwiftData vs in-memory mock).
///
/// - Example:
/// ```swift
/// let sdRepo = SDPlannerDomainRepository(context: modelContext)
/// let domainRepo = PlannerDomainRepository(repo: sdRepo)
/// let plan = domainRepo.get(by: Date())
/// ```
final class PlannerDomainRepository: PlannerProtocolRepository {

    /// The underlying repository that handles actual persistence.
    let repo: PlannerProtocolRepository

    /// Creates a domain repository backed by the given repository implementation.
    ///
    /// - Parameter repo: Any `PlannerProtocolRepository` conformance to delegate operations to.
    init(repo: PlannerProtocolRepository) {
        self.repo = repo
    }

    /// Returns the meal plan for the given day by delegating to the underlying repository.
    func get(by day: Date) -> PlannerData? {
        repo.get(by: day)
    }

    /// Persists a meal plan by delegating to the underlying repository.
    func save(_ planner: PlannerData) throws {
        try repo.save(planner)
    }

    /// Deletes the meal plan for the given day by delegating to the underlying repository.
    func removePlanner(day: Date) throws {
        try repo.removePlanner(day: day)
    }

    /// Moves a recipe between days by delegating to the underlying repository.
    func movePlanner(recipeID: UUID, from date: Date, to: Date) throws {
        try repo.movePlanner(recipeID: recipeID, from: date, to: to)
    }
}
