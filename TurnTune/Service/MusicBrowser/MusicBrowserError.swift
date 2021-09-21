//
//  MusicBrowserError.swift
//  TurnTune
//
//  Created by Louis Menacho on 9/5/21.
//

import Foundation

enum MusicBrowserError: Error {
    case generateToken(error: HTTPError)
    case searchSong(error: HTTPError)
    case getSongRecommendations(error: HTTPError)
}
