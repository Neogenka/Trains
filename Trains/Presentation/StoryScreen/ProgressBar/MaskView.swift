//
//  MaskView.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct MaskView: View {
    let numberOfSections: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfSections, id: \.self) { _ in
                MaskFragmentView()
            }
        }
    }
}

#Preview {
    Color.story1Background
        .ignoresSafeArea()
        .overlay(
            MaskView(numberOfSections: 3)
                .padding()
        )
}
