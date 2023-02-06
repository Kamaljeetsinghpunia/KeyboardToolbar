//
//  NIBKeyboardActionHandler.swift
//  Nostr Image Board
//
//  Created by Kamal Punia on 06/02/23.
//

import KeyboardKit

class NIBKeyboardActionHandler: StandardKeyboardActionHandler {
    override func shouldTriggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) -> Bool {
        return false
    }
}
