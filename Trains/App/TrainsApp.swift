//
//  TrainsApp.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import SwiftUI

@main
struct TravelScheduleApp: App {
    @StateObject private var app = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(app)
                .withGlobalErrors(app)
        }
    }
}
