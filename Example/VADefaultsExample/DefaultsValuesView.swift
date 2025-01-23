//
//  DefaultsValuesView.swift
//  VADefaultsExample
//
//  Created by VAndrJ on 1/23/25.
//

import SwiftUI

struct DefaultsValuesView: View {
    @Environment(\.defaults) private var defaults
    @State private var text = ""
    @State private var defaultsString: String?

    var body: some View {
        VStack {
            TextField("Enter text", text: $text)
            Button("Save to defaults") {
                defaults.string = text
            }
            Spacer()
                .frame(height: 64)
            Button("Show saved text") {
                defaultsString = defaults.string
            }
            Text(defaultsString ?? "No saved text")
        }
        .padding()
    }
}
