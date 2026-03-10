//
//  ScheduleFilterView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

struct ScheduleFilterView: View {
    
    @State private var model = ScheduleFilterViewModel()
    
    var onApply: ((Set<DayPart>, TransfersOption?) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    private var isApplyEnabled: Bool { !model.selectedParts.isEmpty && model.transfers != nil }
    
    var body: some View {
        ZStack {
            List {
                DayPartSectionView(selectedParts: $model.selectedParts)
                TransfersSectionView(transfers: $model.transfers)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Button {
                    onApply?(model.selectedParts, model.transfers)
                } label: {
                    Text("Применить")
                        .font(.bold17)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundColor(.ypWhiteUniversal)
                .background(Color.ypBlue)
                .cornerRadius(16)
                .opacity(isApplyEnabled ? 1 : 0)
                .disabled(!isApplyEnabled)
                .allowsHitTesting(isApplyEnabled)
                .animation(.easeInOut(duration: 0.2), value: isApplyEnabled)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    ScheduleFilterView()
}
