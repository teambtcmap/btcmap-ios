//
//  API.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation

class API {
    let rest: REST = .init(base: URL(string: "https://api.btcmap.org/")!)
    var encoder: JSONEncoder { rest.encoder }
    var decoder: JSONDecoder { rest.decoder }
    
    typealias Completion<Response> = (Result<Response, Error>) -> Void
    
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
    }
    
    func elements(completion: @escaping Completion<[Element]>) {
        rest.get("v2/elements", completion: completion)
    }
    
    func elementsSince(_ since: String, completion: @escaping Completion<[Element]>) {
        rest.get("v2/elements", query: ["updated_since": since], completion: completion)
    }
}
