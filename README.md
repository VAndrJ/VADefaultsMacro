# VADefaults


[![Support Ukraine](https://img.shields.io/badge/Support-Ukraine-FFD500?style=flat&labelColor=005BBB)](https://opensource.fb.com/support-ukraine)


[![Language](https://img.shields.io/badge/language-Swift%205.9-orangered.svg?style=flat)](https://www.swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-limegreen.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20macOS%20%7C%20macCatalyst-lightgray.svg?style=flat)](https://developer.apple.com/discover)


### VADefaults introduces macro to simplify `UserDefaults` usage and errors prevention.


### @UserDefaultValue


Adds a getter and setter wrapping `UserDefaults`.


Example 1:


```swift
@UserDefaultValue(defaultValue: "Empty")
var value: String

// expands to 

var value: String {
    get {
        UserDefaults.standard.string(forKey: "value") ?? "Empty"
    }
    set {
        UserDefaults.testDefaults.setValue(newValue, forKey: "value")
    }
}
```


Example 2:


```swift
@UserDefaultValue(key: "customKey", defaults: .testDefaults)
var value: Int

// expands to 

var value: Int {
    get {
        UserDefaults.testDefaults.integer(forKey: "customKey")
    }
    set {
        UserDefaults.testDefaults.setValue(newValue, forKey: "customKey")
    }
}
```


### @CodableUserDefaultValue


Adds a getter and setter wrapping `UserDefaults` for `Codable` values.


Example 1:


```swift
@CodableUserDefaultValue()
var myCodableValue: MyCodable?

// expands to 

var value: MyCodable? {
    get {
        UserDefaults.standard.data(forKey: "myCodableValue").flatMap {
            try? JSONDecoder().decode(MyCodable.self, from: $0)
        }
    }
    set {
        UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: "myCodableValue")
    }
}
```


Example 2:


```swift
@CodableUserDefaultValue(encoder: customEncoder, decoder: customDecoder)
var myCodableValue: MyCodable?

// expands to 

var value: MyCodable? {
    get {
        UserDefaults.standard.data(forKey: "myCodableValue").flatMap {
            try? customDecoder.decode(MyCodable.self, from: $0)
        }
    }
    set {
        UserDefaults.standard.set(try? customEncoder.encode(newValue), forKey: "myCodableValue")
    }
}
```


#### TBD:


- Value and `defaultValue` types comparison improvements.


- `Codable` check. Throwable.


- `RawRepresentable` improvements.


## Author

Volodymyr Andriienko, vandrjios@gmail.com


## License

VADefaults is available under the MIT license. See the LICENSE file for more info.
