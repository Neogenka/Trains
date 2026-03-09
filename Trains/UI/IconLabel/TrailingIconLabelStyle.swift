//
//  TrailingIconLabelStyle.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.title
            configuration.icon
        }
    }
}
