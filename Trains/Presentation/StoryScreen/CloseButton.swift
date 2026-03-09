//
//  CloseButton.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(.close)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 30, height: 30)
        .background(Color.ypBlackUniversal)
        .clipShape(Circle())
        .contentShape(Circle())
    }
}
