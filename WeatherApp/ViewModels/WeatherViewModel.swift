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
  var lastLocation: CLLocation?
  let cllm = CLLocationManager()

  override init() {
    authorizationStatus = CLAuthorizationStatus.notDetermined
    super.init()
    cllm.delegate = self
    cllm.desiredAccuracy = kCLLocationAccuracyBest
    cllm.requestWhenInUseAuthorization()
    authorizationStatus = cllm.authorizationStatus
    cllm.startUpdatingLocation()
  }

  func requestPermission() {
    cllm.requestWhenInUseAuthorization()
    authorizationStatus = cllm.authorizationStatus
  }

  func checkLocationAuthorization() {
    cllm.delegate = self
    cllm.startUpdatingLocation()
    switch cllm.authorizationStatus {
    case .notDetermined: // The user choose allow or denny your app to get the location yet
      cllm.requestWhenInUseAuthorization()
    case .restricted: // The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
      print("Location restricted")
    case .denied: // The user dennied your app to get location or disabled the services location or the phone is in airplane mode
      print("Location denied")
    case .authorizedAlways: // This authorization allows you to use all location services and receive location events whether or not your app is in use.
      print("Location authorizedAlways")
    case .authorizedWhenInUse: // This authorization allows you to use all location services and receive location events only when your app is in use
      print("Location authorized when in use")
      lastLocation = cllm.location
    @unknown default:
      print("Location service disabled")
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { // Trigged every time authorization status changes
    authorizationStatus = manager.authorizationStatus
    checkLocationAuthorization()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    lastLocation = location
  }
}
