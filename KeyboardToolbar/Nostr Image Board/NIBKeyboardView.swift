//
//  NIBKeyboardView.swift
//  Nostr Image Board
//
//  Created by Kamal Punia on 01/02/23.
//

import SwiftUI
import KeyboardKit

struct NIBKeyboardView: View {
    
    @EnvironmentObject
    private var keyboardContext: KeyboardContext
    var textInputProxy: UITextDocumentProxy
    var heightDelegate: CustomToolbarViewHeightDelegates
    
    var body: some View {
        VStack(spacing: 0) {
            NibKeyboard(textInputProxy: self.textInputProxy, heightDelegate: self.heightDelegate)
            SystemKeyboard()
        }
    }
}

struct NibKeyboard: UIViewRepresentable {
    
    var textInputProxy: UITextDocumentProxy
    var heightDelegate: CustomToolbarViewHeightDelegates

    func makeUIView(context: Context) -> CustomToolbarView {
        let customToolbar: CustomToolbarView = .loadFromNib()
        customToolbar.textInputProxy = self.textInputProxy
        customToolbar.heightDelegate = self.heightDelegate
        customToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
        customToolbar.backgroundColor = .systemBackground
        return customToolbar
    }

    func updateUIView(_ uiView: CustomToolbarView, context: Context) {
    }
}
