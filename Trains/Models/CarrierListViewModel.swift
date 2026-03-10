//
//  CarrierListViewModel.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import SwiftUI
import Foundation

@MainActor
final class CarrierListViewModel: ObservableObject {
    
    private enum Constants {
        enum Retry {
            static let delay: TimeInterval = 10
            static let maxRetries: Int = 3
        }
    }
    
    let headerFrom: String
    let headerTo: String
    let fromStationCode: String
    let toStationCode: String
    
    let searchService: SearchServiceProtocol
    let carrierService: CarrierServiceProtocol
    let app: AppState
    
    @Published var showFilters = false
    @Published var loadedItems: [CarrierRowViewModel] = []
    @Published var isLoading = true
    @Published var filterResultBox: CarrierListView.FilterResultBox? = nil
    
    init(
        headerFrom: String,
        headerTo: String,
        fromStationCode: String,
        toStationCode: String,
        searchService: SearchServiceProtocol,
        carrierService: CarrierServiceProtocol,
        app: AppState
    ) {
        self.headerFrom = headerFrom
        self.headerTo = headerTo
        self.fromStationCode = fromStationCode
        self.toStationCode = toStationCode
        self.searchService = searchService
        self.carrierService = carrierService
        self.app = app
    }
    
    func load() {
        isLoading = true
        loadWithGlobalError(
            app: app,
            delay: Constants.Retry.delay,
            maxRetries: Constants.Retry.maxRetries,
            task: { try await self.fetchCarriers() },
            onSuccess: { [weak self] data in
                Task { @MainActor in
                    self?.loadedItems = data
                    self?.isLoading = false
                }
            }
        )
    }
    
    func fetchCarriers() async throws -> [CarrierRowViewModel] {
        let resp = try await searchService.getScheduleBetweenStations(
            from: fromStationCode, to: toStationCode
        )
        guard let segments = resp.segments else { return [] }
        
        var items: [CarrierRowViewModel] = []
        for segment in segments {
            if segment.has_transfers == true, let details = segment.details, !details.isEmpty {
                if let compositeViewModel = await createCompositeViewModel(from: segment) {
                    items.append(compositeViewModel)
                }
            } else if let viewModel = await CarrierRowViewModel(from: segment, carrierService: carrierService) {
                items.append(viewModel)
            }
        }
        return items
    }
    
    func createCompositeViewModel(from segment: Components.Schemas.Segment) async -> CarrierRowViewModel? {
        guard let departureString = segment.departure,
              let arrivalString = segment.arrival,
              let details = segment.details, !details.isEmpty else {
            return nil
        }
        
        guard let firstDetail = details.first,
              let thread = firstDetail.thread else {
            return nil
        }
        
        let carrierName = thread.carrier?.title ?? "Неизвестный перевозчик"
        let carrierCode = thread.carrier?.code?.description ?? thread.number ?? "unknown"
        
        let (dateText, departTime, arriveTime) = CarrierRowViewModel.formatDates(
            departure: departureString,
            arrival: arrivalString
        )
        
        let durationText: String
        if let durationSeconds = segment.duration {
            durationText = CarrierRowViewModel.formatDuration(seconds: Int(durationSeconds))
        } else {
            durationText = CarrierRowViewModel.calculateDuration(
                departure: departureString,
                arrival: arrivalString
            )
        }
        
        let transferCity = segment.transfers?.first?.title ?? "Москва"
        let note = "С пересадкой в \(transferCity)"
        
        let logoURL: URL? = await {
            if let code = thread.carrier?.code?.description {
                do {
                    let carrierInfo = try await carrierService.getCarrierInfo(code: code)
                    
                    if let logoString = carrierInfo.carrier?.logo,
                       !logoString.isEmpty,
                       let url = URL(string: logoString) {
                        return url
                    }
                    if let logoSvgString = carrierInfo.carrier?.logo_svg,
                       !logoSvgString.isEmpty,
                       let url = URL(string: logoSvgString) {
                        return url
                    }
                } catch {
                    print("Ошибка получения информации о перевозчике: \(error)")
                }
            }
            return nil
        }()
        
        let logoSystemName = logoURL == nil ? CarrierRowViewModel.getSystemIconName(for: carrierName) : nil
        
        return CarrierRowViewModel(
            carrierName: carrierName,
            logoSystemName: logoSystemName,
            logoURL: logoURL,
            dateText: dateText,
            departTime: departTime,
            arriveTime: arriveTime,
            durationText: durationText,
            note: note,
            carrierCode: carrierCode,
            hasTransfers: true
        )
    }
    
    func filterItems(items: [CarrierRowViewModel], selectedParts: Set<DayPart>, transfers: TransfersOption?) -> [CarrierRowViewModel] {
        items.filter { viewModel in
            guard let hour = viewModel.departureHour else { return false }
            
            let matchesDayPart = selectedParts.contains { $0.contains(hour: hour) }
            
            let matchesTransfers: Bool
            if let t = transfers {
                matchesTransfers = (t == .yes && viewModel.hasTransfers) || (t == .no && !viewModel.hasTransfers)
            } else {
                matchesTransfers = true
            }
            
            return matchesDayPart && matchesTransfers
        }
    }
}
