//
//  Trie.swift
//  VimacModern
//
//  Trie data structure for key sequence matching
//  Pure Swift, no dependencies
//

import Foundation

/// A node in the Trie
class TrieNode {
    private var children: [Character: TrieNode] = [:]
    private var terminates: Bool
    let character: Character
    let parent: TrieNode?

    init(character: Character, terminates: Bool, parent: TrieNode?) {
        self.character = character
        self.terminates = terminates
        self.parent = parent
    }

    func setTerminates(_ value: Bool) {
        self.terminates = value
    }

    func addWord(_ word: [Character]) {
        guard !word.isEmpty else { return }

        let firstChar = word.first!
        let child = children[firstChar] ?? {
            let newChild = TrieNode(character: firstChar, terminates: false, parent: self)
            children[firstChar] = newChild
            return newChild
        }()

        if word.count > 1 {
            child.addWord(Array(word.dropFirst()))
        } else {
            child.setTerminates(true)
        }
    }

    func getChildren() -> [TrieNode] {
        return Array(children.values)
    }

    func getChild(_ c: Character) -> TrieNode? {
        return children[c]
    }

    func isTerminating() -> Bool {
        return terminates
    }
}

/// Trie (prefix tree) for efficient sequence matching
class Trie {
    let root: TrieNode

    init() {
        // Root node with placeholder character
        root = TrieNode(character: "\0", terminates: false, parent: nil)
    }

    /// Add a word to the trie
    func addWord(_ word: [Character]) {
        root.addWord(word)
    }

    /// Check if a word is a prefix of any word in the trie
    func isPrefix(_ word: [Character]) -> Bool {
        var node: TrieNode? = root
        for c in word {
            node = node?.getChild(c)
            if node == nil {
                return false
            }
        }
        return true
    }

    /// Check if the exact word exists in the trie
    func contains(_ word: [Character]) -> Bool {
        var node: TrieNode? = root
        for c in word {
            node = node?.getChild(c)
            if node == nil {
                return false
            }
        }
        return node?.isTerminating() ?? false
    }

    /// Check if any prefix of the word is a complete word in the trie
    func doesPrefixWordExist(_ word: [Character]) -> Bool {
        var node: TrieNode? = root
        for c in word {
            guard let nextNode = node?.getChild(c) else {
                return node?.isTerminating() ?? false
            }
            node = nextNode
        }
        return node?.isTerminating() ?? false
    }
}
