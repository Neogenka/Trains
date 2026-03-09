//
//  AppState.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var errorState: ErrorState? = nil
    
    func showError(_ error: ErrorState) {
        errorState = error
    }
    
    func hideError() {
        errorState = nil
    }
    
    func showErrorAndRetry(_ error: ErrorState,delay: TimeInterval = 3, maxRetries: Int = 3,
                           retry: @escaping (@escaping (Bool) -> Void) -> Void) {
        errorState = error
        retryWithDelay( error,delay: delay,
                        remainingAttempts: maxRetries,
                        retry: retry)
    }
    
    private func retryWithDelay(_ error: ErrorState,delay: TimeInterval,remainingAttempts: Int,
                                retry: @escaping (@escaping (Bool) -> Void) -> Void) {
        guard remainingAttempts > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            retry { success in DispatchQueue.main.async {
                if success { self?.hideError()} else { self?.retryWithDelay( error,
                                                                             delay: delay,
                                                                             remainingAttempts: remainingAttempts - 1,
                                                                             retry: retry)
                }
            }
            }
        }
    }
}
