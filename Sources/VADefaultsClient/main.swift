import VADefaults
import Foundation

extension UserDefaults {

    func clear() {
        dictionaryRepresentation().forEach {
            UserDefaults.standard.removeObject(forKey: $0.key)
        }
    }
}

let testDefaults = UserDefaults(suiteName: "com.vandrj.test")!
testDefaults.clear()
UserDefaults.standard.clear()

@UserDefaultValue
var boolTest: Bool
assert(boolTest == false)
boolTest = true
assert(boolTest == true)

@UserDefaultValue(defaultValue: true)
var boolDefaultTest: Bool
assert(boolDefaultTest == true)
boolDefaultTest = false
assert(boolDefaultTest == false)

@UserDefaultValue(defaultValue: true)
var boolOptionalDefaultTest: Bool?
assert(boolOptionalDefaultTest == true)
boolOptionalDefaultTest = false
assert(boolOptionalDefaultTest == false)

@UserDefaultValue(defaultValue: Date(timeIntervalSince1970: 23))
var dateTest: Date
assert(dateTest == Date(timeIntervalSince1970: 23))
dateTest = Date(timeIntervalSince1970: 42)
assert(dateTest == Date(timeIntervalSince1970: 42))

@UserDefaultValue(defaultValue: NSDate(timeIntervalSince1970: 23))
var nsDateTest: NSDate
assert(nsDateTest == NSDate(timeIntervalSince1970: 23))
nsDateTest = NSDate(timeIntervalSince1970: 42)
assert(nsDateTest == NSDate(timeIntervalSince1970: 42))

@UserDefaultValue(defaultValue: Data())
var dataTest: Data
assert(dataTest == Data())
dataTest = "a".data(using: .utf8)!
assert(dataTest == "a".data(using: .utf8)!)

@UserDefaultValue(defaultValue: NSData())
var nsDataTest: NSData
assert(nsDataTest == NSData())
nsDataTest = "a".data(using: .utf8)! as NSData
assert(nsDataTest == "a".data(using: .utf8)! as NSData)

@UserDefaultValue
var intTest: Int
assert(intTest == 0)
intTest = 42
assert(intTest == 42)

@UserDefaultValue(defaultValue: 1)
var intDefaultTest: Int
assert(intDefaultTest == 1)
intDefaultTest = 42
assert(intDefaultTest == 42)

@UserDefaultValue
var floatTest: Float
assert(floatTest == 0)
floatTest = 42
assert(floatTest == 42)

@UserDefaultValue
var doubleTest: Double
assert(doubleTest == 0)
doubleTest = 42
assert(doubleTest == 42)

@UserDefaultValue(defaultValue: "a")
var stringTest: String
assert(stringTest == "a")
stringTest = "42"
assert(stringTest == "42")

@UserDefaultValue
var stringOptionalTest: String?
assert(stringOptionalTest == nil)
stringOptionalTest = "42"
assert(stringOptionalTest == "42")

@UserDefaultValue(defaultValue: "a")
var nsStringTest: NSString
assert(nsStringTest == "a")
nsStringTest = "42"
assert(nsStringTest == "42")

@UserDefaultValue(defaultValue: "a")
var nsStringOptionalTest: NSString
assert(nsStringOptionalTest == "a")
nsStringOptionalTest = "42"
assert(nsStringOptionalTest == "42")

@UserDefaultValue(defaultValue: 4)
var nsNumberTest: NSNumber
assert(nsNumberTest == 4)
nsNumberTest = 42
assert(nsNumberTest == 42)

@UserDefaultValue(defaultValue: 4)
var nsNumberOptionalTest: NSNumber?
assert(nsNumberOptionalTest == 4)
nsNumberOptionalTest = 42
assert(nsNumberOptionalTest == 42)

@UserDefaultValue(defaultValue: 4.0)
var nsNumberDeaultTest: NSNumber
assert(nsNumberDeaultTest == 4)
nsNumberDeaultTest = 42
assert(nsNumberDeaultTest == 42)

@UserDefaultValue(defaultValue: URL(string: "https://apple.com")!)
var urlTest: URL
assert(urlTest == URL(string: "https://apple.com")!)
urlTest = URL(string: "https://swift.org")!
assert(urlTest == URL(string: "https://swift.org")!)

