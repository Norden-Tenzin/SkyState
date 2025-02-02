//
//  Models.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 02/02/25.
//

import Foundation
import SwiftData
import MapKit

@Model
final class Item {
  var timestamp: Date
  
  init(timestamp: Date) {
    self.timestamp = timestamp
  }
}

@Model
class SavedCities {
  var id: String
  var name: String
  var administrativeArea: String
  var country: String
  var coord_lat: CLLocationDegrees
  var coord_long: CLLocationDegrees
  var flagIconURL: String
  
  init(city: City) {
    self.id = UUID().uuidString
    self.name = city.name ?? ""
    self.country = city.country ?? ""
    self.administrativeArea = city.administrativeArea ?? ""
    self.coord_lat = city.coord_lat ?? 0.0
    self.coord_long = city.coord_long ?? 0.0
    self.flagIconURL = city.flagIconURL ?? ""
  }
}

