//
//  MainTabView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

enum Route: Hashable {
    case carriers(from: String, to: String)
}

struct MainTabView: View {
    
    struct StoryPair: Identifiable {
        let id = UUID()
        let stories: [Story]
    }
    
    private enum Constants {
        static let tabIconSize: CGFloat = 30
        static let firstTabSystemImage = "arrow.up.message.fill"
        static let secondTabAssetImage = "Vector"
    }
    
    @EnvironmentObject private var app: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var path: [Route] = []
    @State private var activePair: StoryPair?
    @State private var startIndex  = 0
    @State private var seen: Set<Int> = []
    
    private var isTabBarHidden: Bool {
        if let last = path.last, case .carriers = last { return true }
        return false
    }
    
    init() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundEffect = nil
        tab.shadowColor = .clear
        tab.shadowImage = UIImage()
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundEffect = nil
        nav.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                NavigationStack(path: $path) {
                    RouteInputSectionView(
                        actionButton: {},
                        actionSearchButton: { from, to in
                            path.append(.carriers(from: from, to: to))
                        }
                    )
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                            case let .carriers(from, to):
                                if let search = try? APIFactory.makeSearchService(),
                                   let carrier = try? APIFactory.makeCarrierService() {
                                    CarrierListView(headerFrom: from,
                                                    headerTo: to,
                                                    searchService: search,
                                                    carrierService: carrier
                                    )
                                } else {
                                    ErrorStateView(state: .server)
                                        .task { app.showError(.server) }
                                }
                        }
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
                .safeAreaInset(edge: .top,spacing: 0) {
                    if path.isEmpty {
                        StoriesStripView(stories: Story.odd, seenIndices: seen) { index in
                            guard index < Story.pairs.count else { return }
                            seen.insert(index)
                            activePair = StoryPair(stories: Story.pairs[index])
                            startIndex = 0
                        }
                        .background(Color(.systemBackground))
                    }
                }
                .fullScreenCover(item: $activePair) { pair in
                    StoryView(stories: pair.stories, initialIndex: startIndex)
                }
                .tabItem {
                    Image(systemName: Constants.firstTabSystemImage)
                        .renderingMode(.template)
                        .frame(width: Constants.tabIconSize, height: Constants.tabIconSize)
                }
                
                SettingsView()
                    .tabItem {
                        Image(Constants.secondTabAssetImage)
                            .renderingMode(.template)
                            .frame(width: Constants.tabIconSize, height: Constants.tabIconSize)
                    }
            }
            .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
            .toolbarBackground(isTabBarHidden ? .hidden : .visible, for: .tabBar)
            .tint(.ypBlack)
            .accentColor(.ypGray)
            .withGlobalErrors(app)
            
            if colorScheme == .light && !isTabBarHidden {
                Rectangle()
                    .fill(Color.ypGray)
                    .frame(height: 1.0 / UIScreen.main.scale)
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.bottom, 83)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
