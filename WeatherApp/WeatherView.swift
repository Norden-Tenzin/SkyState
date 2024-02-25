//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/18/23.
//

import SwiftUI
import SwiftData
import WeatherKit
import CoreLocation

public enum Units: String {
    case american
    case other
}

struct WeatherView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("units") var units: Units = .american
    @State var vm: WeatherViewModel = WeatherViewModel()
    @State var loaded: Bool = false
    @State var weather: Weather?

    @State var latitude: CLLocationDegrees?
    @State var longitude: CLLocationDegrees?

    @State var country: String?
    @State var city: String?

    @State var week: [DayWeather] = []
    @Binding var currentCity: City?

    var body: some View {
        GeometryReader { geo in
            VStack {
                if loaded == false {
                    Text(currentCity?.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.clear)
                    Text("\(city ?? "City"), \(country ?? "Country")")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.clear)
                    Text("Now")
                        .foregroundStyle(.clear)
                        .padding(.bottom, 100)
                    Image(systemName: weather?.currentWeather.symbolName ?? "sun.max")
                        .font(.system(size: 70))
                        .foregroundStyle(.clear)
                    Text("_ _")
                        .font(.system(size: 60, weight: .regular))
                        .padding(.bottom, 50)
                    Text(String(weather?.currentWeather.condition.description ?? ""))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.clear)
                        .padding(.bottom, 50)
                    Text("Wind")
                        .foregroundStyle(.clear)
                    HStack {
                        Image(systemName: "wind")
                            .font(.system(size: 20, weight: .bold))
                        Text(getWindSpeed(weather?.currentWeather.wind.speed.value))
                            .font(.system(size: 15))
                    }
                        .foregroundStyle(.clear)
                        .padding(.bottom, 50)
                    VStack {
                        Color.clear
                            .frame(height: 30)
                        Color.clear
                            .frame(height: 30)
                        Color.clear
                            .frame(height: 30)
                        Color.clear
                            .frame(height: 30)
                    }
                        .padding(30)
                } else {
                    //                            NavigationLink {
                    //                                SettingsView(units: $units)
                    //                            } label: {
                    //                                Image(systemName: "gear")
                    //                                    .padding(.trailing, 20)
                    //                                    .padding(.top, 10)
                    //                                    .font(.system(size: 25))
                    //
                    //                            }
                    //                                .buttonStyle(.plain)

                    Text(currentCity?.name ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                    Text("\(city ?? "City"), \(country ?? "Country")")
//                        .font(.system(size: 20))
                    Text("Now")
                        .padding(.bottom, geo.size.height * 0.1)
                    Image(systemName: weather?.currentWeather.symbolName ?? "sun.max")
                        .font(.system(size: 70))
                    Text(getTemp(weather?.currentWeather.temperature.value))
                        .font(.system(size: 60, weight: .bold))
                        .padding(.bottom, geo.size.height * 0.05)
                    Text(String(weather?.currentWeather.condition.description ?? ""))
                        .font(.system(size: 20, weight: .bold))
                        .padding(.bottom, geo.size.height * 0.04)
                    Text("Wind")
                    HStack {
                        Image(systemName: "wind")
                            .font(.system(size: 20, weight: .bold))
                        Text(getWindSpeed(weather?.currentWeather.wind.speed.value))
                            .font(.system(size: 15))
                        Image(systemName: "arrow.up")
                            .rotationEffect(Angle(degrees: weather?.currentWeather.wind.direction.value ?? 0))
                        Text(weather?.currentWeather.wind.compassDirection.abbreviation ?? "")
                    }
                        .padding(.bottom, 40)
                    Grid(alignment: .topLeading,
                        verticalSpacing: 5) {
                        ForEach(week, id: \.date) { day in
                            GridRow {
                                Text(getWeekDay(date: day.date))
                                Spacer()
                                Image(systemName: day.symbolName)
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer()
                                Text(getTemp(day.highTemperature.value))
                                Text(getTemp(day.lowTemperature.value))
                            }
                                .frame(height: 30)
                        }
                    }
                        .padding(30)
                }
            }
                .padding(.top, 45)
                .scrollIndicators(.hidden)
                .task {
                currentCity = UserDefaults.standard.codableObject(dataType: City.self, key: "city")
                load()
            }
        }
    }

    func load() {
        print("IN LOAD")
        Task {
//            loaded = false
//            week = []
//            let lat = vm.currentPlacemark?.location?.coordinate.latitude
//            let lng = vm.currentPlacemark?.location?.coordinate.longitude
//
//            latitude = lat
//            longitude = lng
//            let CountryCity = await getCityState(lat: lat ?? 0, long: lng ?? 0)
//            country = CountryCity["country"] ?? "Country"
//            city = CountryCity["city"] ?? "City"
//            weather = await fetchWeather(latitude: lat, longitude: lng)
//            let dailyForecast = weather?.dailyForecast
//            for index in 0..<min(dailyForecast?.count ?? 0, 5) {
//                if let forecast = dailyForecast? [index] {
//                    week.append(forecast)
//                }
//            }
//            loaded = true

            loaded = false
            week = []
            if let cc = currentCity {
                let lat = cc.coord_lat ?? 0.0
                let lng = cc.coord_long ?? 0.0
                let CountryCity = await getCityState(lat: lat, long: lng)
                country = CountryCity["country"] ?? "Country"
                city = CountryCity["city"] ?? "City"
                weather = await fetchWeather(latitude: lat, longitude: lng)
                let dailyForecast = weather?.dailyForecast
                for index in 0..<min(dailyForecast?.count ?? 0, 5) {
                    if let forecast = dailyForecast? [index] {
                        week.append(forecast)
                    }
                }
            } else {
                print("HERE")
            }
            loaded = true
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

    func getWindSpeed(_ input: Double?) -> String {
        if let input = input {
            if units == .other {
                return "\(Int(round(input))) km/h"
            } else {
                return "\(Int(round(input * 0.6213712))) mph"
            }
        } else {
            return "0°"
        }
    }
}

func getWeekDay(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, d"
    return dateFormatter.string(from: date)
}

func openAppSettings() {
    if let bundleId = Bundle.main.bundleIdentifier,
        let url = URL(string: "\(UIApplication.openSettingsURLString)&root=Privacy&path=LOCATION/\(bundleId)") {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

//    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
//        if UIApplication.shared.canOpenURL(appSettingsURL) {
//            UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
//        }
//    }
//
//    // System settings:
//    let url = URL(string: UIApplication.openSettingsURLString)!
//    UIApplication.shared.open(url)
//
//    // Notifications settings:
//    URL(string: Loca)!
//    UIApplication.shared.open(url)
}
//
//#Preview {
//    @State var viewModel: WeatherViewModel = .init()
//    //    @AppStorage var userSettings = UserSettings()
//
//    @AppStorage("units") var units: Units = .american
//    @State var loaded: Bool = false
//    @State var weather: Weather?
//
//    @State var latitude: CLLocationDegrees?
//    @State var longitude: CLLocationDegrees?
//
//    @State var country: String?
//    @State var city: String?
//
//    @State var week: [DayWeather] = []
//
//    WeatherView(viewModel: viewModel, units: units, loaded: loaded, weather: weather, latitude: latitude, longitude: longitude, country: country, city: city, week: week)
//}
