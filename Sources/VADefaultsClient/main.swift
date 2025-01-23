import VADefaults
import Foundation
import Observation

let testDefaults = UserDefaults(suiteName: "com.vandrj.test")!
testDefaults.clear()
UserDefaults.standard.clear()

@UserDefaultsValue
var boolTest: Bool
assert(boolTest == false)
boolTest = true
assert(boolTest == true)

@UserDefaultsValue(defaultValue: true)
var boolDefaultTest: Bool
assert(boolDefaultTest == true)
boolDefaultTest = false
assert(boolDefaultTest == false)

@UserDefaultsValue(defaultValue: true)
var boolOptionalDefaultTest: Bool?
assert(boolOptionalDefaultTest == true)
boolOptionalDefaultTest = false
assert(boolOptionalDefaultTest == false)

@UserDefaultsValue(defaultValue: Date(timeIntervalSince1970: 23))
var dateTest: Date
assert(dateTest == Date(timeIntervalSince1970: 23))
dateTest = Date(timeIntervalSince1970: 42)
assert(dateTest == Date(timeIntervalSince1970: 42))

@UserDefaultsValue(defaultValue: NSDate(timeIntervalSince1970: 23))
var nsDateTest: NSDate
assert(nsDateTest == NSDate(timeIntervalSince1970: 23))
nsDateTest = NSDate(timeIntervalSince1970: 42)
assert(nsDateTest == NSDate(timeIntervalSince1970: 42))

@UserDefaultsValue(defaultValue: Data())
var dataTest: Data
assert(dataTest == Data())
dataTest = "a".data(using: .utf8)!
assert(dataTest == "a".data(using: .utf8)!)

@UserDefaultsValue(defaultValue: NSData())
var nsDataTest: NSData
assert(nsDataTest == NSData())
nsDataTest = "a".data(using: .utf8)! as NSData
assert(nsDataTest == "a".data(using: .utf8)! as NSData)

@UserDefaultsValue
var intTest: Int
assert(intTest == 0)
intTest = 42
assert(intTest == 42)

@UserDefaultsValue(defaultValue: 1)
var intDefaultTest: Int
assert(intDefaultTest == 1)
intDefaultTest = 42
assert(intDefaultTest == 42)

@UserDefaultsValue
var floatTest: Float
assert(floatTest == 0)
floatTest = 42
assert(floatTest == 42)

@UserDefaultsValue
var doubleTest: Double
assert(doubleTest == 0)
doubleTest = 42
assert(doubleTest == 42)

@UserDefaultsValue(defaultValue: "a")
var stringTest: String
assert(stringTest == "a")
stringTest = "42"
assert(stringTest == "42")

@UserDefaultsValue
var stringOptionalTest: String?
assert(stringOptionalTest == nil)
stringOptionalTest = "42"
assert(stringOptionalTest == "42")

@UserDefaultsValue(defaultValue: "a")
var nsStringTest: NSString
assert(nsStringTest == "a")
nsStringTest = "42"
assert(nsStringTest == "42")

@UserDefaultsValue(defaultValue: "a")
var nsStringOptionalTest: NSString
assert(nsStringOptionalTest == "a")
nsStringOptionalTest = "42"
assert(nsStringOptionalTest == "42")

@UserDefaultsValue(defaultValue: 4)
var nsNumberTest: NSNumber
assert(nsNumberTest == 4)
nsNumberTest = 42
assert(nsNumberTest == 42)

@UserDefaultsValue(defaultValue: 4)
var nsNumberOptionalTest: NSNumber?
assert(nsNumberOptionalTest == 4)
nsNumberOptionalTest = 42
assert(nsNumberOptionalTest == 42)

@UserDefaultsValue(defaultValue: 4.0)
var nsNumberDeaultTest: NSNumber
assert(nsNumberDeaultTest == 4)
nsNumberDeaultTest = 42
assert(nsNumberDeaultTest == 42)

@UserDefaultsValue(defaultValue: URL(string: "https://apple.com")!)
var urlTest: URL
assert(urlTest == URL(string: "https://apple.com")!)
urlTest = URL(string: "https://swift.org")!
assert(urlTest == URL(string: "https://swift.org")!)

