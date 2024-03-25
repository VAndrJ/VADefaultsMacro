// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(accessor)
public macro UserDefaultValue(
    key: String? = nil,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefaultValue")

@attached(accessor)
public macro UserDefaultValue<T>(
    key: String? = nil,
    defaultValue: T?,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefaultValue")

@attached(accessor)
public macro CodableUserDefaultValue(
    key: String? = nil,
    defaults: UserDefaults = .standard,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableUserDefaultValue")

@attached(accessor)
public macro CodableUserDefaultValue<T: Codable>(
    key: String? = nil,
    defaultValue: T?,
    defaults: UserDefaults = .standard,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableUserDefaultValue")

@attached(accessor)
public macro RawUserDefaultValue<R>(
    rawType: R.Type,
    key: String? = nil,
    defaultValue: Any? = nil,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "RawUserDefaultValue")

@attached(accessor)
public macro RawUserDefaultValue<T: RawRepresentable, R>(
    rawType: R.Type,
    key: String? = nil,
    defaultValue: T?,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "RawUserDefaultValue") where T.RawValue == R
