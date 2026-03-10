//
//  StoriesStripView.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct StoriesStripView: View {
    let stories: [Story]
    var seenIndices: Set<Int> = []
    var onTap: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(stories.enumerated()), id: \.offset) { i, s in
                    StoryCardView(story: s, isSeen: seenIndices.contains(i))
                        .onTapGesture { onTap(i) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
    }
}

#Preview("Stories strip") {
    StoriesStripView(stories: Story.odd) { _ in }
        .padding(.vertical, 8)
}
