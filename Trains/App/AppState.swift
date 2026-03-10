//
//  AppState.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var errorState: ErrorState? = nil
    
    func showError(_ error: ErrorState) {
        errorState = error
    }
    
    func hideError() {
        errorState = nil
    }
    
    func showErrorAndRetry(
        _ error: ErrorState,
        delay: TimeInterval = 3,
        maxRetries: Int = 3,
        retry: @Sendable @escaping () async -> Bool
    ) {
        errorState = error
        Task { // MainActor
            await retryWithDelay(
                error,
                delay: delay,
                remainingAttempts: maxRetries,
                retry: retry
            )
        }
    }
    
    private func retryWithDelay(
        _ error: ErrorState,
        delay: TimeInterval,
        remainingAttempts: Int,
        retry: @Sendable @escaping () async -> Bool
    ) async {
        guard remainingAttempts > 0 else { return }
        
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        let success = await retry()
        if success {
            hideError()
        } else {
            await retryWithDelay(
                error,
                delay: delay,
                remainingAttempts: remainingAttempts - 1,
                retry: retry
            )
        }
    }
    
}
