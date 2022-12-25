//
//  API.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation
import os

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
    
    func elements(completion: @escaping Completion<[Element]>) {
        rest.get("v2/elements", completion: completion)
    }
    
    func elements(_ since: String?, completion: @escaping Completion<[Element]>) {
        let query: REST.Query? = {
            guard let since = since else { return nil }
            return ["updated_since": since]
        }()
        rest.get("v2/elements", query: query, completion: completion)
    }
    
    // MARK: - Area
    struct Area: Codable {
        let id: String
        let tags: Tags
        let createdAt: String
        let updatedAt: String
        let deletedAt: String

        struct Tags: Codable {
            let boxEast: Double
            let boxNorth: Double
            let boxSouth: Double
            let boxWest: Double          
            let discord: String
            let twitter: String
            let website: String
            let iconSquare: String
            let name: String
            let type: String

            private enum CodingKeys: String, CodingKey {
                case boxEast = "box:east"
                case boxNorth = "box:north"
                case boxSouth = "box:south"
                case boxWest = "box:west"
                case discord = "contact:discord"
                case twitter = "contact:twitter"
                case website = "contact:website"
                case iconSquare = "icon:square"
                case name
                case type
            }
        }
        
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
