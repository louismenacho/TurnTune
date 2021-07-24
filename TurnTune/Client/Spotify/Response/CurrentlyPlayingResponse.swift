//
//  CurrentlyPlayingResponse.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/31/21.
//

import Foundation

//// MARK: - CurrentlyPlayingResponse
//struct CurrentlyPlayingResponse: Codable {
//    var isPlaying: Bool?
//    var currentlyPlayingType: String?
//    var context: JSONNull?
//    var progressMS: Int?
//    var timestamp: Int?
//    var item: Item?
//    var actions: Actions?
//
//    enum CodingKeys: String, CodingKey {
//        case isPlaying = "is_playing"
//        case currentlyPlayingType = "currently_playing_type"
//        case context = "context"
//        case progressMS = "progress_ms"
//        case timestamp = "timestamp"
//        case item = "item"
//        case actions = "actions"
//    }
//    
//    // MARK: - Actions
//    struct Actions: Codable {
//        var disallows: Disallows?
//
//        enum CodingKeys: String, CodingKey {
//            case disallows = "disallows"
//        }
//    }
//
//    // MARK: - Disallows
//    struct Disallows: Codable {
//        var togglingRepeatTrack: Bool?
//        var skippingPrev: Bool?
//        var pausing: Bool?
//        var togglingShuffle: Bool?
//        var togglingRepeatContext: Bool?
//
//        enum CodingKeys: String, CodingKey {
//            case togglingRepeatTrack = "toggling_repeat_track"
//            case skippingPrev = "skipping_prev"
//            case pausing = "pausing"
//            case togglingShuffle = "toggling_shuffle"
//            case togglingRepeatContext = "toggling_repeat_context"
//        }
//    }
//
//    // MARK: - Item
//    struct Item: Codable {
//        var id: String?
//        var name: String?
//        var album: Album?
//        var discNumber: Int?
//        var trackNumber: Int?
//        var artists: [Artist]?
//        var href: String?
//        var isLocal: Bool?
//        var popularity: Int?
//        var availableMarkets: [String]?
//        var type: String?
//        var uri: String?
//        var explicit: Bool?
//        var previewURL: String?
//        var durationMS: Int?
//        var externalUrls: ExternalUrls?
//        var externalIDS: ExternalIDS?
//
//        enum CodingKeys: String, CodingKey {
//            case id = "id"
//            case name = "name"
//            case album = "album"
//            case discNumber = "disc_number"
//            case trackNumber = "track_number"
//            case artists = "artists"
//            case href = "href"
//            case isLocal = "is_local"
//            case popularity = "popularity"
//            case availableMarkets = "available_markets"
//            case type = "type"
//            case uri = "uri"
//            case explicit = "explicit"
//            case previewURL = "preview_url"
//            case durationMS = "duration_ms"
//            case externalUrls = "external_urls"
//            case externalIDS = "external_ids"
//        }
//    }
//
//    // MARK: - Album
//    struct Album: Codable {
//        var id: String?
//        var totalTracks: Int?
//        var uri: String?
//        var albumType: String?
//        var artists: [Artist]?
//        var href: String?
//        var availableMarkets: [String]?
//        var releaseDatePrecision: String?
//        var type: String?
//        var images: [Image]?
//        var releaseDate: String?
//        var externalUrls: ExternalUrls?
//        var name: String?
//
//        enum CodingKeys: String, CodingKey {
//            case id = "id"
//            case totalTracks = "total_tracks"
//            case uri = "uri"
//            case albumType = "album_type"
//            case artists = "artists"
//            case href = "href"
//            case availableMarkets = "available_markets"
//            case releaseDatePrecision = "release_date_precision"
//            case type = "type"
//            case images = "images"
//            case releaseDate = "release_date"
//            case externalUrls = "external_urls"
//            case name = "name"
//        }
//    }
//
//    // MARK: - Artist
//    struct Artist: Codable {
//        var uri: String?
//        var id: String?
//        var externalUrls: ExternalUrls?
//        var href: String?
//        var name: String?
//        var type: String?
//
//        enum CodingKeys: String, CodingKey {
//            case uri = "uri"
//            case id = "id"
//            case externalUrls = "external_urls"
//            case href = "href"
//            case name = "name"
//            case type = "type"
//        }
//    }
//
//    // MARK: - ExternalUrls
//    struct ExternalUrls: Codable {
//        var spotify: String?
//
//        enum CodingKeys: String, CodingKey {
//            case spotify = "spotify"
//        }
//    }
//
//    // MARK: - Image
//    struct Image: Codable {
//        var url: String?
//        var width: Int?
//        var height: Int?
//
//        enum CodingKeys: String, CodingKey {
//            case url = "url"
//            case width = "width"
//            case height = "height"
//        }
//    }
//
//    // MARK: - ExternalIDS
//    struct ExternalIDS: Codable {
//        var isrc: String?
//
//        enum CodingKeys: String, CodingKey {
//            case isrc = "isrc"
//        }
//    }
//
//    // MARK: - Encode/decode helpers
//
//    class JSONNull: Codable, Hashable {
//
//        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//            return true
//        }
//
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(0)
//        }
//
//        public init() {}
//
//        public required init(from decoder: Decoder) throws {
//            let container = try decoder.singleValueContainer()
//            if !container.decodeNil() {
//                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//            }
//        }
//
//        public func encode(to encoder: Encoder) throws {
//            var container = encoder.singleValueContainer()
//            try container.encodeNil()
//        }
//    }
//}
