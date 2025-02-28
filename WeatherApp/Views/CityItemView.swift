//
//  CityItemView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 03/02/25.
//

import CoreLocation
import SwiftUI
import WeatherKit

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
