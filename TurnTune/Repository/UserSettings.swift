//
//  UserDefaultsRepository.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/14/21.
//

import Foundation

class UserDefaultsRepository {
    
    var userDefaults: UserDefaults = .standard

    @UserDefaultsProperty(key: "Appearance")
    var appearance = UIUserInterfaceStyle.unspecified.rawValue
    
    func listKeys() -> [String] {
        userDefaults.dictionaryRepresentation().keys.map { $0 }
    }
}
