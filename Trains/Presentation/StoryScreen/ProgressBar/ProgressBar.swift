//
//  ProgressBar.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct ProgressBar: View {
    let numberOfSections: Int
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .progressBarCornerRadius)
                    .frame(width: geometry.size.width, height: .progressBarHeight)
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: .progressBarCornerRadius)
                    .frame(
                        width: min(
                            progress * geometry.size.width,
                            geometry.size.width
                        ),
                        height: .progressBarHeight
                    )
                    .foregroundColor(.blue)
            }
            .mask {
                MaskView(numberOfSections: numberOfSections)
            }
        }
    }
}


#Preview {
    Color.story1Background
        .ignoresSafeArea()
        .overlay(
            ProgressBar(numberOfSections: 3, progress: 0.5)
                .padding()
        )
}