@UserDefaultsValue(defaultValue: 2)
var int8Test: Int8
assert(int8Test == 2)
int8Test = 42
assert(int8Test == 42)

@UserDefaultsValue(defaultValue: 2)
var int16Test: Int16
assert(int16Test == 2)
int16Test = 42
assert(int16Test == 42)

@UserDefaultsValue(defaultValue: 2)
var int32Test: Int32
assert(int32Test == 2)
int32Test = 42
assert(int32Test == 42)

@UserDefaultsValue(defaultValue: 2)
var int64Test: Int64
assert(int64Test == 2)
int64Test = 42
assert(int64Test == 42)

@UserDefaultsValue(defaultValue: 2)
var uIntTest: UInt
assert(uIntTest == 2)
uIntTest = 42
assert(uIntTest == 42)

@UserDefaultsValue(defaultValue: 2)
var uInt8Test: UInt8
assert(uInt8Test == 2)
uInt8Test = 42
assert(uInt8Test == 42)

@UserDefaultsValue(defaultValue: 2)
var uInt16Test: UInt16
assert(uInt16Test == 2)
uInt16Test = 42
assert(uInt16Test == 42)

@UserDefaultsValue(defaultValue: 4)
var uInt32Test: UInt32
assert(uInt32Test == 4)
uInt32Test = 42
assert(uInt32Test == 42)

@UserDefaultsValue(defaultValue: 4)
var uInt64Test: UInt64
assert(uInt64Test == 4)
uInt64Test = 42
assert(uInt64Test == 42)

@UserDefaultsValue(defaultValue: [4])
var arrTest: [Int]
assert(arrTest == [4])
arrTest = [42]
assert(arrTest == [42])

@UserDefaultsValue
var arrOptionalTest: [Int]?
assert(arrOptionalTest == nil)
arrOptionalTest = [42]
assert(arrOptionalTest == [42])

@UserDefaultsValue(defaultValue: ["4": 4])
var dictTest: [String: Int]
assert(dictTest == ["4": 4])
dictTest = ["4": 42]
assert(dictTest == ["4": 42])

@UserDefaultsValue
var dictOptionalTest: [String: Int]?
assert(dictOptionalTest == nil)
dictOptionalTest = ["4": 42]
assert(dictOptionalTest == ["4": 42])

class StaticTestClass {
    @UserDefaultsValue(defaultValue: 42)
    static var staticValue: Int
    @UserDefaultsValue(defaultValue: 42)
    class var classValue: Int

    static func check() {
        assert(staticValue == 42)
        staticValue = 1
        assert(staticValue == 1)
        assert(classValue == 42)
        classValue = 1
        assert(classValue == 1)
    }
}
StaticTestClass.check()

struct CodableStruct: Codable, Equatable {
    var value = 2
}
struct NotCodableStruct: Equatable {
    var value = 2
}
let codableStruct = CodableStruct(value: 42)
let notCodableStruct = NotCodableStruct(value: 42)
let encoder = JSONEncoder()
let decoder = JSONDecoder()

@CodableUserDefaultsValue
var codableTest: CodableStruct?
assert(codableTest == nil)
codableTest = CodableStruct()
assert(codableTest == CodableStruct())

@CodableUserDefaultsValue(defaultValue: codableStruct)
var codableDefaultTest: CodableStruct
assert(codableDefaultTest == codableStruct)
codableDefaultTest = CodableStruct()
assert(codableDefaultTest == CodableStruct())

@CodableUserDefaultsValue(defaultValue: [codableStruct])
var codableArrayDefaultTest: [CodableStruct]
assert(codableArrayDefaultTest == [codableStruct])
let newCodableArray = [CodableStruct(value: 5)]
codableArrayDefaultTest = newCodableArray
assert(codableArrayDefaultTest == newCodableArray)

