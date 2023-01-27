//
//  LocalizedStringEnum.swift
//

import Foundation

enum LocalizedStringEnum:String {
    case appName
    case networkNotReachable
    case somethingWentWrong
    
    //MARK:- Alerts
    case ok
    case yes
    case no
    case cancel
    
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: self.rawValue)
    }
}

