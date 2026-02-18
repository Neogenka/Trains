//
//  ErrorStateView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

enum ErrorState: Equatable, Identifiable {
    case offline
    case server
    
    var id: String { title }
    
    var title: String {
        switch self {
            case .offline: return "Нет интернета"
            case .server:  return "Ошибка сервера"
        }
    }
    
    var assetName: String {
        switch self {
            case .offline: return "noInternet"
            case .server:  return "serverError"
        }
    }
}

struct ErrorStateView: View {
    let state: ErrorState
    
    private let iconSize: CGFloat = 223
    private let corner: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 16) {
            Image(state.assetName)
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            Text(state.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
}

#Preview("Server error") {
    ErrorStateView(state: .server)
        .preferredColorScheme(.light)
}

#Preview("No internet") {
    ErrorStateView(state: .offline)
        .preferredColorScheme(.light)
}
