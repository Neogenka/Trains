//
//  StationSearchView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

struct StationSearchView: View {
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
            static let station: CGFloat = 17
        }
        enum Opacity {
            static let chevronRight: Double = 0.6
        }
        enum Offset {
            static let notFoundTop: CGFloat = 228
        }
        enum ClearButton {
            static let clearIcon = "xmark.circle.fill"
            static let textTrailingInsetForClear: CGFloat = 34
        }
        enum Paging {
            static let pageSize = 12
            static let prefetchThreshold = 5
        }
        static let minSearchCharacters = 2
    }
    
    let city: String
    let onSelect: (StationLite) -> Void
    
    @State private var model: StationSearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(stationService: some StationServiceProtocol, city: String, onSelect: @escaping (StationLite) -> Void, app: AppState) {
        self.city = city
        self.onSelect = onSelect
        _model = State(initialValue: StationSearchViewModel(stationService: stationService, city: city, app: app))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                
                if model.filteredStations.isEmpty {
                    notFoundView
                } else {
                    stationList
                }
            }
            .navigationTitle("Выбор станции")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbarRole(.editor)
            .task {
                await model.loadStations()
            }
            .onChange(of: model.searchText) {
                model.currentLoadedCount = min(Constants.Paging.pageSize, model.filteredStations.count)
            }
        }
        .tint(.ypBlack)
    }
    
    private var searchField: some View {
        SearchTextField(text: $model.searchText, placeholder: "Введите запрос")
            .padding(.horizontal, Constants.Padding.horizontal)
            .padding(.top, Constants.Padding.searchTop)
            .padding(.bottom, Constants.Padding.searchBottom)
    }
    
    private var stationList: some View {
        List(model.filteredStations, id: \.self) { station in
            HStack {
                Text(station.title)
                    .font(.system(size: Constants.FontSize.station, weight: .regular))
                    .foregroundColor(.ypBlack)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.ypBlack)
            }
            .frame(height: Constants.Size.rowHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect(station)
                dismiss()
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .listStyle(.plain)
    }
    
    private var notFoundView: some View {
        VStack {
            Spacer().frame(height: Constants.Offset.notFoundTop)
            Text("Станция не найдена")
                .font(.system(size: Constants.FontSize.notFound, weight: .bold))
                .foregroundColor(.ypBlack)
            Spacer()
        }
    }
}
