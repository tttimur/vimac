//
//  InputState.swift
//  VimacModern
//
//  State machine for key sequence matching with Trie
//  Pure Swift, no dependencies
//

import Foundation

/// State machine for tracking key sequence input
class InputState {
    enum State {
        case initialized
        case wordsAdded
        case advancable
        case deadend
        case matched
    }

    enum StateMachineError: Error {
        case invalidTransition
    }

    private var trie: Trie
    private var currentTrieNode: TrieNode
    private(set) var state: State

    init() {
        self.trie = Trie()
        self.currentTrieNode = trie.root
        self.state = .initialized
    }

    /// Add a word/sequence to the state machine
    func addWord(_ word: [Character]) throws -> Bool {
        guard state == .initialized || state == .wordsAdded else {
            throw StateMachineError.invalidTransition
        }

        // Prevent overlapping sequences
        if trie.isPrefix(word) || trie.doesPrefixWordExist(word) {
            return false
        }

        trie.addWord(word)
        state = .wordsAdded
        return true
    }

    /// Advance the state machine with a character
    func advance(_ c: Character) throws {
        guard state == .advancable || state == .wordsAdded else {
            throw StateMachineError.invalidTransition
        }

        guard let newNode = currentTrieNode.getChild(c) else {
            state = .deadend
            return
        }

        currentTrieNode = newNode

        if currentTrieNode.isTerminating() {
            assert(currentTrieNode.getChildren().isEmpty)
            state = .matched
            return
        }

        state = .advancable
    }

    /// Get the matched word (only valid when state == .matched)
    func matchedWord() throws -> [Character] {
        guard state == .matched else {
            throw StateMachineError.invalidTransition
        }
        return typedSequence()
    }

    /// Get the sequence typed so far
    private func typedSequence() -> [Character] {
        var sequence: [Character] = []
        var node: TrieNode? = currentTrieNode

        while let current = node {
            sequence.append(current.character)
            node = current.parent
        }

        // Remove root node's placeholder character
        if !sequence.isEmpty {
            sequence.removeLast()
        }

        return sequence.reversed()
    }

    /// Reset to initial state (ready for new input)
    func resetInput() {
        currentTrieNode = trie.root
        state = .wordsAdded
    }
}
