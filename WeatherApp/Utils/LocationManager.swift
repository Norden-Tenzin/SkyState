//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 02/02/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  let cllm = CLLocationManager()
  @Published var locationStatus: CLAuthorizationStatus?
  @Published var lastLocation: CLLocation?

  override init() {
    super.init()
    cllm.delegate = self
    cllm.desiredAccuracy = kCLLocationAccuracyBest
    cllm.requestWhenInUseAuthorization()
    cllm.startUpdatingLocation()
  }
  
  func checkLocationAuthorization() {
    cllm.delegate = self
    cllm.startUpdatingLocation()
    switch cllm.authorizationStatus {
    case .notDetermined://The user choose allow or denny your app to get the location yet
      cllm.requestWhenInUseAuthorization()
    case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
      print("Location restricted")
    case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
      print("Location denied")
    case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
      print("Location authorizedAlways")
    case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
      print("Location authorized when in use")
      lastLocation = cllm.location
    @unknown default:
      print("Location service disabled")
    }
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {//Trigged every time authorization status changes
    checkLocationAuthorization()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    lastLocation = location
  }
}

