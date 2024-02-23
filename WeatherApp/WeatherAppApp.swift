//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/18/23.
//

import SwiftUI
import SwiftData

@main
struct WeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
//                WeatherView()
                ContentView()
            }
        }
    }
}

#Preview(body: {
    ContentView()
})
