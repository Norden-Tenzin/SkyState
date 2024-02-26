//
//  Helper.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/19/23.
//

import Foundation
import CoreLocation
import WeatherKit

//func latLong(lat: Double, long: Double) {
//    let geoCoder = CLGeocoder()
//    let location = CLLocation(latitude: lat, longitude: long)
//    geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
//        print("Response GeoLocation : \(placemarks)")
//        var placeMark: CLPlacemark!
//        placeMark = placemarks?[0]
//
//        // Country
//        if let country = placeMark.addressDictionary!["Country"] as? String {
//            print("Country :- \(country)")
//            // City
//            if let city = placeMark.addressDictionary!["City"] as? String {
//                print("City :- \(city)")
//                // State
//                if let state = placeMark.addressDictionary!["State"] as? String {
//                    print("State :- \(state)")
//                    // Street
//                    if let street = placeMark.addressDictionary!["Street"] as? String {
//                        print("Street :- \(street)")
//                        let str = street
//                        let streetNumber = str.components(
//                            separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
//                        print("streetNumber :- \(streetNumber)" as Any)
//
//                        // ZIP
//                        if let zip = placeMark.addressDictionary!["ZIP"] as? String {
//                            print("ZIP :- \(zip)")
//                            // Location name
//                            if let locationName = placeMark?.addressDictionary?["Name"] as? String {
//                                print("Location Name :- \(locationName)")
//                                // Street address
//                                if let thoroughfare = placeMark?.addressDictionary!["Thoroughfare"] as? NSString {
//                                    print("Thoroughfare :- \(thoroughfare)")
//
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    })
//}

func getCityState(lat: Double, long: Double) async -> [String: String] {
    print("lat: \(lat) : long: \(long)")
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
    print(res)
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

enum DNTime {
    case day
    case night
}

extension UserDefaults {
  func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String) {
    let encoded = try? JSONEncoder().encode(data)
    set(encoded, forKey: defaultName)
  }
}

extension UserDefaults {
  func codableObject<T : Codable>(dataType: T.Type, key: String) -> T? {
    guard let userDefaultData = data(forKey: key) else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: userDefaultData)
  }
}
