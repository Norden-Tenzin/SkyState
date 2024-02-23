//
//  SearchBar.swift
//  WeatherApp
//
//  Created by Tenzin Norden on 2/21/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    @FocusState var isBarFocused: Bool

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .focused($isBarFocused)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                }
            )
                .padding(.leading, self.isEditing ? 20 : 20)
                .padding(.trailing, self.isEditing ? 10 : 20)
                .onTapGesture {
                withAnimation {
                    self.isEditing = true
                }
            }
            if isEditing {
                Button(action: {
                    withAnimation {
                        self.isEditing = false
                        self.isBarFocused = false
                    }
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, self.isEditing ? 20 : 0)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
