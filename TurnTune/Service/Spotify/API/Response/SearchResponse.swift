//
//  SearchResponse.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/29/21.
//

import Foundation

// MARK: - SearchResponse
struct SearchResponse: Codable {
    var tracks: Tracks
}

// MARK: - Tracks
struct Tracks: Codable {
    var href: String?
    var items: [TrackItem?]
    var limit: Int?
    var next: String?
    var offset: Int?
    var previous: JSONNull?
    var total: Int?
}

// MARK: - TrackItem
struct TrackItem: Codable {
    var album: Album
    var artists: [Artist]
    var availableMarkets: [String]?
    var discNumber, durationMS: Int
    var explicit: Bool?
    var externalIDS: ExternalIDS?
    var externalUrls: ExternalUrls?
    var href: String?
    var id: String
    var isLocal: Bool?
    var name: String
    var popularity: Int?
    var previewURL: String?
    var trackNumber: Int?
    var type: String?
    var uri: String?

    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalIDS = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case name, popularity
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case type, uri
    }
}

// MARK: - Album
struct Album: Codable {
    var albumType: String?
    var artists: [Artist]?
    var availableMarkets: [String]?
    var externalUrls: ExternalUrls?
    var href: String?
    var id: String?
    var images: [Image]
    var name, releaseDate: String?
    var releaseDatePrecision: String?
    var totalTracks: Int?
    var type: String?
    var uri: String?

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
        case type, uri
    }
}

// MARK: - Artist
struct Artist: Codable {
    var externalUrls: ExternalUrls?
    var href: String?
    var id, name: String
    var type: String?
    var uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

// MARK: - ExternalUrls
struct ExternalUrls: Codable {
    var spotify: String?
}

// MARK: - Image
struct Image: Codable {
    var height: Int?
    var url: String
    var width: Int?
}

// MARK: - ExternalIDS
struct ExternalIDS: Codable {
    var isrc: String?
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}
