//
//  SpotifyService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation

class SpotifyService: NSObject, MusicService {
    
    private var sessionManager: SPTSessionManager?
    private var appRemote: SPTAppRemote?
    
    override init() {
        super.init()
        loadConfiguration { config in
            let configuration = SPTConfiguration(clientID: config.clientID, redirectURL: URL(string: config.redirectURL)!)
            self.sessionManager = SPTSessionManager(configuration: configuration, delegate: self)
            self.appRemote = SPTAppRemote(configuration: SpotifyApp.shared.configuration, logLevel: .debug)
        }
    }

    func play(song: SpotifyTrack, completion: @escaping (Error?) -> Void) {
        spotifyWebAPI.playTrack(uris: [song.spotifyURI]) { error in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
    func pause(completion: @escaping (Error?) -> Void) {
        spotifyWebAPI.pausePlayback { error in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
    func playingSongDidChange(completion: @escaping (Result<SpotifyTrack, Error>) -> Void) {
        
    }
    
    func searchSong(query: String, completion: @escaping (Result<[SpotifyTrack], Error>) -> Void) {
        APIClient<SpotifySearch>().request(endpoint: .search(query: "", type: "", limit: 0)) { (result: Result<SearchResponse, Error>) in
            <#code#>
        }
    }
    
    private func loadConfiguration(completion: @escaping (SpotifyConfig) -> Void) {
        FirestoreRepository<SpotifyConfig>(collectionPath: "spotify").get(id: "configuration") { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(config):
                completion(config)
            }
        }
    }
}

extension SpotifyService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        appRemote?.connectionParameters.accessToken
        SpotifyAPI.shared.setPlayerToken(session.accessToken)
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("SPTSession didRenew")
        SpotifyAppRemote.shared.setAccessToken(session.accessToken)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith error")
    }
}

extension SpotifyService: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("appRemote didFailConnectionAttemptWithError")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote didDisconnectWithError")
    }
}
