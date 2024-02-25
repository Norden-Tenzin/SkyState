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
    let prompt: String
    let padding: Double

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: padding / 2) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $text)
                    .focused($isBarFocused)
                    .padding(.vertical, 5)
                if text != "" {
                    Button(action: {
                        text = ""
                    }, label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.gray)
                        })
                }
            }
                .padding(.horizontal, padding / 2)
                .background(content: {
                Color(.systemGray6)
            })
                .padding(.horizontal, padding)
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
                    .padding(.trailing, self.isEditing ? padding : 0)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
