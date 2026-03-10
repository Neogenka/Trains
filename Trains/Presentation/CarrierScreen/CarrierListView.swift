//
//  CarrierListView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

struct CarrierListView: View {
    
    private struct FilterResultBox: Identifiable, Hashable {
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
        enum Mock {
            static let delayNs: UInt64 = 400_000_000
        }
    }
    
    let headerFrom: String
    let headerTo: String
    var items: [CarrierRowViewModel] = CarrierRowViewModel.mock
    
    let searchService: SearchServiceProtocol
    let carrierService: CarrierServiceProtocol
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var app: AppState
    
    @State private var showFilters = false
    @State private var loadedItems: [CarrierRowViewModel] = []
    @State private var isLoading = true
    @State private var filterResultBox: FilterResultBox? = nil
    
    var body: some View {
        
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: Constants.Spacing.view) {
                Text("\(headerFrom) → \(headerTo)")
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.horizontal, Constants.Spacing.horizontal)
                    .padding(.top, Constants.Spacing.titleTop)
                
                if isLoading {
                    ProgressView()
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
            Button {
                showFilters = true
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
        .navigationDestination(isPresented: $showFilters) {
            ScheduleFilterView { selectedParts, transfers in
                let filtered = filterItems(
                    items: loadedItems,
                    selectedParts: selectedParts,
                    transfers: transfers
                )
                self.filterResultBox = .init(items: filtered)
            }
        }
        .navigationDestination(item: $filterResultBox) { box in
            FilterResultView(headerFrom: headerFrom,
                             headerTo: headerTo,
                             items: box.items
            )
        }
        .onAppear { load() }
    }
    
    @ViewBuilder
    private var listView: some View {
        List(loadedItems) { item in
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
    
    private func load() {
        isLoading = true
        loadWithGlobalError(app: app,
                            delay: Constants.Retry.delay,
                            maxRetries: Constants.Retry.maxRetries,
                            task: { try await fetchCarriers()},
                            onSuccess: { data in
            loadedItems = data
            isLoading = false
        }
        )
    }
    
    private func fetchCarriers() async throws -> [CarrierRowViewModel] {
        try await Task.sleep(nanoseconds: Constants.Mock.delayNs)
        return items
    }
    
    private func filterItems(items: [CarrierRowViewModel], selectedParts: Set<DayPart>, transfers:TransfersOption?) -> [CarrierRowViewModel] {
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

#Preview {
    NavigationStack {
        CarrierListView(
            headerFrom: "c146",
            headerTo: "c213",
            searchService: try! APIFactory.makeSearchService(),
            carrierService: try! APIFactory.makeCarrierService()
        )
        .environmentObject(AppState())
    }
}
