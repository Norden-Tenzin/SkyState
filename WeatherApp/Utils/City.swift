//
//  City.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 2/21/24.
//

import Foundation
import MapKit

struct City: Identifiable, Equatable, Codable {
  var id: String = UUID().uuidString
  var name: String?
  var administrativeArea: String?
  var country: String?
  var coord_lat: CLLocationDegrees?
  var coord_long: CLLocationDegrees?
  var flagIconURL: String?

  private enum CodingKeys: String, CodingKey {
    case name, administrativeArea, country, coord_lat, coord_long, flagIconURL
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
//    print(container.allKeys)
    name = try container.decode(String.self, forKey: .name)
    administrativeArea = try container.decode(String.self, forKey: .administrativeArea)
    country = try container.decode(String.self, forKey: .country)
    coord_lat = try container.decode(Double.self, forKey: .coord_lat)
    coord_long = try container.decode(Double.self, forKey: .coord_long)
    flagIconURL = try container.decode(String.self, forKey: .flagIconURL)
  }

  init(name: String? = nil, administrativeArea: String? = nil, country: String? = nil, coordinates: CLLocationCoordinate2D? = nil, region: CLRegion? = nil, flagIconURL: String? = nil) {
    self.name = name
    self.administrativeArea = administrativeArea
    self.country = country
    coord_lat = coordinates?.latitude
    coord_long = coordinates?.longitude
    self.flagIconURL = flagIconURL
  }

  init(lastLocation: CLLocation?) {
    name = "My Location"
    administrativeArea = ""
    country = ""
    coord_lat = lastLocation?.coordinate.latitude ?? 0.0
    coord_long = lastLocation?.coordinate.longitude ?? 0.0
    flagIconURL = ""
  }

  init(placemark: CLPlacemark) {
    name = placemark.name
    administrativeArea = placemark.administrativeArea
    country = placemark.country
    coord_lat = placemark.location?.coordinate.latitude
    coord_long = placemark.location?.coordinate.longitude
    flagIconURL = placemark.isoCountryCode
  }

  static func == (lhs: City, rhs: City) -> Bool {
    lhs.id == rhs.id
  }

  func getAddress() -> String {
    let name: String = self.name ?? ""
    let state: String = administrativeArea ?? ""
    let country: String = self.country ?? ""
    return "\(name)_\(state)_\(country)"
  }
}
