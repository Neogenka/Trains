//
//  StoryCardView.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct StoryCardView: View {
    let story: Story
    let isSeen: Bool
    
    private let size = CGSize(width: 92, height: 140)
    private let corner: CGFloat = 16
    
    init(story: Story, isSeen: Bool = false) {
        self.story = story
        self.isSeen = isSeen
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let name = story.imageName {
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .opacity(isSeen ? 0.5 : 1.0)
            } else {
                story.backgroundColor
                    .frame(width: size.width, height: size.height)
                    .opacity(isSeen ? 0.5 : 1.0)
            }
            
            Text(story.title)
                .font(.regular12)
                .foregroundColor(.ypWhiteUniversal)
                .lineLimit(3)
                .padding(8)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(isSeen ? .clear : .ypBlue, lineWidth: 4)
        )
    }
}

#Preview("Card • Unseen (blue border)", traits: .sizeThatFitsLayout) {
    StoryCardView(story: .storyOne, isSeen: false)
        .padding()
}

#Preview("Card • Seen (50% opacity)", traits: .sizeThatFitsLayout) {
    StoryCardView(story: .storyOne, isSeen: true)
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}

#Preview("Side-by-side", traits: .sizeThatFitsLayout) {
    HStack(spacing: 16) {
        StoryCardView(story: .storyOne, isSeen: false)
        StoryCardView(story: .storyOne, isSeen: true)
    }
    .padding()
}

#Preview("Strip • Mixed", traits: .fixedLayout(width: 390, height: 200)) {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
            let items = Array(Story.all.prefix(8))
            ForEach(items.indices, id: \.self) { i in
                StoryCardView(story: items[i], isSeen: i.isMultiple(of: 2))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
