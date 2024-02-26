//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/18/23.
//

import CoreLocation
import SwiftData
import SwiftUI
import WeatherKit

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
        GeometryReader { _ in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(currentCity?.name ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .fontDesign(.monospaced)
                        .redacted(reason: !loaded ? .placeholder : [])
                    if city != "City", country != "Country" {
                        Text("\(city ?? "City"), \(country ?? "Country")")
                            .fontDesign(.monospaced)
                            .redacted(reason: !loaded ? .placeholder : [])
                    }
                    Text("Now")
                        .fontDesign(.monospaced)
                        .redacted(reason: !loaded ? .placeholder : [])
                }
                Spacer()
                VStack(spacing: 0) {
                    Image(systemName: weather?.currentWeather.symbolName ?? "cloud.fill")
                        .foregroundStyle(loaded ? Color.black : Color(red: 0.839, green: 0.839, blue: 0.839, opacity: 1.000))
                        .font(.system(size: 70))
                    if loaded {
                        Text(getTemp(weather?.currentWeather.temperature.value))
                            .font(.system(size: 60, weight: .bold))
                            .fontDesign(.monospaced)
                    } else {
                        Text("__")
                            .font(.system(size: 60))
                            .fontDesign(.monospaced)
                    }
                }
                Spacer()
                Text(String(weather?.currentWeather.condition.description.uppercased() ?? "PARTLY CLOUDY"))
                    .font(.system(size: 20, weight: .black))
                    .fontDesign(.default)
                    .fontWidth(.expanded)
                    .redacted(reason: !loaded ? .placeholder : [])
                Spacer()
                VStack(spacing: 0) {
                    Text("Wind")
                        .fontDesign(.monospaced)
                        .redacted(reason: !loaded ? .placeholder : [])
                    HStack {
                        Image(systemName: "wind")
                            .font(.system(size: 20, weight: .bold))
                        Text(getWindSpeed(weather?.currentWeather.wind.speed.value))
                            .font(.system(size: 15))
                        Image(systemName: "arrow.up")
                            .rotationEffect(Angle(degrees: weather?.currentWeather.wind.direction.value ?? 0))
                        Text(weather?.currentWeather.wind.compassDirection.abbreviation ?? "")
                    }
                    .foregroundStyle(loaded ? Color.black : Color(red: 0.839, green: 0.839, blue: 0.839, opacity: 1.000))
                    .overlay {
                        if loaded {
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(red: 0.839, green: 0.839, blue: 0.839, opacity: 1.000))
                        }
                    }
                }
                .fontDesign(.monospaced)
                Spacer()
                if loaded {
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                    .fontDesign(.monospaced)
                } else {
                    Color.clear
                        .frame(height: 170)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                }
            }
            .scrollIndicators(.hidden)
            .task {
                load()
            }
            .onAppear {
                currentCity = UserDefaults.standard.codableObject(dataType: City.self, key: "city")
            }
        }
    }

    func load() {
        Task {
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
                for index in 0 ..< min(dailyForecast?.count ?? 0, 5) {
                    if let forecast = dailyForecast? [index] {
                        week.append(forecast)
                    }
                }
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
}
