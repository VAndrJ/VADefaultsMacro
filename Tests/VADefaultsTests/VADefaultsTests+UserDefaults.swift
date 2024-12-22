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
    }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@ObservableUserDefaultsData(defaults: .testDefaults, keyPrefix: "com.vandrj.")
private class ObservableDefaults: @unchecked Sendable {
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
