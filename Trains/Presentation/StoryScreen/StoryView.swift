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
    
    private var currentStoryIndex: Int {
        guard !stories.isEmpty else { return 0 }
        let raw = floor(progress * CGFloat(stories.count))
        let i = Int(raw)
        return max(0, min(i, stories.count - 1))
    }
    private var currentStory: Story? {
        guard !stories.isEmpty else { return nil }
        return stories[currentStoryIndex]
    }
    
    private let stories: [Story]
    private let configuration: Configuration
    @State private var progress: CGFloat = 0
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    
    init(stories: [Story] = Story.all, initialIndex: Int = 0) {
        self.stories = stories
        configuration = Configuration(storiesCount: stories.count)
        timer = Self.createTimer(configuration: configuration)
        
        let count = max(stories.count, 1)
        let start = max(0, min(initialIndex, count - 1))
        _progress = State(initialValue: CGFloat(start) / CGFloat(count))
    }
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            if let story = currentStory {
                StoriesContentView(story: story)
            }
            ProgressBar(numberOfSections: stories.count, progress: progress)
                .padding(.init(top: 28, leading: 12, bottom: 12, trailing: 12))
            CloseButton(action: { dismiss() })
                .padding(.top, 57)
                .padding(.trailing, 12)
        }
        .onAppear {
            guard stories.count > 1 else { return }
            timer = Self.createTimer(configuration: configuration)
            cancellable = timer.connect()
        }
        .onDisappear {
            cancellable?.cancel()
        }
        .onReceive(timer) { _ in
            timerTick()
        }
        .onTapGesture {
            nextStory()
            resetTimer()
        }
    }
    
    private func timerTick() {
        var nextProgress = progress + configuration.progressPerTick
        if nextProgress >= 1 {
            nextProgress = 0
        }
        withAnimation {
            progress = nextProgress
        }
    }
    
    private func nextStory() {
        let storiesCount = stories.count
        let currentStoryIndex = Int(progress * CGFloat(storiesCount))
        let nextStoryIndex = currentStoryIndex + 1 < storiesCount ? currentStoryIndex + 1 : 0
        withAnimation {
            progress = CGFloat(nextStoryIndex) / CGFloat(storiesCount)
        }
    }
    
    private func resetTimer() {
        cancellable?.cancel()
        timer = Self.createTimer(configuration: configuration)
        cancellable = timer.connect()
    }
    
    private static func createTimer(configuration: Configuration) -> Timer.TimerPublisher {
        Timer.publish(every: configuration.timerTickInternal, on: .main, in: .common)
    }
}

#Preview {
    StoryView()
}
