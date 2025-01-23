//
//  VADefaultsExampleApp.swift
//  VADefaultsExample
//
//  Created by VAndrJ on 1/23/25.
//

import SwiftUI

@main
struct VADefaultsExampleApp: App {
    @State private var observableDefaults = ObservableDefaults()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Observable defaults counter") {
                        ObservableDefaultsCounterView()
                            .navigationTitle("Observable defaults counter")
                    }
                    NavigationLink("Defaults values") {
                        DefaultsValuesView()
                            .navigationTitle("Defaults values")
                    }
                }
            }
            .environment(observableDefaults)
        }
    }
}

extension EnvironmentValues {
    @Entry var defaults = Defaults()
}
