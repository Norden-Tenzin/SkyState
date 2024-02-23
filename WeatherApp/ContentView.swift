//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/25/23.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var cvm = CityViewModel.instance

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .onChange(of: searchText) { oldValue, newValue in
                if newValue != "" {
                    cvm.searchCity(text: newValue)
                } else {
                    cvm.currentCity = nil
                }
            }
            if cvm.currentCity != nil {
                Text(cvm.currentCity?.id.uuidString ?? "")
                Text(cvm.currentCity?.name ?? "")
                Text(cvm.currentCity?.region?.description ?? "")
                Text(cvm.currentCity?.coordinates.debugDescription ?? "")
            }
            Spacer()
        }
    }
}

struct ContentView1: View {
    @State var viewModel = WeatherViewModel()
    var body: some View {
        switch viewModel.authorizationStatus {
        case .notDetermined:
            RequestLocationView(viewModel: viewModel)
        case .restricted:
            Color.black
                .overlay(content: { Text("RESTRICTED").foregroundStyle(Color.white) })
        case .denied:
            RequestLocationView(viewModel: viewModel)
        case .authorizedAlways:
            WeatherView(viewModel: viewModel)
        case .authorizedWhenInUse:
            WeatherView(viewModel: viewModel)
        case .authorized:
            WeatherView(viewModel: viewModel)
        @unknown default:
            WeatherView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}

struct RequestLocationView: View {
    @State var locationAccessAlert: Bool = false
    var viewModel: WeatherViewModel
    var body: some View {
        VStack(alignment: .center, spacing: 30, content: {
            Spacer()
            Image(systemName: "globe.americas")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.black)
            Text("The App requires your location to get you the most accurate weather.")
                .padding(.horizontal, 75)
                .multilineTextAlignment(.center)
                .font(.system(size: 20, weight: .semibold))
            Button(action: {
                if viewModel.authorizationStatus == .notDetermined {
                    viewModel.requestPermission()
                } else {
                    locationAccessAlert = true
                }
//                viewModel.requestPermission()
            }, label: {
                    Label("Allow tracking", systemImage: "location.fill")
                })
                .padding(10)
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            Spacer()
        })
            .alert("Access to your location is essential for us to provide you with accurate weather information", isPresented: $locationAccessAlert, actions: {
            Button("Settings", role: .cancel) {
                locationAccessAlert = false
                openAppSettings()
            }
        })
    }
}
