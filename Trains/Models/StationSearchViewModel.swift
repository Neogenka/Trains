//
//  StationSearchViewModel.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class StationSearchViewModel {
    
    let stationService: any StationServiceProtocol
    let city: String
    let app: AppState
    
    private enum Constants {
        enum Paging {
            static let pageSize = 12
            static let prefetchThreshold = 5
        }
        static let minSearchCharacters = 2
    }
    
    var searchText: String = ""
    var allStations: [StationLite] = []
    var isLoading = false
    var currentLoadedCount: Int = Constants.Paging.pageSize
    
    var filteredStations: [StationLite] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return allStations }
        return allStations.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }
    
    var visibleStations: [StationLite] {
        let limit = min(currentLoadedCount, filteredStations.count)
        return Array(filteredStations.prefix(limit))
    }
    
    init(stationService: some StationServiceProtocol, city: String, app: AppState) {
        self.stationService = stationService
        self.city = city
        self.app = app
    }
    
    func loadStations() async {
        guard !isLoading else { return }
        isLoading = true
        
        let city = self.city
        let service = self.stationService
        
        loadWithGlobalError(
            app: app,
            task: {
                let raw = try await service.getStations(for: city)
                return raw.compactMap { s -> StationLite? in
                    guard let title = s.title else { return nil }
                    let code = s.code ?? s.codes?.yandex_code
                    guard let code else { return nil }
                    return StationLite(title: title, code: code)
                }
            },
            onSuccess: { [self] (result: [StationLite]) in
                Task { @MainActor in
                    self.allStations = result
                    self.currentLoadedCount = min(Constants.Paging.pageSize, result.count)
                    self.isLoading = false
                }
            }
        )
    }
    
    func loadMoreIfNeeded(currentItem: StationLite) {
        guard !filteredStations.isEmpty else { return }
        guard currentLoadedCount < filteredStations.count else { return }
        
        if let index = visibleStations.firstIndex(where: { $0.id == currentItem.id }),
           index >= visibleStations.count - Constants.Paging.prefetchThreshold {
            currentLoadedCount = min(
                currentLoadedCount + Constants.Paging.pageSize,
                filteredStations.count
            )
        }
    }
}
