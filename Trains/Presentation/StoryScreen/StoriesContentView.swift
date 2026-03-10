//
//  StoriesContentView.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct StoriesContentView: View {
    let story: Story
    
    var body: some View {
        ZStack {
            story.backgroundColor
                .ignoresSafeArea()
            
            if let imageName = story.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .clipped()
            }
        }
        
        .overlay(alignment: .bottomLeading) {
            VStack {
//                Spacer()
                VStack(alignment: .leading, spacing: 10) {
                    Text(story.title)
                        .font(.bold34)
                        .lineLimit(2)
                        .foregroundColor(.ypWhiteUniversal)
                    Text(story.description)
                        .font(.regular20)
                        .lineLimit(3)
                        .foregroundColor(.ypWhiteUniversal)
                }
                .padding(.init(top: 0, leading: 16, bottom: 40, trailing: 16))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
    }
}

#Preview {
    StoriesContentView(story: .storyOne)
}
