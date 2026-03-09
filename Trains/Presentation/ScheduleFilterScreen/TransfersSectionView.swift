//
//  TransfersSectionView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

enum TransfersOption: String, Identifiable, Hashable {
    case yes, no
    var id: Self { self }
    var title: String { self == .yes ? "Да" : "Нет" }
}

struct TransfersSectionView: View {
    @Binding var transfers: TransfersOption?
    
    private let rowInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    
    var body: some View {
        Section {
            ForEach([TransfersOption.yes, .no]) { option in
                HStack {
                    Text(option.title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                    Spacer()
                    Image(transfers == option ? "circleOn" : "circleOff")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.ypBlack)
                        .frame(width: 24, height: 24)
                }
                .contentShape(Rectangle())
                .onTapGesture { transfers = option }
                .listRowSeparator(.hidden)
                .listRowInsets(rowInsets)
                .frame(height: 60)
            }
        } header: {
            Text("Показывать варианты с пересадками")
                .textCase(nil)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .listRowInsets(rowInsets)
        }
    }
}

#Preview("TransfersSection • none selected") {
    List {
        TransfersSectionView(transfers: .constant(nil))
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(.ypWhite)
}

#Preview("TransfersSection • YES selected") {
    List {
        TransfersSectionView(transfers: .constant(.yes))
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(.ypWhite)
}
