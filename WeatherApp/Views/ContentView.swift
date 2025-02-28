//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/25/23.
//

import SwiftUI

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
      RequestLocationView()
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
  @Environment(PermissionViewModel.self) var permissionViewModel
  @State var selection: TabType = .search
//  @State var currentCity: City?
  @State var cvm = CityViewModel.instance

  @AppStorage("isTracking") var isTracking: Bool = false
  @AppStorage("firstLaunch") var firstLaunch = true

  func getData() {
    if permissionViewModel.authorizationStatus == .authorizedAlways ||
      permissionViewModel.authorizationStatus == .authorizedWhenInUse {
      cvm.currentCity = UserDefaults.standard.codableObject(dataType: City.self, key: "city")
      if firstLaunch {
        print("YES FIRST LAUNCH")
        isTracking = true
        firstLaunch = false
      }
      if isTracking {
        let newCity = City(lastLocation: permissionViewModel.lastLocation)
        cvm.lastCity = newCity
        if cvm.currentCity == nil {
          cvm.currentCity = newCity
        }
      } else {
        cvm.lastCity = nil
        // check if other cities pick first
        // else nil
        if cvm.currentCity == cvm.lastCity {
          if cvm.cities.count > 0 {
            cvm.currentCity = cvm.cities.first
          }
        }
      }
    } else {
      if let index = cvm.cities.firstIndex(where: { city in
        city.name == "My Location"
      }) {
        cvm.cities.remove(at: index)
      }
      cvm.currentCity = nil
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        TabView(selection: $selection, content: {
          CitySearchView(cvm: $cvm, isTracking: $isTracking, firstLaunch: $firstLaunch)
            .tag(TabType.search)
          if cvm.currentCity != nil {
            WeatherView(cvm: $cvm)
              .tag(TabType.weather)
          }
          SettingsView()
            .tag(TabType.settings)
        })
        .tabViewStyle(.page(indexDisplayMode: .never))
        VStack {
          Spacer()
          HStack {
            Capsule()
              .fill(selection == TabType.search ? Color(.systemGray5) : Color(.systemGray2))
              .frame(width: selection == TabType.search ? 20 : 8, height: 8)
              .transition(.slide)
              .animation(.easeInOut, value: selection)
            if cvm.currentCity != nil {
              Capsule()
                .fill(selection == TabType.weather ? Color(.systemGray5) : Color(.systemGray2))
                .frame(width: selection == TabType.weather ? 20 : 8, height: 8)
                .transition(.slide)
                .animation(.easeInOut, value: selection)
            }
            Capsule()
              .fill(selection == TabType.settings ? Color(.systemGray5) : Color(.systemGray2))
              .frame(width: selection == TabType.settings ? 20 : 8, height: 8)
              .transition(.slide)
              .animation(.easeInOut, value: selection)
          }
        }
        .padding(.bottom, 32)
      }
      .ignoresSafeArea()
    }
    .onAppear {
      print("ON APPEAR CONTENT VIEW")
      if !firstLaunch {
        getData()
      }
    }
    .onChange(of: permissionViewModel.authorizationStatus) { _, newValue in
      print("Authorization changed: \(newValue.rawValue)")
      getData()
    }
  }
}
