# VADefaults


[![StandWithUkraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)
[![Support Ukraine](https://img.shields.io/badge/Support-Ukraine-FFD500?style=flat&labelColor=005BBB)](https://opensource.fb.com/support-ukraine)


[![Language](https://img.shields.io/badge/language-Swift%206.0-orangered.svg?style=flat)](https://www.swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-limegreen.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20macOS%20%7C%20macCatalyst-lightgray.svg?style=flat)](https://developer.apple.com/discover)


### VADefaults introduces macro to simplify `UserDefaults` usage and errors prevention.


2.x.x - Swift 6

1.3.1 - Swift 5.9


### @UserDefaultsValue


Adds a getter and setter wrapping `UserDefaults`.


Example 1:


```swift
@UserDefaultsValue(defaultValue: "Empty")
var value: String

// expands to 

var value: String {
    get {
        UserDefaults.standard.string(forKey: "value") ?? "Empty"
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "value")
    }
}
```


Example 2:


```swift
@UserDefaultsValue(key: "customKey", defaults: .testDefaults)
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


### @CodableUserDefaultsValue


Adds a getter and setter wrapping `UserDefaults` for `Codable` values.


Example 1:


```swift
@CodableUserDefaultsValue
var myCodableValue: MyCodable?

// expands to 

var myCodableValue: MyCodable? {
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
@CodableUserDefaultsValue(encoder: customEncoder, decoder: customDecoder)
var myCodableValue: MyCodable?

// expands to 

var myCodableValue: MyCodable? {
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


### @RawUserDefaultsValue


Adds a getter and setter wrapping `UserDefaults` for `RawRepresentable` values.


Example 1:


```swift
@RawUserDefaultsValue(rawType: Int.self)
var value: MyRawRepresentable?

// expands to 

var value: MyRawRepresentable? {
    get {
        (UserDefaults.standard.object(forKey: "value") as? Int).flatMap(MyRawRepresentable.init(rawValue:))
    }
    set {
        UserDefaults.standard.setValue(newValue?.rawValue, forKey: "value")
    }
}
```


Example 2:


```swift
@RawUserDefaultsValue(rawType: Int.self, defaultValue: MyRawRepresentable.undefined)
var value: MyRawRepresentable

// expands to 

var value: MyRawRepresentable {
    get {
        (UserDefaults.standard.object(forKey: "value") as? Int).flatMap(MyRawRepresentable.init(rawValue:)) ?? MyRawRepresentable.undefined
    }
    set {
        UserDefaults.standard.setValue(newValue.rawValue, forKey: "value")
    }
}
```


### @UserDefaultsData


Adds a variable and initializer to the class, and adds getters and setters to the variables wrapping `UserDefaults`.
Dependent macroses:
- @DefaultsValue
- @RawDefaultsValue
- @CodableDefaultsValue


Example 1:


```swift
@UserDefaultsData
class Defaults {
    var someVariable: Int
    let someConstant = true
}

// expands to 

class Defaults {
    var someVariable: Int {
        get {
            userDefaults.integer(forKey: "someVariable")
        }
        set {
            userDefaults.setValue(newValue, forKey: "someVariable")
        }
    }
    let someConstant = true

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
}
```


Example 2:


```swift
@UserDefaultsData(defaults: .test)
public class Defaults {
    @DefaultsValue(key: "customKey")
    var someVariable: Int
    var computedVariable: Bool { true }
}

// expands to 

public class Defaults {
    var someVariable: Int {
        get {
            userDefaults.integer(forKey: "customKey")
        }
        set {
            userDefaults.setValue(newValue, forKey: "customKey")
        }
    }
    var computedVariable: Bool { true }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults.test) {
        self.userDefaults = userDefaults
    }
}
```


Example 3:


```swift
@UserDefaultsData
public class Defaults {
    @DefaultsValue
    static var someVariable: Int // <-- error, not allowed
    @DefaultsValue
    class var someVariable: Int // <-- error, not allowed
}
```


### Observation


Just add `@Observable` to make `UserDefaultsData` observable. And `ObservationIgnored` to variables


Example:


```swift
@Observable
@UserDefaultsData
class Defaults {
    @ObservationIgnored
    var someVariable: Int
}

// expands to 

class Defaults {
    var someVariable: Int {
        get {
            access(keyPath: \.someVariable)
            userDefaults.integer(forKey: "someVariable")
        }
        set {
            withMutation(keyPath: \.someVariable) {
                userDefaults.setValue(newValue, forKey: "someVariable")
            }
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
}
```


#### TBD:


- `Codable` check. Throwable.


## Author

Volodymyr Andriienko, vandrjios@gmail.com


## License

VADefaults is available under the MIT license. See the LICENSE file for more info.
