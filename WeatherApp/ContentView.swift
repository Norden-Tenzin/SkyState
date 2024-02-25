//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/25/23.
//

import SwiftUI

enum TabType {
    case search
    case weather
    case settings
}

struct ContentView: View {
    @Environment(PermissionViewModel.self) var permissionViewModel

    var body: some View {
        switch permissionViewModel.authorizationStatus {
        case .notDetermined:
            RequestLocationView()
        case .restricted:
            Color.black
                .overlay(content: { Text("RESTRICTED").foregroundStyle(Color.white) })
        case .denied:
            RequestLocationView()
        case .authorizedAlways:
            JunctionView()
        case .authorizedWhenInUse:
            JunctionView()
        case .authorized:
            JunctionView()
        @unknown default:
            JunctionView()
        }
    }
}

struct RequestLocationView: View {
    @Environment(PermissionViewModel.self) var permissionViewModel
    @State var locationAccessAlert: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 30, content: {
            Spacer()
            Image(systemName: "globe.americas")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.black)
            Text("The App requires your location to get you the most accurate weather.")
                .padding(.horizontal, 75)
                .multilineTextAlignment(.center)
                .font(.system(size: 20, weight: .semibold))
            Button(action: {
                if permissionViewModel.authorizationStatus == .notDetermined {
                    permissionViewModel.requestPermission()
                } else {
                    locationAccessAlert = true
                }
//                viewModel.requestPermission()
            }, label: {
                    Label("Allow tracking", systemImage: "location.fill")
                })
                .padding(10)
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            Spacer()
        })
            .alert("Access to your location is essential for us to provide you with accurate weather information", isPresented: $locationAccessAlert, actions: {
            Button("Settings", role: .cancel) {
                locationAccessAlert = false
                openAppSettings()
            }
        })
    }
}

struct JunctionView: View {
    @State var selection: TabType = .search
    @State var currentCity: City?
    @State var cvm = CityViewModel.instance

    var body: some View {
        NavigationStack {
            TabView(selection: $selection,
                content: {
                    CitySearchView(cvm: $cvm, currentCity: $currentCity)
                        .tag(TabType.search)
                    if !cvm.cities.isEmpty {
                        WeatherView(currentCity: $currentCity)
                            .tag(TabType.weather)
                    }
                    SettingsView()
                        .tag(TabType.settings)
                })
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .ignoresSafeArea()
        }
            .onAppear() {
            if cvm.cities.isEmpty {
                selection = .search
            } else {
                selection = .weather
            }
        }
    }
}

#Preview() {
    @State var permissionViewModel: PermissionViewModel = PermissionViewModel()

    return ContentView()
        .environment(permissionViewModel)
}
