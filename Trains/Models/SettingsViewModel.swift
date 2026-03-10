//
//  SettingsViewModel.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import Foundation
import Combine
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var isDarkThemeEnabled: Bool
    var showUserAgreement: Bool = false
    
    @ObservationIgnored
    private let themeDidChangeSubject = PassthroughSubject<Bool, Never>()
    var themeDidChange: AnyPublisher<Bool, Never> { themeDidChangeSubject.eraseToAnyPublisher() }
    
    @ObservationIgnored
    private var didBootstrapTheme: Bool
    
    @ObservationIgnored
    private var store: ThemePreferencesStore
    
    init(store: ThemePreferencesStore = UserDefaultsThemePreferencesStore()) {
        self.store = store
        self.isDarkThemeEnabled = store.isDarkThemeEnabled
        self.didBootstrapTheme  = store.didBootstrapTheme
    }
    
    func toggleDarkTheme(_ isOn: Bool) {
        isDarkThemeEnabled = isOn
        store.isDarkThemeEnabled = isOn
        didBootstrapTheme = true
        store.didBootstrapTheme = true
        themeDidChangeSubject.send(isOn)
    }
    
    func openAgreement() {
        showUserAgreement = true
    }
}
