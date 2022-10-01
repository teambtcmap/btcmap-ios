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
        struct Data: Identifiable, Equatable, Codable {
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
                let type: DataType
                let role: String
                let geometry: Geometry?
            }
            
            let id: Int64
            let type: DataType
            let uid: Int
            let user: String
            let timestamp: Date
            let version: Int
            let changeset: Int64
            let tags: [String: String]
            let lat: Double?
            let lon: Double?
            let geometry: Geometry?
            let bounds: Bounds?
            let nodes: [Int64]?
            let members: [Member]?
        }
        
        enum DataType: String, Codable {
            case node
            case way
            case relation
        }
        
        let id: String
        let data: Data
        let createdAt: Date
        let updatedAt: Date
        let deletedAt: Date?
    }
    
    func elements(completion: @escaping Completion<[Element]>) {
        rest.get("elements", completion: completion)
    }
    
    func elementsSince(_ since: Date, completion: @escaping Completion<[Element]>) {
        rest.get("elements", query: ["created_or_updated_since": ISO8601DateFormatter().string(from: since)], completion: completion)
    }
}
