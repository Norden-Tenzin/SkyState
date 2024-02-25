//
//  SettingsView.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 10/20/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("units") var units: Units = .american

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            HStack {
                Text("Units")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading, 10)
                Spacer()
                Picker("Units", selection: $units, content: {
                    Text("🇺🇸")
                        .tag(Units.american)
                        .font(.system(size: 40))
                    Text("🇪🇺")
                        .tag(Units.other)
                        .font(.system(size: 40))
                })
                    .pickerStyle(.wheel)
                    .frame(width: 150, height: 100)
            }
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text("Like what i do?")
                        .padding(.top, 20)
                    Text("Say hi 👋") + Text("[@norden](https://twitter.com/nordten)")
                }
                Spacer()
            }
            Spacer()
            Spacer()
        }
            .padding(.top, 45)
            .padding(.horizontal, 20)
//            .navigationBarBackButtonHidden()
//            .toolbar(content: {
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: { dismiss() }, label: {
//                        Image(systemName: "chevron.backward")
//                            .padding(.top, 10)
//                            .font(.system(size: 20))
//                    })
//                    .buttonStyle(.plain)
//            }
//            ToolbarItem(placement: .principal) {
//                Text("Settings")
//                    .font(.system(size: 20, weight: .bold))
//            }
//        })
    }
}
