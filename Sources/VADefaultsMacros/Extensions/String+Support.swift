//
//  String+Support.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import Foundation

extension String {
    static let encoder = "JSONEncoder()"
    static let initializer = ".init()"
    static let decoder = "JSONDecoder()"
    static let standardDefaults = "UserDefaults.standard"

    var quoted: String { "\"\(self)\"" }
    var asDefaults: String {
        if starts(with: ".") {
            return "UserDefaults\(self)"
        } else {
            return self
        }
    }
    var asEncoder: String {
        if self == .initializer {
            return .encoder
        } else if starts(with: ".") {
            return "JSONEncoder\(self)"
        } else {
            return self
        }
    }
    var asDecoder: String {
        if self == .initializer {
            return .decoder
        } else if starts(with: ".") {
            return "JSONDecoder\(self)"
        } else {
            return self
        }
    }
}

extension String? {
    var isEmpty: Bool { self?.isEmpty ?? true }
    var isNotEmpty: Bool { !isEmpty }
}
