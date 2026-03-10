//
//  CitySearchView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

struct CitySearchView: View {
    
    // MARK: - Constants
    private enum Constants {
        enum Padding {
            static let horizontal: CGFloat = 16
            static let rowVertical: CGFloat = 4
            static let searchTop: CGFloat = 8
            static let searchBottom: CGFloat = 4
            static let clearHit: CGFloat = 8
            static let clearTrailing: CGFloat = 14
        }
        enum Size {
            static let rowHeight: CGFloat = 60
            static let backButton: CGFloat = 44
        }
        enum CornerRadius {
            static let search: CGFloat = 10
        }
        enum FontSize {
            static let notFound: CGFloat = 24
            static let city: CGFloat = 17
        }
        enum Opacity {
            static let chevronRight: Double = 0.6
        }
        enum Offset {
            static let notFoundTop: CGFloat = 228
        }
        enum ClearIcon {
            static let name = "xmark.circle.fill"
            static let textTrailingInset: CGFloat = 34
        }
        enum Paging {
            static let pageSize = 20
            static let prefetchThreshold = 5
        }
        static let minSearchCharacters = 3
    }
    
    let onSelect: (StationLite) -> Void
    @State private var model: CitySearchViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init(cityService: some CityServiceProtocol, onSelect: @escaping (StationLite) -> Void, app: AppState) {
        self.onSelect = onSelect
        _model = State(initialValue: CitySearchViewModel(cityService: cityService, app: app))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                
                if model.isSearching && model.visibleCities.isEmpty {
                    notFoundView
                } else if model.visibleCities.isEmpty {
                    if model.isLoading {
                        Spacer()
                    } else {
                        Spacer()
                    }
                } else {
                    cityList
                }
            }
            .navigationTitle("Выбор города")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .navigationDestination(isPresented: $model.showStations) {
                if let city = model.selectedCity,
                   let stationService = try? APIFactory.makeStationService() {
                    StationSearchView(
                        stationService: stationService,
                        city: city.title,
                        onSelect: { station in
                            let title = "\(city.title) (\(station.title))"
                            let code  = station.code
                            onSelect(StationLite(title: title, code: code))
                            dismiss()
                        },
                        app: model.app
                    )
                } else {
                    ErrorStateView(state: .server)
                        .task { model.app.showError(.server) }
                }
            }
            .task {
                await model.loadCities()
            }
            .onChange(of: model.searchText) {
                model.currentLoadedCount = min(Constants.Paging.pageSize, model.filteredCities.count)
            }
        }
    }
    
    // MARK: - Subviews
    private var searchField: some View {
        SearchTextField(text: $model.searchText, placeholder: "Введите запрос")
            .padding(.horizontal, Constants.Padding.horizontal)
            .padding(.top, Constants.Padding.searchTop)
            .padding(.bottom, Constants.Padding.searchBottom)
    }
    
    private var cityList: some View {
        List(model.filteredCities) { city in
            HStack {
                Text(city.title)
                    .font(.system(size: Constants.FontSize.city, weight: .regular))
                    .foregroundColor(.ypBlack)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.ypBlack)
            }
            .frame(height: Constants.Size.rowHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                model.selectedCity = city
                model.showStations = true
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .listStyle(.plain)
    }
    
    
    
    private var notFoundView: some View {
        VStack {
            Spacer().frame(height: Constants.Offset.notFoundTop)
            Text("Город не найден")
                .font(.system(size: Constants.FontSize.notFound, weight: .bold))
                .foregroundColor(.ypBlack)
            Spacer()
        }
    }
}

#Preview {
    let app = AppState()
    CitySearchView(
        cityService: MockCityService(),
        onSelect: { _ in },
        app: app
    )
    .environmentObject(AppState())
}

#Preview("CitySearchView + Error internet") {
    struct Harness: View {
        @StateObject var app = AppState()
        var body: some View {
            CitySearchView(
                cityService: MockCityService(),
                onSelect: { _ in },
                app: app
            )
            .environmentObject(app)
            .withGlobalErrors(app)
            .onAppear { app.showError(.offline) }
        }
    }
    return Harness()
}

#Preview("CitySearchView + Error server") {
    struct Harness: View {
        @StateObject var app = AppState()
        var body: some View {
            CitySearchView(
                cityService: MockCityService(),
                onSelect: { _ in },
                app: app
            )
            .environmentObject(app)
            .withGlobalErrors(app)
            .onAppear { app.showError(.server) }
        }
    }
    return Harness()
}
