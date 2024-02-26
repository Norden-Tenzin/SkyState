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
    @FocusState var focusState: Bool
    @State private var searchText = ""
    @Binding var cvm: CityViewModel
    @Binding var currentCity: City?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Search")
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                Spacer()
                Button(action: {
                    switch permissionViewModel.authorizationStatus {
                    case .authorized:
                        permissionViewModel.authorizationStatus = .denied
                    case .notDetermined:
                        permissionViewModel.requestPermission()
                    case .restricted:
                        permissionViewModel.requestPermission()
                    case .denied:
                        permissionViewModel.requestPermission()
                    case .authorizedAlways:
                        permissionViewModel.authorizationStatus = .denied
                    case .authorizedWhenInUse:
                        permissionViewModel.authorizationStatus = .denied
                    @unknown default:
                        permissionViewModel.requestPermission()
                    }
                }, label: {
                    if permissionViewModel.authorizationStatus == .authorizedAlways || permissionViewModel.authorizationStatus == .authorizedWhenInUse {
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
            SearchBar(text: $searchText, isBarFocused: _focusState, prompt: "City & Airport", padding: 10)
                .fontDesign(.monospaced)
            ZStack {
                List {
                    ForEach(cvm.cities, id: \.id) { city in
                        CityItemView(city: city, currCity: currentCity)
                            .onTapGesture {
                                withAnimation {
                                    currentCity = city
                                    UserDefaults.standard.setCodableObject(city, forKey: "city")
                                }
                            }
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowSeparator(.hidden)
                            .contextMenu {
                                Button("Delete") {
                                    if city.name != "My Location" {
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
                                                    currentCity = first
                                                    UserDefaults.standard.setCodableObject(first, forKey: "city")
                                                } else {
                                                    currentCity = nil
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .listRowSpacing(10)
                .padding(.horizontal, 10)
                if !cvm.currentCities.isEmpty {
                    List {
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
                            .onTapGesture {
                                searchText = ""
                                currentCity = city
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
                            }
                            .padding(.horizontal)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background {
                        if !cvm.currentCities.isEmpty {
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()
                        }
                    }
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            if newValue != "" {
                cvm.searchCityMKL(text: newValue)
            }
            if newValue == "" {
                cvm.clearSearch()
            }
        }
        .onChange(of: focusState) { _, newValue in
            if newValue && searchText != "" {
                // TODO: show again
                cvm.searchCityMKL(text: searchText)
            } else {
                // TODO: cancel should remove the dropdown
                cvm.clearSearch()
            }
        }
        .onChange(of: permissionViewModel.authorizationStatus) { _, _ in
            if permissionViewModel.authorizationStatus == .authorizedAlways || permissionViewModel.authorizationStatus == .authorizedWhenInUse {
                let newCity: City = City()
                do {
                    try cvm.loadCities()
                } catch {
                    print(error.localizedDescription)
                }
                if !cvm.cities.contains(where: { cc in
                    cc.name == "My Location"
                }) {
                    cvm.cities = [newCity] + cvm.cities
                }
                currentCity = newCity
                UserDefaults.standard.setCodableObject(newCity, forKey: "city")
            } else {
                if let index = cvm.cities.firstIndex(where: { city in
                    city.name == "My Location"
                }) {
                    cvm.cities.remove(at: index)
                }
                currentCity = nil
            }
        }
    }
}

struct CityItemView: View {
    @AppStorage("units") var units: Units = .american
    let city: City
    var currCity: City?
    @State var weather: Weather?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(.systemGray6))
                .frame(height: 100)
            HStack {
                VStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            city.getAddress() == currCity?.getAddress() ?? "" ? Color.yellow : Color(.systemGray3)
                        )
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(city.name ?? "")
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .lineLimit(1)
                        let time: String = {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:MM"
                            let str = dateFormatter.string(from: CLLocation(latitude: city.coord_lat ?? 0.0, longitude: city.coord_long ?? 0.0).timestamp)
                            return str
                        }()
                        Text(time)
                            .font(.system(size: 14))
                        Spacer()
                        HStack {
                            Text(weather?.currentWeather.condition.description ?? "")
                                .font(.system(size: 14))
                            Image(systemName: weather?.currentWeather.symbolName ?? "sun.max")
                                .font(.system(size: 20))
                                .fontWeight(.light)
                                .padding(.bottom, 5)
                        }
                    }
                    Spacer()
                    VStack {
                        Text(getTemp(weather?.currentWeather.temperature.value))
                            .font(.system(size: 50, weight: .bold))
                            .fontDesign(.monospaced)
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding(10)
        }
        .fontDesign(.monospaced)
        .onAppear {
            Task {
                weather = await fetchWeather(latitude: city.coord_lat ?? 0.0, longitude: city.coord_long ?? 0.0)
            }
        }
    }

    func getTemp(_ input: Double?) -> String {
        if let input = input {
            if units == .other {
                return "\(Int(round(input)))°"
            } else {
                return "\(Int(round((input * 9 / 5) + 32)))°"
            }
        } else {
            return "0°"
        }
    }
}
