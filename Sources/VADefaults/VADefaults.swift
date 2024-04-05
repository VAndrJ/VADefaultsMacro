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
public macro DefaultValue(
    key: String? = nil
) = #externalMacro(module: "VADefaultsMacros", type: "DefaultValue")

@attached(accessor)
public macro DefaultValue<T>(
    key: String? = nil,
    defaultValue: T?
) = #externalMacro(module: "VADefaultsMacros", type: "DefaultValue")

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
public macro CodableDefaultValue(
    key: String? = nil,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableDefaultValue")

@attached(accessor)
public macro CodableDefaultValue<T: Codable>(
    key: String? = nil,
    defaultValue: T?,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableDefaultValue")

@attached(accessor)
public macro RawUserDefaultValue<R>(
    rawType: R.Type,
    key: String? = nil,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "RawUserDefaultValue")

@attached(accessor)
public macro RawUserDefaultValue<T: RawRepresentable, R>(
    rawType: R.Type,
    key: String? = nil,
    defaultValue: T?,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "RawUserDefaultValue") where T.RawValue == R

@attached(accessor)
public macro RawDefaultValue<R>(
    rawType: R.Type,
    key: String? = nil
) = #externalMacro(module: "VADefaultsMacros", type: "RawDefaultValue")

@attached(accessor)
public macro RawDefaultValue<T: RawRepresentable, R>(
    rawType: R.Type,
    key: String? = nil,
    defaultValue: T?
) = #externalMacro(module: "VADefaultsMacros", type: "RawDefaultValue") where T.RawValue == R

@attached(member, names: named(userDefaults), named(init(userDefaults:)))
@attached(memberAttribute)
public macro UserDefault(
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefault")
