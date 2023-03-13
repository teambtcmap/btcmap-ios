//
//  API.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation
import os
import CoreLocation

// API Documentation: https://github.com/teambtcmap/btcmap-api/wiki
class API {
    let logger = Logger(subsystem: "org.btcmap.app", category: "API")
    let rest: REST = .init(base: URL(string: "https://api.btcmap.org/")!)
    var encoder: JSONEncoder { rest.encoder }
    var decoder: JSONDecoder { rest.decoder }
    
    typealias Completion<Response> = (Result<Response, Error>) -> Void
         
    // MARK: - Element
    struct Element: Identifiable, Equatable, Codable {
        struct OsmJson: Identifiable, Equatable, Codable {
            struct Point: Equatable, Codable {
                let lat: Double
                let lon: Double
            }
            
            typealias Geometry = [Point]
            
            struct Bounds: Equatable, Codable {
                let maxlat: Double
                let maxlon: Double
                let minlat: Double
                let minlon: Double
            }
            
            struct Member: Equatable, Codable {
                let ref: Int64
                let type: OsmType
                let role: String
                let geometry: Geometry?
            }
            
            let id: Int64
            let type: OsmType
            let uid: Int?
            let user: String?
            let timestamp: Date?
            let version: Int?
            let changeset: Int64?
            let tags: [String: String]?
            let lat: Double?
            let lon: Double?
            let geometry: Geometry?
            let bounds: Bounds?
            let nodes: [Int64]?
            let members: [Member]?
            
            // MARK: Tags
            var name: String { tags?["name"] ?? "" }
            var address: String {
                var address = ""
                
                if let houseNumber = tags?["addr:housenumber"] {
                    address += houseNumber
                }
                if let street = tags?["addr:street"] {
                    if !address.isEmpty { address += " " }
                    address += street
                }
                if let city = tags?["addr:city"] {
                    if !address.isEmpty { address += ", " }
                    address += city
                }
                if let state = tags?["addr:state"] {
                    if !address.isEmpty { address += ", " }
                    address += state
                }
                if let postcode = tags?["addr:postcode"] {
                    if !address.isEmpty { address += ", " }
                    address += postcode
                }
                
                return address
            }
            
            var websiteUrl: String? {
                return tags?["website"] ?? tags?["contact:website"]
            }
            
            var websiteTitle: String? {
                guard let website = websiteUrl else { return nil }
                return website
                    .replacingOccurrences(of: "https://www.", with: "")
                    .replacingOccurrences(of: "http://www.", with: "")
                    .replacingOccurrences(of: "https://", with: "")
                    .replacingOccurrences(of: "http://", with: "")
                    .trimmingCharacters(in: ["/"])
            }
        }
        
        enum OsmType: String, Codable {
            case node
            case way
            case relation
        }
        
        let id: String
        let osmJson: OsmJson
        let createdAt: String
        let updatedAt: String
        let deletedAt: String
        let tags: [String: String]?
        
