//
//  AlphabetHints.swift
//  VimacModern
//
//  Generates hint strings for elements
//  Algorithm from Vimium: https://github.com/philc/vimium
//  Pure Swift, no dependencies
//

import Foundation

/// Generates unique hint strings from a character alphabet
enum AlphabetHints {
    /// Generate hint strings for a given number of links
    /// - Parameters:
    ///   - count: Number of hint strings to generate
    ///   - characters: String of allowed hint characters (e.g., "sadfjklewcmpgh")
    /// - Returns: Array of unique hint strings
    static func generate(count: Int, using characters: String) -> [String] {
        guard count > 0 else { return [] }

        var hints = [""]
        var offset = 0

        // Build hints until we have enough
        while hints.count - offset < count || hints.count == 1 {
            let hint = hints[offset]
            offset += 1

            for char in characters {
                hints.append(String(char) + hint)
            }
        }

        // Take the required number of hints, sort, reverse, and uppercase
        return Array(hints[offset..<offset + count])
            .sorted()
            .map { String($0.reversed()).uppercased() }
    }
}
