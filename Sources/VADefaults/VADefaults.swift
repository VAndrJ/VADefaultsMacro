// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(accessor)
public macro UserDefaultsValue(
    key: String? = nil,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefaultsValue")

@attached(accessor)
public macro UserDefaultsValue<T>(
    key: String? = nil,
    defaultValue: T?,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefaultsValue")

@attached(accessor)
public macro DefaultsValue(
    key: String? = nil
) = #externalMacro(module: "VADefaultsMacros", type: "DefaultsValue")

@attached(accessor)
public macro ObservationDefaultsTracked() = #externalMacro(module: "VADefaultsMacros", type: "DefaultsValue")

@attached(accessor)
public macro DefaultsValue<T>(
    key: String? = nil,
    defaultValue: T?
) = #externalMacro(module: "VADefaultsMacros", type: "DefaultsValue")

@attached(accessor)
public macro CodableUserDefaultsValue(
    key: String? = nil,
    defaults: UserDefaults = .standard,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableUserDefaultsValue")

@attached(accessor)
public macro CodableUserDefaultsValue<T: Codable>(
    key: String? = nil,
    defaultValue: T?,
    defaults: UserDefaults = .standard,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableUserDefaultsValue")

@attached(accessor)
public macro CodableDefaultsValue(
    key: String? = nil,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableDefaultsValue")

@attached(accessor)
public macro CodableDefaultsValue<T: Codable>(
    key: String? = nil,
    defaultValue: T?,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
) = #externalMacro(module: "VADefaultsMacros", type: "CodableDefaultsValue")

@attached(accessor)
public macro RawUserDefaultsValue<R>(
    rawType: R.Type,
    key: String? = nil,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "RawUserDefaultsValue")

@attached(accessor)
public macro RawUserDefaultsValue<T: RawRepresentable, R>(
    rawType: R.Type,
    key: String? = nil,
    defaultValue: T?,
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "RawUserDefaultsValue") where T.RawValue == R

@attached(accessor)
public macro RawDefaultsValue<R>(
    rawType: R.Type,
    key: String? = nil
) = #externalMacro(module: "VADefaultsMacros", type: "RawDefaultsValue")

@attached(accessor)
public macro RawDefaultsValue<T: RawRepresentable, R>(
    rawType: R.Type,
    key: String? = nil,
    defaultValue: T?
) = #externalMacro(module: "VADefaultsMacros", type: "RawDefaultsValue") where T.RawValue == R

@attached(member, names: named(userDefaults), named(init(userDefaults:)))
@attached(memberAttribute)
public macro UserDefaultsData(
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "UserDefaultsData")

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@attached(
    member,
    names: named(userDefaults),
    named(init(userDefaults:)),
    named(_$observationRegistrar),
    named(access),
    named(withMutation)
)
@attached(memberAttribute)
@attached(extension, conformances: Observable)
public macro ObservableUserDefaultsData(
    defaults: UserDefaults = .standard
) = #externalMacro(module: "VADefaultsMacros", type: "ObservableUserDefaultsData")
