//
//  Helper.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/19/23.
//

import Foundation
import CoreLocation
import WeatherKit

func getCityState(lat: Double, long: Double) async -> [String: String] {
//    print("lat: \(lat) : long: \(long)")
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: lat, longitude: long)
    var res = [String: String] ()
    do {
        let placeMark = try await geoCoder.reverseGeocodeLocation(location)[0]
        if let country = placeMark.isoCountryCode {
            res["country"] = country
        }
        if let city = placeMark.locality {
            res["city"] = city
        }
    } catch {
        print(error)
    }
    return res
}

func fetchWeather(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?) async -> Weather? {
    do {
        let weatherServices = WeatherService()
        let home = CLLocation(latitude: latitude ?? 0, longitude: longitude ?? 0)
        return try await weatherServices.weather(for: home)
    } catch {
        print(error)
        return nil
    }
}

