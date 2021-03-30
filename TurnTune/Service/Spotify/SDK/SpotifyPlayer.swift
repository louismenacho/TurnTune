//
//  SpotifyPlayer.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/3/21.
//

import Foundation

protocol SpotifyPlayerDelegate: class {
    func spotifyPlayer(spotifyPlayer: SpotifyPlayer, didChangeTrack track: SPTAppRemoteTrack)
    func spotifyPlayer(spotifyPlayer: SpotifyPlayer, didFinishTrack track: SPTAppRemoteTrack)
}

class SpotifyPlayer: NSObject {
    
    weak var delegate: SpotifyPlayerDelegate?
    
    private(set) static var shared = SpotifyPlayer()
    
    var player: SPTAppRemotePlayerAPI? { SpotifyAppRemote.shared.playerAPI }
    
    private var playerState: SPTAppRemotePlayerState?
    private var pendingPlaybackURI: String? = nil
    
    private override init() {}
    
    func configure() {
        if let player = player, player.delegate == nil {
            player.delegate = self
            player.subscribe()
            player.setRepeatMode(.off)
        } else {
            print("SpotifyPlayer configure failed")
        }
    }
    
    func isPendingPlayback() -> Bool {
        return pendingPlaybackURI != nil
    }
    
    func retryPlayback() {
//        isPendingPlayback() ? playTrack(uri: pendingPlaybackURI!) : ()
//        player?.resume()
    }
    
    func playTrack(uri: String, completion: (() -> Void)? = nil) {
//        pendingPlaybackURI = uri
        SpotifyAppRemote.shared.connectIfNeeded()
        player?.play(uri, asRadio: false) { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
//            self.pendingPlaybackURI = nil
            completion?()
        }
    }
    
    func pausePlayback( completion: (() -> Void)? = nil) {
        SpotifyAppRemote.shared.connectIfNeeded()
        player?.pause { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
            completion?()
        }
    }
}

extension SpotifyPlayer: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        // check how image shows up when reawaking
        // image shows selected song btu Spotify is playing Silent Track
        print(playerState.track.name)
        if self.playerState?.track.uri != playerState.track.uri {
            self.delegate?.spotifyPlayer(spotifyPlayer: self, didChangeTrack: playerState.track)
            print("spotifyPlayer didChangeTrack")
        }
        self.playerState = playerState
    }
}
