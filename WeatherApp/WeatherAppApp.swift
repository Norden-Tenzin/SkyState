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
    @State var permissionViewModel: PermissionViewModel = PermissionViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
//                WeatherView()
                ContentView()
                    .environment(permissionViewModel)
            }
        }
    }
}
