// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(accessor)
public macro UserDefaultValue<T>(
    key: String? = nil,
    defaultValue: T? = Optional<Void>.none,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefaultValue")
@attached(accessor)
public macro CodableUserDefaultValue<T: Codable>(
    key: String? = nil,
    defaultValue: T? = Optional<String>.none,
    defaults: UserDefaults = .standard,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableUserDefaultValue")
