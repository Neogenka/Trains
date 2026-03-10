//
//  CarrierListView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

struct CarrierListView: View {
    
    struct FilterResultBox: Identifiable, Hashable, Sendable {
        let id = UUID()
        let items: [CarrierRowViewModel]
        
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }
    
    private enum Constants {
        enum Spacing {
            static let view: CGFloat = 12
            static let horizontal: CGFloat = 16
            static let titleTop: CGFloat = 12
            static let rowVerticalInset: CGFloat = 8
            static let rowHorizontalInset: CGFloat = 16
            static let listBottom: CGFloat = 10
            static let bottom: CGFloat = 24
        }
        enum FontSize {
            static let title: CGFloat = 24
            static let bottomButton: CGFloat = 17
        }
        enum Size {
            static let bottomButtonHeight: CGFloat = 60
        }
        enum Corner {
            static let bottomButton: CGFloat = 16
        }
        enum Retry {
            static let delay: TimeInterval = 10
            static let maxRetries: Int = 3
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CarrierListViewModel
    
    init(
        headerFrom: String,
        headerTo: String,
        fromStationCode: String,
        toStationCode: String,
        searchService: SearchServiceProtocol,
        carrierService: CarrierServiceProtocol,
        app: AppState
    ) {
        _viewModel = StateObject(wrappedValue: CarrierListViewModel(
            headerFrom: headerFrom,
            headerTo: headerTo,
            fromStationCode: fromStationCode,
            toStationCode: toStationCode,
            searchService: searchService,
            carrierService: carrierService,
            app: app
        ))
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: Constants.Spacing.view) {
                Text("\(viewModel.headerFrom) → \(viewModel.headerTo)")
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.horizontal, Constants.Spacing.horizontal)
                    .padding(.top, Constants.Spacing.titleTop)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.loadedItems.isEmpty {
                    Text("Рейсы не найдены")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    listView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            if !viewModel.loadedItems.isEmpty {
                Button {
                    viewModel.showFilters = true
                } label: {
                    Text("Уточнить время")
                        .font(.system(size: Constants.FontSize.bottomButton, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: Constants.Size.bottomButtonHeight)
                        .contentShape(
                            RoundedRectangle(cornerRadius: Constants.Corner.bottomButton, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .foregroundColor(.ypWhiteUniversal)
                .background(Color.ypBlue)
                .cornerRadius(Constants.Corner.bottomButton)
                .padding(.horizontal, Constants.Spacing.horizontal)
                .padding(.bottom, Constants.Spacing.bottom)
                .background(Color(.systemBackground))
            }
        }
        .navigationDestination(isPresented: $viewModel.showFilters) {
            ScheduleFilterView { selectedParts, transfers in
                let filtered = viewModel.filterItems(
                    items: viewModel.loadedItems,
                    selectedParts: selectedParts,
                    transfers: transfers
                )
                viewModel.filterResultBox = .init(items: filtered)
            }
        }
        .navigationDestination(item: $viewModel.filterResultBox) { box in
            FilterResultView(headerFrom: viewModel.headerFrom,
                             headerTo: viewModel.headerTo,
                             items: box.items
            )
        }
        .onAppear { viewModel.load() }
    }
    
    @ViewBuilder
    private var listView: some View {
        List(viewModel.loadedItems) { item in
            CarrierTableRow(viewModel: item)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: Constants.Spacing.rowVerticalInset,
                                     leading: Constants.Spacing.rowHorizontalInset,
                                     bottom: Constants.Spacing.rowVerticalInset,
                                     trailing: Constants.Spacing.rowHorizontalInset))
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .listSectionSeparator(.hidden, edges: .all)
        .listRowSeparator(.hidden, edges: .all)
        .contentMargins(.bottom, Constants.Spacing.listBottom,
                        for: .scrollContent)
    }
}
