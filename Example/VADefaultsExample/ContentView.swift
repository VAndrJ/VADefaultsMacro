//
//  ContentView.swift
//  VADefaultsExample
//
//  Created by VAndrJ on 1/23/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(SomeDefaults.self) var defaults
    @State var counter = 0

    var body: some View {
        VStack {
            Text("counter: \(counter)")
            Button("Increment counter") {
                counter += 1
            }
            Spacer()
                .frame(height: 64)
            Text("defaults counter: \(defaults.counter)")
            Button("Increment defaults counter") {
                defaults.counter += 1
            }
        }
    }
}

#Preview {
    ContentView()
}
