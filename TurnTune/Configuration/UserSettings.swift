//
//  UserSettings.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/14/21.
//

import Foundation

class UserSettings {
    
    private(set) static var shared = UserSettings()
    
    private init() {}
    
    @UserDefaultsSetting(key: "Appearance")
    var appearance = UIUserInterfaceStyle.unspecified.rawValue
    
}
