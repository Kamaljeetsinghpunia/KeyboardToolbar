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
    var hasFullAccess: Bool
    var responder: UIViewController?
    
    var body: some View {
        VStack(spacing: 0) {
            if !self.hasFullAccess {
                VStack {
                    Button("Enable \"Full Access\" to send Images") {
                        self.openSettings()
                    }.foregroundColor(Color.white)
                }
                .padding(.top, 15)
                .padding(.bottom, 10)
            }else {
                NibKeyboard(textInputProxy: self.textInputProxy, heightDelegate: self.heightDelegate)
            }
            SystemKeyboard()
        }
    }
    
    private func openSettings() {
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        let selectorOpenURL = NSSelectorFromString("openURL:")
        var responder: UIResponder? = self.responder
        while let r = responder {
            if r.canPerformAction(selectorOpenURL, withSender: nil) {
                 r.perform(selectorOpenURL, with: url, afterDelay: 0.01)
                 break
            }
            responder = r.next
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
