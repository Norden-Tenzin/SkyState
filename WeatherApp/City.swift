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
//    var coordinates: CLLocationCoordinate2D? {
//        guard let lat = coord_lat, let lng = coord_long else { return nil }
//        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
//    }
    var flagIconURL: String?
//    var reg_lat: CLLocationDegrees?
//    var reg_long: CLLocationDegrees?
//    var reg_id: String?
//    var reg_radius: Double?
//    var region: CLCircularRegion? {
//        guard let lat = reg_lat,
//            let lng = reg_long,
//            let id = reg_id,
//            let radius = reg_radius else { return nil }
//        return CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lng), radius: radius, identifier: id)
//    }

//    private enum CodingKeys: String, CodingKey {
//        case name, administrativeArea, country, coord_lat, coord_long, flagIconURL, reg_lat, reg_long, reg_id, reg_radius
//    }

    private enum CodingKeys: String, CodingKey {
        case name, administrativeArea, country, coord_lat, coord_long, flagIconURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print(container.allKeys)
        name = try container.decode(String.self, forKey: .name)
        administrativeArea = try container.decode(String.self, forKey: .administrativeArea)
        country = try container.decode(String.self, forKey: .country)
        coord_lat = try container.decode(Double.self, forKey: .coord_lat)
        coord_long = try container.decode(Double.self, forKey: .coord_long)
        flagIconURL = try container.decode(String.self, forKey: .flagIconURL)
//        reg_lat = try container.decode(CLLocationDegrees.self, forKey: .reg_lat)
//        reg_long = try container.decode(CLLocationDegrees.self, forKey: .reg_long)
//        reg_id = try container.decode(String.self, forKey: .reg_id)
//        reg_radius = try container.decode(Double.self, forKey: .reg_radius)
    }

    init(name: String? = nil, administrativeArea: String? = nil, country: String? = nil, coordinates: CLLocationCoordinate2D? = nil, region: CLRegion? = nil, flagIconURL: String? = nil) {
        self.name = name
        self.administrativeArea = administrativeArea
        self.country = country
        self.coord_lat = coordinates?.latitude
        self.coord_long = coordinates?.longitude
        self.flagIconURL = flagIconURL
    }

    init() {
        let location: LocationManager = LocationManager()
        self.name = "My Location"
        self.administrativeArea = ""
        self.country = ""
        self.coord_lat = location.lastLocation?.coordinate.latitude ?? 0.0
        self.coord_long = location.lastLocation?.coordinate.longitude ?? 0.0
        self.flagIconURL = ""
//        self.reg_lat = nil
//        self.reg_long = nil
//        self.reg_id = nil
//        self.reg_radius = nil
    }

    init(placemark: CLPlacemark) {
        self.name = placemark.name
        self.administrativeArea = placemark.administrativeArea
        self.country = placemark.country
        self.coord_lat = placemark.location?.coordinate.latitude
        self.coord_long = placemark.location?.coordinate.longitude
        self.flagIconURL = placemark.isoCountryCode
//        self.reg_lat = (placemark.region as? CLCircularRegion)?.center.latitude
//        self.reg_long = (placemark.region as? CLCircularRegion)?.center.longitude
//        self.reg_id = (placemark.region as? CLCircularRegion)?.identifier
//        self.reg_radius = (placemark.region as? CLCircularRegion)?.radius
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }

    func getAddress() -> String {
        let name: String = self.name ?? ""
        let state: String = self.administrativeArea ?? ""
        let country: String = self.country ?? ""
        return "\(name)_\(state)_\(country)"
    }
}
