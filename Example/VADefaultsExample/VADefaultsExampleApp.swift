//
//  VADefaultsExampleApp.swift
//  VADefaultsExample
//
//  Created by VAndrJ on 1/23/25.
//

import SwiftUI

@main
struct VADefaultsExampleApp: App {
    @State var defaults = SomeDefaults()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                NavigationLink("Next") {
                    ContentView()
                        .environment(defaults)
                }
            }
        }
    }
}
