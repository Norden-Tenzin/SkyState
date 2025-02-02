//
//  Extensions.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 02/02/25.
//

import Foundation

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
