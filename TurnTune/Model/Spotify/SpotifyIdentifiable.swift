//
//  SpotifyIdentifiable.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation

protocol SpotifyIdentifiable {
    var spotifyID: String { get set }
    var spotifyURI: String { get set }
}
