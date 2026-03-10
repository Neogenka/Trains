//
//  StoryViewModel.swift
//  Trains
//
//  Created by МAK on 10.03.2026.
//

import SwiftUI
import Combine

@MainActor
@Observable
final class StoryViewModel {
    
    let stories: [Story]
    let configuration: StoryView.Configuration
    
    var progress: CGFloat
    var timer: Timer.TimerPublisher
    var cancellable: Cancellable?
    
    init(stories: [Story], configuration: StoryView.Configuration, initialProgress: CGFloat) {
        self.stories = stories
        self.configuration = configuration
        self.progress = initialProgress
        self.timer = Self.createTimer(configuration: configuration)
    }
    
    var currentStoryIndex: Int {
        guard !stories.isEmpty else { return 0 }
        let raw = floor(progress * CGFloat(stories.count))
        let i = Int(raw)
        return max(0, min(i, stories.count - 1))
    }
    
    var currentStory: Story? {
        guard !stories.isEmpty else { return nil }
        return stories[currentStoryIndex]
    }
    
    func onAppear() {
        guard stories.count > 1 else { return }
        timer = Self.createTimer(configuration: configuration)
        cancellable = timer.connect()
    }
    
    func onDisappear() {
        cancellable?.cancel()
    }
    
    func timerTick() {
        var nextProgress = progress + configuration.progressPerTick
        if nextProgress >= 1 {
            nextProgress = 0
        }
        withAnimation {
            progress = nextProgress
        }
    }
    
    func nextStory() {
        let storiesCount = stories.count
        let currentStoryIndex = Int(progress * CGFloat(storiesCount))
        let nextStoryIndex = currentStoryIndex + 1 < storiesCount ? currentStoryIndex + 1 : 0
        withAnimation {
            progress = CGFloat(nextStoryIndex) / CGFloat(storiesCount)
        }
    }
    
    func resetTimer() {
        cancellable?.cancel()
        timer = Self.createTimer(configuration: configuration)
        cancellable = timer.connect()
    }
    
    static func createTimer(configuration: StoryView.Configuration) -> Timer.TimerPublisher {
        Timer.publish(every: configuration.timerTickInternal, on: .main, in: .common)
    }
}
