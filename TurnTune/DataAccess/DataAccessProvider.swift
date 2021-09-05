//
//  DataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/28/21.
//

import Foundation

protocol DataAccessProviderDelegate: AnyObject {
    func dataAccessProvider(_ dataAccessProvider: DataAccessProvider, error: DataAccessError)
}

protocol DataAccessProvider {
    var delegate: DataAccessProviderDelegate? { get set }
}
