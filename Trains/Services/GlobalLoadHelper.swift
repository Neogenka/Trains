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

func loadWithGlobalError<T>(
    app: AppState,
    delay: TimeInterval = 10,
    maxRetries: Int = 3,
    task: @escaping () async throws -> T,
    onSuccess: @MainActor @escaping (T) -> Void
) {
    Task {
        do {
            let value = try await task()
            await MainActor.run {
                app.hideError()
                onSuccess(value)
            }
        } catch {
            let state = classifyError(error)
            await MainActor.run {
                app.showErrorAndRetry(state, delay: delay, maxRetries: maxRetries) { _ in
                    loadWithGlobalError(
                        app: app,
                        delay: delay,
                        maxRetries: maxRetries,
                        task: task,
                        onSuccess: onSuccess
                    )
                }
            }
        }
    }
}
