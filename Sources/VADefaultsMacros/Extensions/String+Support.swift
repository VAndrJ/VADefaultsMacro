//
//  String+Support.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import Foundation

extension String {
    static let standardDefaults = "UserDefaults.standard"

    var quoted: String { "\"\(self)\"" }
    var asDefaults: String {
        if starts(with: ".") {
            return "UserDefaults\(self)"
        } else {
            return self
        }
    }
}

extension String? {
    var isEmpty: Bool { self?.isEmpty ?? true }
    var isNotEmpty: Bool { !isEmpty }
}