@UserDefaultValue(defaultValue: 2)
var int8Test: Int8
assert(int8Test == 2)
int8Test = 42
assert(int8Test == 42)

@UserDefaultValue(defaultValue: 2)
var int16Test: Int16
assert(int16Test == 2)
int16Test = 42
assert(int16Test == 42)

@UserDefaultValue(defaultValue: 2)
var int32Test: Int32
assert(int32Test == 2)
int32Test = 42
assert(int32Test == 42)

@UserDefaultValue(defaultValue: 2)
var int64Test: Int64
assert(int64Test == 2)
int64Test = 42
assert(int64Test == 42)

@UserDefaultValue(defaultValue: 2)
var uIntTest: UInt
assert(uIntTest == 2)
uIntTest = 42
assert(uIntTest == 42)

@UserDefaultValue(defaultValue: 2)
var uInt8Test: UInt8
assert(uInt8Test == 2)
uInt8Test = 42
assert(uInt8Test == 42)

@UserDefaultValue(defaultValue: 2)
var uInt16Test: UInt16
assert(uInt16Test == 2)
uInt16Test = 42
assert(uInt16Test == 42)

@UserDefaultValue(defaultValue: 4)
var uInt32Test: UInt32
assert(uInt32Test == 4)
uInt32Test = 42
assert(uInt32Test == 42)

@UserDefaultValue(defaultValue: 4)
var uInt64Test: UInt64
assert(uInt64Test == 4)
uInt64Test = 42
assert(uInt64Test == 42)

@UserDefaultValue(defaultValue: [4])
var arrTest: [Int]
assert(arrTest == [4])
arrTest = [42]
assert(arrTest == [42])

@UserDefaultValue
var arrOptionalTest: [Int]?
assert(arrOptionalTest == nil)
arrOptionalTest = [42]
assert(arrOptionalTest == [42])

@UserDefaultValue(defaultValue: ["4": 4])
var dictTest: [String: Int]
assert(dictTest == ["4": 4])
dictTest = ["4": 42]
assert(dictTest == ["4": 42])

@UserDefaultValue
var dictOptionalTest: [String: Int]?
assert(dictOptionalTest == nil)
dictOptionalTest = ["4": 42]
assert(dictOptionalTest == ["4": 42])

class StaticTestClass {
    @UserDefaultValue(defaultValue: 42)
    static var value: Int

    static func check() {
        assert(value == 42)
        value = 1
        assert(value == 1)
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

@CodableUserDefaultValue
var codableTest: CodableStruct?
assert(codableTest == nil)
codableTest = CodableStruct()
assert(codableTest == CodableStruct())

@CodableUserDefaultValue(defaultValue: codableStruct)
var codableDefaultTest: CodableStruct
assert(codableDefaultTest == codableStruct)
codableDefaultTest = CodableStruct()
assert(codableDefaultTest == CodableStruct())

@CodableUserDefaultValue(key: "customKey", defaultValue: codableStruct, encoder: encoder, decoder: decoder)
var codableEncoderDecoderTest: CodableStruct
assert(codableEncoderDecoderTest == codableStruct)
codableEncoderDecoderTest = CodableStruct()
assert(codableEncoderDecoderTest == CodableStruct())

enum ExampleEnum: Int {
    case undefined = 0
    case question = -1
    case answer = 42
}

@RawUserDefaultValue(rawType: Int.self)
var representableTest: ExampleEnum?
assert(representableTest == nil)
representableTest = .question
assert(representableTest == .question)

@RawUserDefaultValue(rawType: Int.self, defaultValue: ExampleEnum.undefined)
var representableDefaultTest: ExampleEnum
assert(representableDefaultTest == .undefined)
representableDefaultTest = .answer
assert(representableDefaultTest == .answer)

@UserDefault
class Defaults {
    @RawDefaultValue(rawType: Int.self, defaultValue: ExampleEnum.undefined)
    var rawRepresentableExampleValue: ExampleEnum
    @CodableDefaultValue(defaultValue: CodableStruct(value: 0))
    var codableExampleValue: CodableStruct
    @DefaultValue
    var defaultExampleValue: Int
}

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

UserDefaults.standard.clear()
testDefaults.clear()

print("success")
