//
//  ContentView.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        MainTabView()
            .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview { ContentView().environmentObject(AppState()) }
