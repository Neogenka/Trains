//
//  StoryView.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI
import Combine

struct StoryView: View {
    
    struct Configuration {
        let timerTickInternal: TimeInterval
        let progressPerTick: CGFloat
        
        init(storiesCount: Int, secondsPerStory: TimeInterval = 5,
             timerTickInternal: TimeInterval = 0.05) {
            self.timerTickInternal = timerTickInternal
            self.progressPerTick = 1.0 / CGFloat(storiesCount) / secondsPerStory * (CGFloat(timerTickInternal) / CGFloat(secondsPerStory)) / CGFloat(max(storiesCount, 1))
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var model: StoryViewModel
    
    init(stories: [Story] = Story.all, initialIndex: Int = 0) {
        let configuration = Configuration(storiesCount: stories.count)
        let count = max(stories.count, 1)
        let start = max(0, min(initialIndex, count - 1))
        let initialProgress = CGFloat(start) / CGFloat(count)
        _model = State(initialValue: StoryViewModel(
            stories: stories,
            configuration: configuration,
            initialProgress: initialProgress
        ))
    }
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            if let story = model.currentStory {
                StoriesContentView(story: story)
            }
            ProgressBar(numberOfSections: model.stories.count, progress: model.progress)
                .padding(.init(top: 28, leading: 12, bottom: 12, trailing: 12))
            CloseButton(action: { dismiss() })
                .padding(.top, 57)
                .padding(.trailing, 12)
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
        .onReceive(model.timer) { _ in
            timerTick()
        }
        .onTapGesture {
            nextStory()
            resetTimer()
        }
    }
    
    private func timerTick() {
        model.timerTick()
    }
    
    private func nextStory() {
        model.nextStory()
    }
    
    private func resetTimer() {
        model.resetTimer()
    }
    
    private static func createTimer(configuration: Configuration) -> Timer.TimerPublisher {
        StoryViewModel.createTimer(configuration: configuration)
    }
}

#Preview {
    StoryView()
}
