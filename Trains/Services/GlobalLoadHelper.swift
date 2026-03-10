//
//  GlobalLoadHelper.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import Foundation

private func classifyError(_ error: Error) -> ErrorState {
    if let urlError = error as? URLError {
        switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut,
                    .cannotFindHost, .cannotConnectToHost:
                return .offline
            default:
                break
        }
    }
    return .server
}

@MainActor
func loadWithGlobalError<T: Sendable>(
    app: AppState,
    delay: TimeInterval = 10,
    maxRetries: Int = 3,
    task: @Sendable @escaping () async throws -> T,
    onSuccess: @MainActor @Sendable @escaping (T) -> Void
) {
    Task {
        do {
            let value = try await task()
            app.hideError()
            onSuccess(value)
        } catch {
            let state = classifyError(error)
            let retryAttempt: @Sendable () async -> Bool = {
                do {
                    let value = try await task()
                    await MainActor.run {
                        app.hideError()
                        onSuccess(value)
                    }
                    return true
                } catch {
                    return false
                }
            }
            
            app.showErrorAndRetry(
                state,
                delay: delay,
                maxRetries: maxRetries,
                retry: retryAttempt
            )
        }
    }
}
