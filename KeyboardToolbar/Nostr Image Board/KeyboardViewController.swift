//
//  KeyboardViewController.swift
//  Nostr Image Board
//
//  Created by Kamal Punia on 01/02/23.
//

import UIKit
import KeyboardKit

class KeyboardViewController: KeyboardInputViewController {
    
    var heightConstraint: NSLayoutConstraint?

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewWillSetupKeyboard() {
        super.viewWillSetupKeyboard()
        self.setup(with: NIBKeyboardView(textInputProxy: self.textDocumentProxy, heightDelegate: self, hasFullAccess: self.hasFullAccess, responder: self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var height = AppConstants.keyboardHeight + AppConstants.closedToolbarHeight + AppConstants.suggestionsToolbarHeight
        if !self.hasFullAccess {
            height = AppConstants.keyboardHeight + AppConstants.allowAccessHeight
        }
        self.updateHeightConstraint(height: height)
        self.autocompleteProvider = NIBAutocompleteProvider()
        keyboardActionHandler = NIBKeyboardActionHandler(inputViewController: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }

    private func updateHeightConstraint(height: CGFloat) {
        if let oldHeightConstraint = self.heightConstraint {
            self.view.removeConstraint(oldHeightConstraint)
            self.heightConstraint = nil
        }
        let heightConstraint = NSLayoutConstraint(item: self.view as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: height)
        self.view.addConstraint(heightConstraint)
        self.heightConstraint = heightConstraint
    }
}

// MARK: - CustomToolbarViewHeightDelegates
extension KeyboardViewController: CustomToolbarViewHeightDelegates {
    func toolbarView(_ view: CustomToolbarView, updateHeight: CGFloat) {
        self.updateHeightConstraint(height: updateHeight)
    }
}
