//
//  MusicPlayerServiceableError.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/29/21.
//

import Foundation

enum MusicPlayerServiceableError: Error {
    case initiate(error: Error)
    case startPlayback(error: Error)
    case pausePlayback(error: Error)
    case rewindPlayback(error: Error)
    case currentUserProfile(error: Error)
    case cannotPlayOnDemand
}
