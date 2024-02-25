//
//  SavedCities.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 2/23/24.
//

import Foundation
import SwiftData
import MapKit

@Model
class SavedCities {
    var id: String
    var name: String
    var administrativeArea: String
    var country: String
    var coord_lat: CLLocationDegrees
    var coord_long: CLLocationDegrees
//    var coordinates: CLLocationCoordinate2D {
//        guard let lat = coord_lat, let lng = coord_long else { return nil }
//        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
//    }
    var flagIconURL: String
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
