//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/19/23.
//

import CoreLocation
import Foundation
import SwiftUI
import WeatherKit

@Observable
class PermissionViewModel: NSObject, CLLocationManagerDelegate {
  var authorizationStatus: CLAuthorizationStatus
  let locationManager: LocationManager

  override init() {
    locationManager = LocationManager()
    authorizationStatus = locationManager.cllm.authorizationStatus
  }
}

@Observable
class WeatherViewModel {
  var lastSeenLocation: CLLocation?
  var currentPlacemark: CLPlacemark?

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    lastSeenLocation = locations.first
    fetchPlacemark(for: locations.first)
  }

  func fetchPlacemark(for location: CLLocation?) {
    guard let location = location else { return }
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { placemarks, _ in
      self.currentPlacemark = placemarks?.first
    }
  }
}

