//
//  VADefaultsExampleApp.swift
//  VADefaultsExample
//
//  Created by VAndrJ on 1/23/25.
//

import SwiftUI

@main
struct VADefaultsExampleApp: App {
    @State var observableDefaults = ObservableDefaults()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Observable defaults counter") {
                        ObservableDefaultsCounterView()
                    }
                }
            }
            .environment(observableDefaults)
        }
    }
}
