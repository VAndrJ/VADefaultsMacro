//
//  Defaults.swift
//  VADefaultsExample
//
//  Created by VAndrJ on 1/23/25.
//

import Foundation
import VADefaults

@ObservableUserDefaultsData(keyPrefix: "com.vandrj.")
class ObservableDefaults {
    var counter: Int
}

@UserDefaultsData
class Defaults {
    var string: String?
}
