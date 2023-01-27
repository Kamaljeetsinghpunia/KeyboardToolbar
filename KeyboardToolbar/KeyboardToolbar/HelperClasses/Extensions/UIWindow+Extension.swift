//
//  UIWindow+Extension.swift
//  ARHuman
//
//  Created by Kamal Punia on 01/08/22.
//

import UIKit

extension UIWindow {
    
    static var keyWindow: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }        
    }
    
    static var currentOrientation: UIInterfaceOrientation {    
        let orientation = self.keyWindow?.windowScene?.interfaceOrientation ?? .portraitUpsideDown
        return orientation
    }
}
