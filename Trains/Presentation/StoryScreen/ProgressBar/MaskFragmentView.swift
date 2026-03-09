//
//  MaskFragmentView.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct MaskFragmentView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: .progressBarCornerRadius)
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: .progressBarHeight)
            .cornerRadius(3)
            .foregroundStyle(.white) // белый цвет для progressBar
    }
}


#Preview {
    Color.story1Background
        .ignoresSafeArea()
        .overlay(
            HStack {
                MaskFragmentView()
                MaskFragmentView()
                MaskFragmentView()
            }.padding()
        )
}
