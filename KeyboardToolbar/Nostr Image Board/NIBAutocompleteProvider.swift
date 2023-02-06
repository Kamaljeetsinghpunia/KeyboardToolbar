//
//  NIBAutocompleteProvider.swift
//  Nostr Image Board
//
//  Created by Kamal Punia on 06/02/23.
//

import Foundation
import KeyboardKit
import UIKit

class NIBAutocompleteProvider: AutocompleteProvider {

    init() {
    }

    var locale: Locale = .current
    
    var canIgnoreWords: Bool { false }
    var canLearnWords: Bool { false }
    var ignoredWords: [String] = []
    var learnedWords: [String] = []
    
    func hasIgnoredWord(_ word: String) -> Bool { false }
    func hasLearnedWord(_ word: String) -> Bool { false }
    func ignoreWord(_ word: String) {}
    func learnWord(_ word: String) {}
    func removeIgnoredWord(_ word: String) {}
    func unlearnWord(_ word: String) {}
    
    func autocompleteSuggestions(for text: String, completion: AutocompleteCompletion) {
        guard text.count > 0 else { return completion(.success([])) }
        completion(.success(getSuggestions(for: text)))
    }
}

private extension NIBAutocompleteProvider {
    
    func typeCheck(text: String) -> [String] {
        let checker = UITextChecker()

        let checkRange = NSRange(location: 0, length: text.count)

        let misspelledRange = checker.rangeOfMisspelledWord(
            in: text,
            range: checkRange,
            startingAt: checkRange.location,
            wrap: false,
            language: "en_US")

        let arrGuessed = checker.guesses(forWordRange: misspelledRange, in: text, language: "en_US")
        return arrGuessed ?? []
    }
    
    func getSuggestions(for text: String) -> [AutocompleteSuggestion] {

        let array = self.typeCheck(text: text)
        let one = array.first ?? text
        let two = array.last ?? text
        
        return [
            StandardAutocompleteSuggestion(text: text, isUnknown: true),
            StandardAutocompleteSuggestion(text: one, isAutocomplete: true),
            StandardAutocompleteSuggestion(text: two)
        ]
    }
    
}
