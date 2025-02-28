//
//  CityViewModel.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 2/21/24.
//

import Foundation
import MapKit
import SwiftUI

@Observable
class CityViewModel {
  static let instance = CityViewModel()
  var lastCity: City?
  var cities: [City] = []
  var currentCities: [City] = []
  var currentCity: City?
  private var isSearching = false

  private init() {
    do {
      try loadCities()
    } catch {
      print("\(error)")
    }
  }

  func loadCities() throws {
    if let data = UserDefaults.standard.data(forKey: "cities") {
      let decoder = JSONDecoder()
      cities = try decoder.decode([City].self, from: data)
    }
  }

  func saveCities() throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(cities.isEmpty ? [City]() : cities)
    UserDefaults.standard.set(data, forKey: "cities")
  }

  func addCity(city: City) {
    cities.append(city)
  }

  func addCity() {
    if let city = currentCity {
      cities.append(city)
    } else {
      print("CityViewModel ==>> NO CITY TO ADD")
    }
  }

  func deleteCity(at indexSet: IndexSet) {
    cities.remove(atOffsets: indexSet)
  }

  func searchCity(text: String) {
    guard !text.isEmpty else {
      currentCity = nil
      return
    }

    let geoCoder = CLGeocoder()
    let location = text
    geoCoder.geocodeAddressString(location) { placemark, error in
      if error != nil {
        print(error!)
      }
      if placemark != nil {
        self.currentCity = nil
        self.currentCity = City(placemark: placemark![0])
      } else {
        self.currentCity = nil
      }
    }
  }

  func searchCityMKL(text: String) {
    isSearching = !text.isEmpty
    guard isSearching else {
      withAnimation {
        self.currentCities = []
      }
      return
    }

    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = text
    request.pointOfInterestFilter?.includes(MKPointOfInterestCategory.airport)
    let search = MKLocalSearch(request: request)
    search.start { response, error in
      guard self.isSearching else { return }
      if let error = error {
        print("Search error: \(error.localizedDescription)")
      } else if let response = response, !response.mapItems.isEmpty {
        self.currentCities = []
        for (index, item) in response.mapItems.enumerated() {
          if index < 8 {
            // Here you can process each placemark as needed
            // For example, adding it to an array or displaying it in your UI
            withAnimation {
              self.currentCities.append(City(placemark: item.placemark))
            }
          }
        }
      } else {
        withAnimation {
          self.currentCities = []
        }
      }
    }
  }

  func clearSearch() {
    isSearching = false
    withAnimation {
      self.currentCities = []
    }
  }
}
