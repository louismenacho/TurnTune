//
//  Song.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/19/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct Song {
    
    typealias MilliSeconds = Int
    
    var name: String                
    var artist: String
    var album: String
    var artworkURL: String
    var duration: MilliSeconds
    
    // MARK: - Queueing Protocol
    var orderGroup: Int = 0
    var didPlay: Bool = false
    var addedBy: Member = Member()
    
    // MARK: - FirestoreDocument Protocol
    @DocumentID var documentID: String?
    @ServerTimestamp var dateAdded: Timestamp?
    
    // MARK: - SpotifyIdentifiable Protocol
    var spotifyID: String = ""
    var spotifyURI: String = ""
    
    init() {
        name = "No song playing"
        artist = ""
        album = ""
        artworkURL = ""
        duration = 0
    }
}

extension Song: Queueing {

}

extension Song: FirestoreDocument {
    
}

extension Song: SpotifyIdentifiable {
    
    init(from spotifyTrack: Track) {
        spotifyURI = spotifyTrack.uri
        spotifyID = spotifyTrack.id
        name = spotifyTrack.name
        artist = spotifyTrack.artists.map { $0.name }.joined(separator: ", ")
        album = spotifyTrack.album.name
        artworkURL = spotifyTrack.album.images[0].url
        duration = spotifyTrack.durationMS
    }
    
    init(from spotifyTrack: SPTAppRemoteTrack) {
        spotifyURI = spotifyTrack.uri
        spotifyID = ""
        name = spotifyTrack.name
        artist = spotifyTrack.artist.name
        album = spotifyTrack.album.name
        artworkURL = "https://i.scdn.co/image/"+spotifyTrack.imageIdentifier.dropFirst(14)
        duration = Int(spotifyTrack.duration)
    }

}
