//
//  Song.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/19/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Song: FireStoreObject {
    @DocumentID var id: String?
    var name: String
    var artistName: String
    var artworkURL: String
    var durationInMillis: Int
    var didPlay: Bool = false
    var orderGroup: Int?
    var addedBy: Member?
    @ServerTimestamp var dateAdded: Timestamp?
    
    // Spotify Identifiers
    var spotifyURI: String?
    
    init(spotifyTrack: SearchResponse.TrackItem) {
        spotifyURI = spotifyTrack.uri
        name = spotifyTrack.name
        artistName = spotifyTrack.artists.map { $0.name }.joined(separator: ", ")
        artworkURL = spotifyTrack.album.images[0].url
        durationInMillis = spotifyTrack.durationMS
    }
    
    init(spotifyTrack: SPTAppRemoteTrack) {
        spotifyURI = spotifyTrack.uri
        name = spotifyTrack.name
        artistName = spotifyTrack.artist.name
        artworkURL = spotifyTrack.imageIdentifier
        durationInMillis = Int(spotifyTrack.duration)
    }
}