@CodableUserDefaultsValue(defaultValue: ["a": codableStruct])
var codableDictionaryDefaultTest: [String: CodableStruct]
assert(codableDictionaryDefaultTest == ["a": codableStruct])
let newCodableDictionary = ["b": codableStruct]
codableDictionaryDefaultTest = newCodableDictionary
assert(codableDictionaryDefaultTest == newCodableDictionary)
codableDictionaryDefaultTest["c"] = codableStruct
assert(codableDictionaryDefaultTest == newCodableDictionary.merging(["c": codableStruct], uniquingKeysWith: { $1 }))

@CodableUserDefaultsValue(key: "customKey", defaultValue: codableStruct, encoder: encoder, decoder: decoder)
var codableEncoderDecoderTest: CodableStruct
assert(codableEncoderDecoderTest == codableStruct)
codableEncoderDecoderTest = CodableStruct()
assert(codableEncoderDecoderTest == CodableStruct())

enum ExampleEnum: Int {
    case undefined = 0
    case question = -1
    case answer = 42
}

@RawUserDefaultsValue(rawType: Int.self)
var representableTest: ExampleEnum?
assert(representableTest == nil)
representableTest = .question
assert(representableTest == .question)

@RawUserDefaultsValue(rawType: Int.self, defaultValue: ExampleEnum.undefined)
var representableDefaultTest: ExampleEnum
assert(representableDefaultTest == .undefined)
representableDefaultTest = .answer
assert(representableDefaultTest == .answer)

@UserDefaultsData
class Defaults {
    @UserDefaultsValue
    static var someStaticVariable: Int
    @UserDefaultsValue(defaultValue: 2)
    class var someClassVariable: Int
    @RawDefaultsValue(rawType: Int.self, defaultValue: ExampleEnum.undefined)
    var rawRepresentableExampleValue: ExampleEnum
    @CodableDefaultsValue(defaultValue: CodableStruct(value: 0))
    var codableExampleValue: CodableStruct
    @DefaultsValue
    var defaultExampleValue: Int
}

assert(Defaults.someStaticVariable == 0)
Defaults.someStaticVariable = 42
assert(Defaults.someStaticVariable == 42)
assert(Defaults.someClassVariable == 2)
Defaults.someClassVariable = 42
assert(Defaults.someClassVariable == 42)

let defaults = Defaults()
assert(defaults.rawRepresentableExampleValue == .undefined)
defaults.rawRepresentableExampleValue = .question
assert(defaults.rawRepresentableExampleValue == .question)
assert(defaults.codableExampleValue == CodableStruct(value: 0))
defaults.codableExampleValue = CodableStruct(value: 42)
assert(defaults.codableExampleValue == CodableStruct(value: 42))
assert(defaults.defaultExampleValue == 0)
defaults.defaultExampleValue = 42
assert(defaults.defaultExampleValue == 42)

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@ObservableUserDefaultsData
class ObservableDefaults {
    @RawDefaultsValue(rawType: Int.self, defaultValue: ExampleEnum.undefined)
    var rawRepresentableExample1Value: ExampleEnum
    @CodableDefaultsValue(defaultValue: CodableStruct(value: 0))
    var codableExample1Value: CodableStruct
    @DefaultsValue
    var defaultExample1Value: Int
}

if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
    let observableDefaults = ObservableDefaults()
    assert(observableDefaults.rawRepresentableExample1Value == .undefined)
    observableDefaults.rawRepresentableExample1Value = .question
    assert(observableDefaults.rawRepresentableExample1Value == .question)
    assert(observableDefaults.codableExample1Value == CodableStruct(value: 0))
    observableDefaults.codableExample1Value = CodableStruct(value: 42)
    assert(observableDefaults.codableExample1Value == CodableStruct(value: 42))
    assert(observableDefaults.defaultExample1Value == 0)
    observableDefaults.defaultExample1Value = 42
    assert(observableDefaults.defaultExample1Value == 42)
}

UserDefaults.standard.clear()
testDefaults.clear()

print("success")

extension UserDefaults {

    func clear() {
        dictionaryRepresentation().forEach {
            removeObject(forKey: $0.key)
        }
    }
}
