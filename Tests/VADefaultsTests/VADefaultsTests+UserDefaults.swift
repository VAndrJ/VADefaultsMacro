//
//  VADefaultsTests+UserDefaults.swift
//  VADefaults
//
//  Created by VAndrJ on 12/20/24.
//

#if canImport(VADefaultsMacros)
import Foundation
import VADefaults
import Testing
import XCTest
import Observation

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
class VAObservableDefaultsTests: XCTestCase {

    override func setUp() {
        UserDefaults.testDefaults.clear()
    }

    override func tearDown() {
        UserDefaults.testDefaults.clear()
    }

    func test_defaultsValues() {
        let defaults = ObservableDefaults()

        XCTAssertEqual(0, defaults.value)
        XCTAssertEqual(0, UserDefaults.testDefaults.integer(forKey: "com.vandrj.value"))
        verifyObservableChange(of: defaults.value) {
            defaults.value = 1
        }
        XCTAssertEqual(1, defaults.value)
        XCTAssertEqual(1, UserDefaults.testDefaults.integer(forKey: "com.vandrj.value"))

        XCTAssertEqual(.init(value: 0), defaults.codableValue)
        verifyObservableChange(of: defaults.codableValue) {
            defaults.codableValue = .init(value: 1)
        }
        XCTAssertEqual(.init(value: 1), defaults.codableValue)

        XCTAssertEqual(.foo, defaults.rawValue)
        verifyObservableChange(of: defaults.rawValue) {
            defaults.rawValue = .bar
        }
        XCTAssertEqual(.bar, defaults.rawValue)

        XCTAssertEqual(0, defaults.defaultsValue)
        XCTAssertEqual(0, UserDefaults.testDefaults.integer(forKey: "defaultsValue"))
        verifyObservableChange(of: defaults.defaultsValue) {
            defaults.defaultsValue = 1
        }
        XCTAssertEqual(1, defaults.defaultsValue)
        XCTAssertEqual(1, UserDefaults.testDefaults.integer(forKey: "defaultsValue"))

        XCTAssertEqual(.init(value: 0), defaults.defaultsCodableValue)
        verifyObservableChange(of: defaults.defaultsCodableValue) {
            defaults.defaultsCodableValue = .init(value: 1)
        }
        XCTAssertEqual(.init(value: 1), defaults.defaultsCodableValue)

        XCTAssertEqual(.foo, defaults.defaultsRawValue)
        verifyObservableChange(of: defaults.defaultsRawValue) {
            defaults.defaultsRawValue = .bar
        }
        XCTAssertEqual(.bar, defaults.defaultsRawValue)
    }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@ObservableUserDefaultsData(defaults: .testDefaults, keyPrefix: "com.vandrj.")
private class ObservableDefaults {
    @UserDefaultsValue(defaults: .testDefaults)
    var defaultsValue: Int
    @CodableUserDefaultsValue(defaultValue: TestCodableStruct(value: 0))
    var defaultsCodableValue: TestCodableStruct
    @RawUserDefaultsValue(rawType: Int.self, defaultValue: TestRawEnum.foo)
    var defaultsRawValue: TestRawEnum
    @DefaultsValue
    var value: Int
    @CodableDefaultsValue(defaultValue: TestCodableStruct(value: 0))
    var codableValue: TestCodableStruct
    @RawDefaultsValue(rawType: Int.self, defaultValue: TestRawEnum.foo)
    var rawValue: TestRawEnum
}

enum TestRawEnum: Int, RawRepresentable, Equatable {
    case foo = 0
    case bar = 1
}

struct TestCodableStruct: Codable, Equatable {
    let value: Int
}

extension XCTestCase {

    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    func verifyObservableChange<T>(
        of value: @autoclosure () -> T,
        change: () -> Void
    ) {
        let expectation = XCTestExpectation(description: "Observable should change")
        withObservationTracking {
            _ = value()
        } onChange: {
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }
        change()
        wait(for: [expectation], timeout: 1)
    }
}

extension UserDefaults {
    nonisolated(unsafe) static let testDefaults = UserDefaults(suiteName: "com.vandrj.test")!

    func clear() {
        dictionaryRepresentation().forEach {
            removeObject(forKey: $0.key)
        }
    }
}
#endif
