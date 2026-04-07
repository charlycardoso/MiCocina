//
//  RepositoryError.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 07/04/26.
//

import Foundation
import SwiftData

/// A comprehensive error type for repository and mapping operations.
///
/// `RepositoryError` provides detailed error information for data access failures,
/// mapping issues, and validation problems. Each error case includes contextual
/// information to help with debugging and user-facing error messages.
///
/// The error type follows Apple's error handling best practices and provides
/// both technical details for developers and user-friendly descriptions.
///
/// - Example:
/// ```swift
/// do {
///     let recipe = try repository.getByIDSafely(id)
/// } catch let error as RepositoryError {
///     print("Error: \(error.localizedDescription)")
///     print("Debug info: \(error.debugDescription)")
/// }
/// ```
enum RepositoryError: Error, LocalizedError, CustomDebugStringConvertible {
    
    // MARK: - Data Access Errors
    
    /// Failed to fetch data from the database
    case fetchFailed(operation: String, underlyingError: Error?)
    
    /// Failed to save data to the database
    case saveFailed(operation: String, underlyingError: Error?)
    
    /// Failed to delete data from the database
    case deleteFailed(operation: String, underlyingError: Error?)
    
    /// Failed to update existing data
    case updateFailed(operation: String, underlyingError: Error?)
    
    // MARK: - Data Validation Errors
    
    /// The requested entity was not found
    case entityNotFound(entityType: String, identifier: String)
    
    /// Invalid data provided for the operation
    case invalidData(field: String, value: Any?, reason: String)
    
    /// Database constraint violation
    case constraintViolation(constraint: String, details: String)
    
    // MARK: - Mapping Errors
    
    /// Failed to convert between domain and storage models
    case mappingFailed(sourceType: String, targetType: String, reason: String)
    
    /// Required field is missing during mapping
    case missingRequiredField(field: String, modelType: String)
    
    /// Invalid enum value encountered during mapping
    case invalidEnumValue(field: String, value: String, validValues: [String])
    
    // MARK: - Context Errors
    
    /// ModelContext is in an invalid state
    case invalidContext(reason: String)
    
    /// Concurrent modification detected
    case concurrencyConflict(details: String)
    
