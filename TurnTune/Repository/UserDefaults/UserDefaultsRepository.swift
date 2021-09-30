//
//  UserDefaultsRepository.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/14/21.
//

import Foundation

class UserDefaultsRepository {
    
    var userDefaults: UserDefaults = .standard
    
    @UserDefaultsProperty(key: "User ID")
    var userID = ""
    
    @UserDefaultsProperty(key: "Display Name")
    var displayName = ""
    
    @UserDefaultsProperty(key: "Room ID")
    var roomID = ""
    
    @UserDefaultsProperty(key: "isHost")
    var isHost = false
    
    @UserDefaultsProperty(key: "Appearance")
    var appearance = UIUserInterfaceStyle.unspecified.rawValue
}