        // MARK: Coords
        var coord: CLLocationCoordinate2D? {
            var lat: Double
            var lon: Double
            
            if osmJson.type == .node {
                guard let _lat = osmJson.lat,
                    let _lon = osmJson.lon else { return nil }
                lat = _lat
                lon = _lon
            } else {
                guard let bounds = osmJson.bounds else { return nil }
                lat = (bounds.minlat + bounds.maxlat) / 2.0
                lon = (bounds.minlon + bounds.maxlon) / 2.0
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        // MARK: Mocks
        static var mock: Element? {
            guard let fileURL = Bundle.main.url(forResource: "mock_element", withExtension: "json") else {
                assertionFailure(); return nil }
            do {
                let data = try Data(contentsOf: fileURL)
                return try API().decoder.decode(API.Element.self, from: data)
            } catch {
                return nil
            }
        }
    }
 
    // MARK: - Area
    struct Area: Codable, Hashable, Equatable {
        let id: String
        let tags: Tags
        let createdAt: String
        let updatedAt: String
        let deletedAt: String
        
        struct Tags: Codable {
            let boxEast: Double?
            let boxNorth: Double?
            let boxSouth: Double?
            let boxWest: Double?
            let discord: String?
            let twitter: String?
            let secondTwitter: String?
            let meetup: String?
            let eventbrite: String?
            let telegram: String?
            let website: String?
            let youtube: String?
            let github: String?
            let reddit: String?
            let iconSquare: String?
            let name: String?
            let type: String?
            
            private enum CodingKeys: String, CodingKey {
                case boxEast = "box:east"
                case boxNorth = "box:north"
                case boxSouth = "box:south"
                case boxWest = "box:west"
                case discord = "contact:discord"
                case twitter = "contact:twitter"
                case secondTwitter = "contact:second_twitter"
                case meetup = "contact:meetup"
                case eventbrite = "contact:eventbrite"
                case telegram = "contact:telegram"
                case website = "contact:website"
                case youtube = "contact:youtube"
                case github = "contact:github"
                case reddit = "contact:reddit"
                case iconSquare = "icon:square"
                case name
                case type
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                // NOTE: This complexity is because sometimes boxEast, boxNorth, etc were returning as Strings in the Json
                boxEast = try? (try? container.decode(Double.self, forKey: .boxEast)) ?? Double(try container.decode(String.self, forKey: .boxEast))
                boxNorth = try? (try? container.decode(Double.self, forKey: .boxNorth)) ?? Double(try container.decode(String.self, forKey: .boxNorth))
                boxSouth = try? (try? container.decode(Double.self, forKey: .boxSouth)) ?? Double(try container.decode(String.self, forKey: .boxSouth))
                boxWest = try? (try? container.decode(Double.self, forKey: .boxWest)) ?? Double(try container.decode(String.self, forKey: .boxWest))
                discord = try container.decodeIfPresent(String.self, forKey: .discord)
                twitter = try container.decodeIfPresent(String.self, forKey: .twitter)
                meetup = try container.decodeIfPresent(String.self, forKey: .meetup)
                eventbrite = try container.decodeIfPresent(String.self, forKey: .eventbrite)
                secondTwitter = try container.decodeIfPresent(String.self, forKey: .secondTwitter)
                telegram = try container.decodeIfPresent(String.self, forKey: .telegram)
                website = try container.decodeIfPresent(String.self, forKey: .website)
                youtube = try container.decodeIfPresent(String.self, forKey: .youtube)
                github = try container.decodeIfPresent(String.self, forKey: .github)
                reddit = try container.decodeIfPresent(String.self, forKey: .reddit)
                iconSquare = try container.decodeIfPresent(String.self, forKey: .iconSquare)
                name = try container.decodeIfPresent(String.self, forKey: .name)
                type = try container.decodeIfPresent(String.self, forKey: .type)
            }
        }
        
        // MARK: Getters
        var iconUrl: URL? { URL(string: tags.iconSquare ?? "") }
        var name: String? { tags.name }
        var type: String? { tags.type }
        var bounds: Bounds? {
            guard let boxEast = tags.boxEast, let boxWest = tags.boxWest, let boxSouth = tags.boxSouth, let boxNorth = tags.boxNorth else { return nil }
            return Bounds(maxlat: max(boxSouth, boxNorth),
                          maxlon: max(boxEast, boxWest),
                          minlat: min(boxSouth, boxNorth),
                          minlon: min(boxEast, boxWest))
        }

        // MARK: Coords
        var coord: CLLocationCoordinate2D? {
            guard let e = tags.boxEast, let w = tags.boxWest, let s = tags.boxSouth, let n = tags.boxNorth else { return nil }
            let lat = (s + n) / 2.0
            let lon = (e + w) / 2.0
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        // MARK: Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Area, rhs: Area) -> Bool {
            return lhs.id == rhs.id
        }
        
        // MARK: Mock
        static var mock: Area? {
            guard let fileURL = Bundle.main.url(forResource: "mock_area", withExtension: "json") else {
                assertionFailure(); return nil }
            do {
                let data = try Data(contentsOf: fileURL)
                return try API().decoder.decode(API.Area.self, from: data)
            } catch {
                return nil
            }
        }
    }
    
    //MARK: - Event
    struct Event: Identifiable, Equatable, Codable {
        let id: Int
        // TODO: Type
        let elementId: String
        let userId: Int
        let createdAt: String
        let updatedAt: String
        let deletedAt: String
        
        static var mock: Event? {
            guard let fileURL = Bundle.main.url(forResource: "mock_event", withExtension: "json") else {
                assertionFailure(); return nil }
            do {
                let data = try Data(contentsOf: fileURL)
                return try API().decoder.decode(Event.self, from: data)
            } catch {
                return nil
            }
        }
    }
    
    //MARK: - User
    struct User: Identifiable, Equatable, Codable {
        let id: String
        let createdAt: String
        let updatedAt: String
        let deletedAt: String
        let osmJson: OsmJson
        
        struct OsmJson: Identifiable, Equatable, Codable {
            let id: Int64
            let accountCreated: Date
            let displayName: String
            let description: String
            let blocks: Blocks
            let changesets: Changesets
            let traces: Traces
            let contributorTerms: ContributorTerms
            let img: Img
            let roles: [String]?
            
            struct Blocks: Equatable, Codable {
                let received: Received
                
                struct Received: Equatable, Codable  {
                    let active: Int
                    let count: Int
                }
            }
            
            struct Changesets: Equatable, Codable {
                let count: Int
            }
            
            struct Traces: Equatable, Codable {
                let count: Int
            }
            
            struct ContributorTerms: Equatable, Codable {
                let agreed: Bool
            }
        }
        
        struct Img: Equatable, Codable {
            let href: String
        }
        
        static var mock: User? {
            guard let fileURL = Bundle.main.url(forResource: "mock_user", withExtension: "json") else {
                assertionFailure(); return nil }
            do {
                let data = try Data(contentsOf: fileURL)
                return try API().decoder.decode(API.User.self, from: data)
            } catch {
                return nil
            }
        }
    }
    
    // MARK: - Report
    struct Report: Codable {
        let id: Int
        let areaId: String
        let date: String
        let tags: Tags
        let createdAt: String
        let updatedAt: String
        let deletedAt: String
        
        struct Tags: Codable {
            let legacyElements: Int
            let outdatedElements: Int
            let totalElements: Int
            let totalElementsLightning: Int
            let totalElementsLightningContactless: Int
            let totalElementsOnchain: Int
            let upToDateElements: Int
        }
        
        static var mock: Report? {
            guard let fileURL = Bundle.main.url(forResource: "mock_report", withExtension: "json") else {
                assertionFailure(); return nil }
            do {
                let data = try Data(contentsOf: fileURL)
                return try API().decoder.decode(API.Report.self, from: data)
            } catch {
                return nil
            }
        }
    }
}

// MARK: - Calls
extension API {
    // MARK: Generic
    func items<Item: Decodable>(_ since: String?, resource: String, completion: @escaping API.Completion<[Item]>) {
        let query: REST.Query? = {
            guard let since = since else { return nil }
            return ["updated_since": since]
        }()
        rest.get("v2/\(resource)", query: query, completion: completion)
    }
    
    // MARK: Specific
    func elements(_ since: String? = nil, completion: @escaping Completion<[Element]>) {
        items(since, resource: "elements", completion: completion )
    }
    
    func areas(_ since: String? = nil, completion: @escaping Completion<[Area]>) {
        items(since, resource: "areas", completion: completion )
    }
}
