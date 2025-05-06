//
//  CitySearchView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 2/24/24.
//

import CoreLocation
import SwiftUI
import WeatherKit

struct CitySearchView: View {
  @Environment(PermissionViewModel.self) var permissionViewModel
  @Binding var cvm: CityViewModel
  @State private var searchText = ""
  @FocusState var focusState: Bool
  @State var searchBarInIsFocus: Bool = false
  @State var showingAlert: Bool = false

  @Binding var isTracking: Bool
  @Binding var firstLaunch: Bool

  func toggleLocationUpdates() {
    if permissionViewModel.authorizationStatus == .authorizedWhenInUse || permissionViewModel.authorizationStatus == .authorizedAlways {
      if isTracking {
        permissionViewModel.cllm.stopUpdatingLocation()
        isTracking = false
      } else {
        permissionViewModel.cllm.startUpdatingLocation()
        isTracking = true
      }
    } else {
      permissionViewModel.requestPermission()
      isTracking = false
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // NavBar
      HStack {
        Text("Search")
          .font(.title)
          .fontWeight(.bold)
          .fontDesign(.monospaced)
        // TODO: DEBUG
//        Button("Debug") {
//          cvm.cities.removeAll()
//          Task {
//            do {
//              try cvm.saveCities()
//            } catch {
//              print(error.localizedDescription)
//            }
//          }
//        }
//        .buttonStyle(.bordered)
        Spacer()
        Button(action: {
          toggleLocationUpdates()
          if isTracking {
            cvm.lastCity = City(lastLocation: permissionViewModel.lastLocation)
            if cvm.currentCity == nil {
              cvm.currentCity = cvm.lastCity
            }
          } else {
            cvm.lastCity = nil
            if cvm.cities.count > 0 {
              cvm.currentCity = cvm.cities.first
            } else {
              cvm.currentCity = nil
            }
            if permissionViewModel.authorizationStatus == .denied {
              showingAlert = true
            }
          }
        }, label: {
          if isTracking {
            Image(systemName: "location.fill")
              .font(.system(size: 20))
              .foregroundStyle(Color.accentColor)
          } else {
            Image(systemName: "location.fill")
              .font(.system(size: 20))
              .foregroundStyle(Color(.systemGray4))
          }
        })
        .padding(.trailing, 10)
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 10)

      // Search Bar
      HStack(spacing: 0) {
        HStack(spacing: 5) {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
          TextField("Search", text: $searchText)
            .focused($focusState)
            .padding(.vertical, 5)
            .onChange(of: searchText) { _, newValue in
              if newValue != "" {
                cvm.searchCityMKL(text: newValue)
              }
              if newValue == "" {
                cvm.clearSearch()
              }
            }
            .onChange(of: focusState, { _, newValue in
              withAnimation {
                searchBarInIsFocus = newValue
              }
              if newValue && searchText != "" {
                // TODO: show again
                cvm.searchCityMKL(text: searchText)
              } else {
                // TODO: cancel should remove the dropdown
                cvm.clearSearch()
              }
            })
          if searchText != "" {
            Button(action: {
              searchText = ""
            }, label: {
              Image(systemName: "x.circle.fill")
                .foregroundColor(.gray)
            })
          }
        }
        .padding(.horizontal, 5)
        .background(content: {
          Color(.card)
        })
        .contentShape(Rectangle())
        .padding(.horizontal, 10)
        if searchBarInIsFocus {
          Button(action: {
            focusState = false
          }) {
            Text("Cancel")
          }
          .transition(.move(edge: .trailing))
          .padding(.trailing, searchBarInIsFocus ? 10 : 0)
        }
      }
      .fontDesign(.monospaced)

      // Cities List
      ZStack {
        List {
          ForEach([cvm.lastCity].compactMap { $0 } + cvm.cities, id: \.id) { city in
            CityItemView(city: city, currCity: cvm.currentCity)
              .onTapGesture {
                withAnimation {
                  cvm.currentCity = city
                  UserDefaults.standard.setCodableObject(city, forKey: "city")
                }
              }
              .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
              .listRowSeparator(.hidden)
              .contextMenu {
                if city.name != "My Location" {
                  Button("Delete") {
                    if let index = cvm.cities.firstIndex(of: city) {
                      withAnimation {
                        // remove city
                        cvm.cities.remove(at: index)
                        // save the new list
                        Task {
                          do {
                            try cvm.saveCities()
                          } catch {
                            print(error.localizedDescription)
                          }
                        }
                        // set new currentCity
                        if let first = cvm.cities.first {
                          print("FIRST")
                          print(first)
                          cvm.currentCity = first
                          UserDefaults.standard.setCodableObject(first, forKey: "city")
                        } else {
                          cvm.currentCity = nil
                        }
                      }
                    }
                  }
                } else {
                  Button("cant remove this :)") {
                  }
                }
              }
          }
        }
        .listStyle(.plain)
        .listRowSpacing(10)
        .padding(.horizontal, 10)
        .padding(.bottom, 64)

        // if searching
        if focusState {
          Color.black
            .opacity(0.5)
            .onTapGesture {
              focusState = false
            }
        }
        if !cvm.currentCities.isEmpty {
          VStack(spacing: 0) {
            ForEach(cvm.currentCities, id: \.id) { city in
              HStack(spacing: 0) {
                let name = city.name ?? ""
                let state = city.administrativeArea ?? ""
                let country = city.country ?? ""
                Group {
                  Text(name + ", ")
                    + Text(state != "" ? "\(state), " : "")
                    + Text(country)
                }
                .lineLimit(1)
                Spacer()
              }
              .padding()
              .background(content: {
                Color.background
              })
              .onTapGesture {
                searchText = ""
                cvm.currentCity = city
                UserDefaults.standard.setCodableObject(city, forKey: "city")
                if !cvm.cities.contains(where: { c in
                  c.getAddress() == city.getAddress()
                }) {
                  cvm.cities.append(city)
                }
                cvm.clearSearch()
                do {
                  try cvm.saveCities()
                } catch {
                  print(error.localizedDescription)
                }
                focusState = false
              }
              if city != cvm.currentCities.last {
                Divider()
              }
            }
            Spacer()
          }
        }
      }
    }
    .foregroundStyle(Color(.backgroundInvert))
    .background(content: {
      Color.background
    })
    .alert(isPresented: $showingAlert) {
      Alert(
        title: Text("Location Access Needed"),
        message: Text("To use this feature, please enable location access in Settings."),
        primaryButton: .default(Text("Open Settings")) {
          // Open app settings
          if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
          }
        },
        secondaryButton: .cancel()
      )
    }
  }
}
