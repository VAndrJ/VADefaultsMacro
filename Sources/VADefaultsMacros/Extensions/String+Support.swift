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
            "UserDefaults\(self)"
        } else {
            self
        }
    }
    var asEncoder: String {
        if self == .initializer {
            .encoder
        } else if starts(with: ".") {
            "JSONEncoder\(self)"
        } else {
            self
        }
    }
    var asDecoder: String {
        if self == .initializer {
            .decoder
        } else if starts(with: ".") {
            "JSONDecoder\(self)"
        } else {
            self
        }
    }
}