    // MARK: - LocalizedError Conformance
    
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let operation, _):
            return "Failed to fetch \(operation)"
            
        case .saveFailed(let operation, _):
            return "Failed to save \(operation)"
            
        case .deleteFailed(let operation, _):
            return "Failed to delete \(operation)"
            
        case .updateFailed(let operation, _):
            return "Failed to update \(operation)"
            
        case .entityNotFound(let entityType, let identifier):
            return "\(entityType) with identifier '\(identifier)' not found"
            
        case .invalidData(let field, _, let reason):
            return "Invalid data for field '\(field)': \(reason)"
            
        case .constraintViolation(let constraint, _):
            return "Database constraint violation: \(constraint)"
            
        case .mappingFailed(let sourceType, let targetType, let reason):
            return "Failed to convert \(sourceType) to \(targetType): \(reason)"
            
        case .missingRequiredField(let field, let modelType):
            return "Missing required field '\(field)' in \(modelType)"
            
        case .invalidEnumValue(let field, let value, _):
            return "Invalid value '\(value)' for field '\(field)'"
            
        case .invalidContext(let reason):
            return "Invalid database context: \(reason)"
            
        case .concurrencyConflict(let details):
            return "Concurrency conflict detected: \(details)"
        }
    }
    
    /// A localized message describing the reason for the failure.
    var failureReason: String? {
        switch self {
        case .fetchFailed(_, let underlyingError):
            return underlyingError?.localizedDescription ?? "Unknown fetch error"
            
        case .saveFailed(_, let underlyingError):
            return underlyingError?.localizedDescription ?? "Unknown save error"
            
        case .deleteFailed(_, let underlyingError):
            return underlyingError?.localizedDescription ?? "Unknown delete error"
            
        case .updateFailed(_, let underlyingError):
            return underlyingError?.localizedDescription ?? "Unknown update error"
            
        case .entityNotFound:
            return "The requested item could not be found in the database"
            
        case .invalidData(_, let value, let reason):
            if let value = value {
                return "The value '\(value)' is invalid: \(reason)"
            } else {
                return "The provided data is invalid: \(reason)"
            }
            
        case .constraintViolation(_, let details):
            return details
            
        case .mappingFailed(_, _, let reason):
            return reason
            
        case .missingRequiredField:
            return "A required field is missing from the data"
            
        case .invalidEnumValue(_, _, let validValues):
            return "Valid values are: \(validValues.joined(separator: ", "))"
            
        case .invalidContext(let reason):
            return reason
            
        case .concurrencyConflict(let details):
            return details
        }
    }
    
    /// A localized message providing "help" text if any is available.
    var recoverySuggestion: String? {
        switch self {
        case .fetchFailed:
            return "Check your internet connection and try again. If the problem persists, restart the app."
            
        case .saveFailed:
            return "Ensure you have enough storage space and try again."
            
        case .deleteFailed:
            return "The item may have already been deleted. Refresh and try again."
            
        case .updateFailed:
            return "The item may have been modified by another process. Refresh and try again."
            
        case .entityNotFound:
            return "The item may have been deleted. Please refresh the list and try again."
            
        case .invalidData:
            return "Please check the data format and try again."
            
        case .constraintViolation:
            return "Please ensure all required fields are filled correctly."
            
        case .mappingFailed:
            return "This appears to be a data format issue. Please report this error."
            
        case .missingRequiredField:
            return "Please ensure all required fields are provided."
            
        case .invalidEnumValue:
            return "Please select a valid option from the available choices."
            
        case .invalidContext:
            return "Please restart the app to reset the database connection."
            
        case .concurrencyConflict:
            return "Multiple processes are trying to modify the same data. Please try again."
        }
    }
    
    // MARK: - CustomDebugStringConvertible Conformance
    
    /// A detailed description for debugging purposes.
    var debugDescription: String {
        switch self {
        case .fetchFailed(let operation, let underlyingError):
            return "RepositoryError.fetchFailed(operation: \"\(operation)\", underlyingError: \(String(describing: underlyingError)))"
            
        case .saveFailed(let operation, let underlyingError):
            return "RepositoryError.saveFailed(operation: \"\(operation)\", underlyingError: \(String(describing: underlyingError)))"
            
        case .deleteFailed(let operation, let underlyingError):
            return "RepositoryError.deleteFailed(operation: \"\(operation)\", underlyingError: \(String(describing: underlyingError)))"
            
        case .updateFailed(let operation, let underlyingError):
            return "RepositoryError.updateFailed(operation: \"\(operation)\", underlyingError: \(String(describing: underlyingError)))"
            
        case .entityNotFound(let entityType, let identifier):
            return "RepositoryError.entityNotFound(entityType: \"\(entityType)\", identifier: \"\(identifier)\")"
            
        case .invalidData(let field, let value, let reason):
            return "RepositoryError.invalidData(field: \"\(field)\", value: \(String(describing: value)), reason: \"\(reason)\")"
            
        case .constraintViolation(let constraint, let details):
            return "RepositoryError.constraintViolation(constraint: \"\(constraint)\", details: \"\(details)\")"
            
        case .mappingFailed(let sourceType, let targetType, let reason):
            return "RepositoryError.mappingFailed(sourceType: \"\(sourceType)\", targetType: \"\(targetType)\", reason: \"\(reason)\")"
            
        case .missingRequiredField(let field, let modelType):
            return "RepositoryError.missingRequiredField(field: \"\(field)\", modelType: \"\(modelType)\")"
            
        case .invalidEnumValue(let field, let value, let validValues):
            return "RepositoryError.invalidEnumValue(field: \"\(field)\", value: \"\(value)\", validValues: \(validValues))"
            
        case .invalidContext(let reason):
            return "RepositoryError.invalidContext(reason: \"\(reason)\")"
            
        case .concurrencyConflict(let details):
            return "RepositoryError.concurrencyConflict(details: \"\(details)\")"
        }
    }
    
    // MARK: - Convenience Properties
    
    /// Returns the underlying error if available
    var underlyingError: Error? {
        switch self {
        case .fetchFailed(_, let error),
             .saveFailed(_, let error),
             .deleteFailed(_, let error),
             .updateFailed(_, let error):
            return error
        default:
            return nil
        }
    }
    
    /// Returns true if this is a network or connectivity related error
    var isConnectivityError: Bool {
        guard let underlyingError = underlyingError else { return false }
        return (underlyingError as NSError).domain == NSURLErrorDomain
    }
    
    /// Returns true if this is a temporary error that might be resolved by retrying
    var isRetryable: Bool {
        switch self {
        case .fetchFailed, .saveFailed:
            return true
        case .concurrencyConflict:
            return true
        default:
            return false
        }
    }
}