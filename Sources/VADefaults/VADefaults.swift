// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(accessor)
public macro UserDefaultValue<T>(
    key: String? = nil,
    defaultValue: T? = Optional<Void>.none,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefaultValue")
