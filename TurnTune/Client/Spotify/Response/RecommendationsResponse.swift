//
//  RecommendationsResponse.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/7/21.
//

import Foundation

//// MARK: - RecommendationsResponse
//struct RecommendationsResponse: Codable {
//    var tracks: [Track]
//    var seeds: [Seed]
//
//    enum CodingKeys: String, CodingKey {
//        case tracks = "tracks"
//        case seeds = "seeds"
//    }
//    
//    // MARK: - Seed
//    struct Seed: Codable {
//        var initialPoolSize: Int?
//        var afterFilteringSize: Int?
//        var afterRelinkingSize: Int?
//        var id: String?
//        var type: String?
//        var href: String?
//
//        enum CodingKeys: String, CodingKey {
//            case initialPoolSize = "initialPoolSize"
//            case afterFilteringSize = "afterFilteringSize"
//            case afterRelinkingSize = "afterRelinkingSize"
//            case id = "id"
//            case type = "type"
//            case href = "href"
//        }
//    }
//
//    // MARK: - Track
//    struct Track: Codable {
//        var album: Album
//        var artists: [Artist]
//        var discNumber: Int?
//        var durationMS: Int
//        var explicit: Bool?
//        var externalIDS: ExternalIDS?
//        var externalUrls: ExternalUrls?
//        var href: String?
//        var id: String?
//        var isLocal: Bool?
//        var isPlayable: Bool?
//        var name: String
//        var popularity: Int?
//        var previewURL: String?
//        var trackNumber: Int?
//        var type: String?
//        var uri: String?
//
//        enum CodingKeys: String, CodingKey {
//            case album = "album"
//            case artists = "artists"
//            case discNumber = "disc_number"
//            case durationMS = "duration_ms"
//            case explicit = "explicit"
//            case externalIDS = "external_ids"
//            case externalUrls = "external_urls"
//            case href = "href"
//            case id = "id"
//            case isLocal = "is_local"
//            case isPlayable = "is_playable"
//            case name = "name"
//            case popularity = "popularity"
//            case previewURL = "preview_url"
//            case trackNumber = "track_number"
//            case type = "type"
//            case uri = "uri"
//        }
//    }
//
//    // MARK: - Album
//    struct Album: Codable {
//        var albumType: String?
//        var artists: [Artist]?
//        var externalUrls: ExternalUrls?
//        var href: String?
//        var id: String?
//        var images: [Image]
//        var name: String?
//        var releaseDate: String?
//        var releaseDatePrecision: String?
//        var totalTracks: Int?
//        var type: String?
//        var uri: String?
//
//        enum CodingKeys: String, CodingKey {
//            case albumType = "album_type"
//            case artists = "artists"
//            case externalUrls = "external_urls"
//            case href = "href"
//            case id = "id"
//            case images = "images"
//            case name = "name"
//            case releaseDate = "release_date"
//            case releaseDatePrecision = "release_date_precision"
//            case totalTracks = "total_tracks"
//            case type = "type"
//            case uri = "uri"
//        }
//    }
//
//    // MARK: - Artist
//    struct Artist: Codable {
//        var externalUrls: ExternalUrls?
//        var href: String?
//        var id: String?
//        var name: String
//        var type: String?
//        var uri: String?
//
//        enum CodingKeys: String, CodingKey {
//            case externalUrls = "external_urls"
//            case href = "href"
//            case id = "id"
//            case name = "name"
//            case type = "type"
//            case uri = "uri"
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
//        var height: Int?
//        var url: String
//        var width: Int?
//
//        enum CodingKeys: String, CodingKey {
//            case height = "height"
//            case url = "url"
//            case width = "width"
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
//}
