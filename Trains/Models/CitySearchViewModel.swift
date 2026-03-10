//
//  CitySearchViewModel.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CitySearchViewModel {
    
    private enum Constants {
        enum Paging {
            static let pageSize = 20
        }
        static let minSearchCharacters = 3
    }
    
    let cityService: any CityServiceProtocol
    let app: AppState
    
    var searchText: String = ""
    var showStations = false
    var isLoading = false
    var currentLoadedCount: Int = Constants.Paging.pageSize
    
    var selectedCity: SettlementLite? = nil
    var allCities: [SettlementLite] = []
    
    var isSearching: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= Constants.minSearchCharacters
    }
    
    var filteredCities: [SettlementLite] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return allCities }
        return allCities.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }
    
    var visibleCities: [SettlementLite] {
        let source = filteredCities
        let limit = min(currentLoadedCount, source.count)
        return Array(source.prefix(limit))
    }
    
    var shouldShowPlaceholder: Bool {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return q.isEmpty
    }
    
    var shouldShowSearchResults: Bool {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return q.count >= Constants.minSearchCharacters
    }
    
    var shouldShowResults: Bool {
        searchText.count >= Constants.minSearchCharacters
    }
    
    init(cityService: some CityServiceProtocol, app: AppState) {
        self.cityService = cityService
        self.app = app
    }
    
    func loadCities() async {
        guard !isLoading else { return }
        isLoading = true
        
        let service = self.cityService
        
        loadWithGlobalError(
            app: app,
            task: {
                do {
                let raw = try await service.getAllCities()
                return raw.compactMap { item in
                    guard
                        let title = item.title,
                        let code  = item.codes?.yandex_code
                    else { return nil }
                    return SettlementLite(title: title, code: code)
                }
                } catch {
                    await MainActor.run { [weak self] in self?.isLoading = false }
                    throw error
                }
            },
            onSuccess: { [weak self] (cities: [SettlementLite]) in
                Task { @MainActor in
                    guard let self else { return }
                    var seen = Set<String>()
                    self.allCities = cities
                        .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        .filter { seen.insert($0.title).inserted }
                        .sorted {
                            $0.title.compare($1.title,
                                             options: .caseInsensitive,
                                             range: nil,
                                             locale: Locale(identifier: "ru_RU")) == .orderedAscending
                        }
                    self.currentLoadedCount = min(Constants.Paging.pageSize, self.allCities.count)
                    self.isLoading = false
                }
            }
        )
    }
}
