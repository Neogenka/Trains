//
//  FilterResultView.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct FilterResultView: View {
    let headerFrom: String
    let headerTo: String
    let items: [CarrierRowViewModel]
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: CarrierRowViewModel? = nil
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("\(headerFrom) → \(headerTo)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                if items.isEmpty {
                    emptyStateView
                } else {
                    carriersListView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            clarifyTimeButton
        }
        
        .navigationDestination(item: $selectedItem) { item in
            CarrierInfoView(
                code: item.carrierCode,
                service: try! APIFactory.makeCarrierService(),
                logoAssetName: nil
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Вариантов нет")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var carriersListView: some View {
        List(items) { item in
            Button {
                selectedItem = item
            } label: {
                CarrierTableRow(viewModel: item)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.ypBlack)
        }
    }
    
    private var clarifyTimeButton: some View {
        Button(action: { dismiss() }) {
            Label {
                Text("Уточнить время")
                    .font(.bold17)
                    .foregroundStyle(.ypWhiteUniversal)
            } icon: {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.ypRed)
                    .frame(width: 8, height: 8)
            }
            .labelStyle(TrailingIconLabelStyle())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.ypBlue, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

#Preview {
    NavigationStack {
        FilterResultView(
            headerFrom: "Москва (Ярославский вокзал)",
            headerTo: "Санкт-Петербург (Балтийский вокзал)",
            items: CarrierRowViewModel.mock.prefix(1).map { $0 }
        )
    }
}
