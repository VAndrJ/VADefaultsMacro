import VADefaults
import Foundation

UserDefaults.standard.dictionaryRepresentation().forEach {
    UserDefaults.standard.removeObject(forKey: $0.key)
}

@UserDefaultValue()
var boolTest: Bool
assert(boolTest == false)
boolTest = true
assert(boolTest == true)

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

@UserDefaultValue()
var intTest: Int
assert(intTest == 0)
intTest = 42
assert(intTest == 42)

@UserDefaultValue(defaultValue: 1)
var intDefaultTest: Int
assert(intDefaultTest == 1)
intDefaultTest = 42
assert(intDefaultTest == 42)

@UserDefaultValue()
var floatTest: Float
assert(floatTest == 0)
floatTest = 42
assert(floatTest == 42)

@UserDefaultValue()
var doubleTest: Double
assert(doubleTest == 0)
doubleTest = 42
assert(doubleTest == 42)

@UserDefaultValue(defaultValue: "a")
var stringTest: String
assert(stringTest == "a")
stringTest = "42"
assert(stringTest == "42")

@UserDefaultValue(defaultValue: "a")
var nsStringTest: NSString
assert(nsStringTest == "a")
nsStringTest = "42"
assert(nsStringTest == "42")

@UserDefaultValue(defaultValue: 4)
var nsNumberTest: NSNumber
assert(nsNumberTest == 4)
nsNumberTest = 42
assert(nsNumberTest == 42)

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

@UserDefaultValue()
var arrOptionalTest: [Int]?
assert(arrOptionalTest == nil)
arrOptionalTest = [42]
assert(arrOptionalTest == [42])

@UserDefaultValue(defaultValue: ["4": 4])
var dictTest: [String: Int]
assert(dictTest == ["4": 4])
dictTest = ["4": 42]
assert(dictTest == ["4": 42])

@UserDefaultValue()
var dictOptionalTest: [String: Int]?
assert(dictOptionalTest == nil)
dictOptionalTest = ["4": 42]
assert(dictOptionalTest == ["4": 42])

print("success")
