//
//  ObservableDefaultsCounterView.swift
//  VADefaultsExample
//
//  Created by VAndrJ on 1/23/25.
//

import SwiftUI

struct ObservableDefaultsCounterView: View {
    @Environment(ObservableDefaults.self) var defaults
    @State var counter = 0

    var body: some View {
        VStack {
            Text("defaults counter: \(defaults.counter)")
            Button("Increment defaults counter") {
                defaults.counter += 1
            }
            Spacer()
                .frame(height: 64)
            Text("counter: \(counter)")
            Button("Increment counter") {
                counter += 1
            }
        }
    }
}

#Preview {
    ObservableDefaultsCounterView()
}
