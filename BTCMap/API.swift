//
//  API.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation
import os
import CoreLocation
import GEOSwift

// API Documentation: https://wiki.btcmap.org/api/introduction.html
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
            
            // MARK: - Verify
            var surveyDates: [String] {
                var surveyDates = [String]()
                
                if let date = tags?["survey:date"] {
                    surveyDates.append(date)
                }
                
                if let date = tags?["check_date"] {
                    surveyDates.append(date)
                }
                
                if let date = tags?["check_date:currency:XBT"] {
                    surveyDates.append(date)
                }
                
                return surveyDates
            }
            
            var latestSurveyDate: Date? {
                guard !surveyDates.isEmpty,
                      let max = surveyDates.max() else {
                    return nil }
                
                // NOTE: These dates come back as a simple string in formate `2022-11-22`. So need to massage to work for DateFormatter.
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                guard let date = formatter.date(from: max) else {
                    return nil }
            
                return date
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
            let geoJson: GeoJson?
            let discord: String?
            let twitter: String?
            let telegram: String?
            let website: String?
            let youtube: String?
            let iconSquare: String?
            let name: String?
            let type: String?
            let amenity: String?
            
            private enum CodingKeys: String, CodingKey {
                case boxEast = "box:east"
                case boxNorth = "box:north"
                case boxSouth = "box:south"
                case boxWest = "box:west"
                case geoJson
                case discord = "contact:discord"
                case twitter = "contact:twitter"
                case telegram = "contact:telegram"
                case website = "contact:website"
                case youtube = "contact:youtube"
                case iconSquare = "icon:square"
                case name, type, amenity
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
                telegram = try container.decodeIfPresent(String.self, forKey: .telegram)
                website = try container.decodeIfPresent(String.self, forKey: .website)
                youtube = try container.decodeIfPresent(String.self, forKey: .youtube)
                iconSquare = try container.decodeIfPresent(String.self, forKey: .iconSquare)
                name = try container.decodeIfPresent(String.self, forKey: .name)
                type = try container.decodeIfPresent(String.self, forKey: .type)
                amenity = try container.decodeIfPresent(String.self, forKey: .amenity)
                geoJson = try container.decodeIfPresent(GeoJson.self, forKey: .geoJson)
            }
            
            // MARK: GeoJson
            struct GeoJson: Codable {
                let type: String
                let coordinates: [[CLLocationCoordinate2D]]?
                let features: [Feature]?
                
                enum CodingKeys: String, CodingKey {
                    case type, coordinates, features
                }
                
                init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    type = try values.decode(String.self, forKey: .type)
                    features = try values.decodeIfPresent([Feature].self, forKey: .features)
                    
                    // separate decoding paths for "Polygon" and "MultiPolygon" types
                    switch type {
                    case "Polygon":
                        guard let rawCoordinates = try? values.decode([[[Double]]].self, forKey: .coordinates) else {
                            coordinates = nil; return }
                        
                        coordinates = [rawCoordinates[0].map {
                            return CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
                        }]
                    case "MultiPolygon":
                        guard let rawCoordinates = try? values.decode([[[[Double]]]].self, forKey: .coordinates) else {
                            coordinates = nil; return }
                
                        coordinates = rawCoordinates[0].map { polygon in
                            polygon.map {
                                return CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
                            }
                        }
                    default: coordinates = nil; return
                    }
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(type, forKey: .type)
                    
                    guard let coordinates = coordinates else {
                        try container.encodeNil(forKey: .coordinates); return }

                    let rawCoordinates = coordinates.map {
                        $0.map { coord in
                            [coord.longitude, coord.latitude]
                        }
                    }
                    try container.encode(rawCoordinates, forKey: .coordinates)
                }
                
                struct Feature: Codable {
                    let type: String
                    let geometry: Geometry
                    let properties: Properties?
                    
                    struct Properties: Codable, Hashable {
                        let osmId: Int?
                        let boundary: String?
                        let adminLevel: Int?
                        let parents: [String]?
                        let name: String?
                        let localName: String?
                        let nameEn: String?
                    }
                    
                    enum Geometry: Codable {
                        case polygon(Polygon)
                        case multiPolygon(MultiPolygon)
                        
                        enum CodingKeys: String, CodingKey {
                            case type
                            case coordinates
                        }
                        
                        init(from decoder: Decoder) throws {
                            let values = try decoder.container(keyedBy: CodingKeys.self)
                            let type = try values.decode(String.self, forKey: .type)
                            switch type {
                            case "Polygon":
                                /// WARNING: The coords in `feature` come back as `[[Double]]`, but with longitude first. So they get decoded into `CLLocationCoordinate2D` incorreclty. Here we just manually switch them.
                                let coordinates = try values.decode([[CLLocationCoordinate2D]].self, forKey: .coordinates)
                                let exteriorRing = try Polygon.LinearRing(points: coordinates[0].map { Point(x: $0.longitude, y: $0.latitude )} )
                                let interiorRings = try coordinates[1...].map { try Polygon.LinearRing(points: $0.map { Point(x: $0.longitude, y: $0.latitude )}) }
                                let polygon = Polygon(exterior: exteriorRing, holes: interiorRings)
                                self = .polygon(polygon)
                            case "MultiPolygon":
                                let coordinates = try values.decode([[[CLLocationCoordinate2D]]].self, forKey: .coordinates)
                                let polygons = try coordinates.map { coords in
                                    let exteriorRing = try Polygon.LinearRing(points: coords[0].map { Point(x: $0.longitude, y: $0.latitude )} )
                                    let interiorRings = try coords[1...].map { try Polygon.LinearRing(points: $0.map { Point(x: $0.longitude, y: $0.latitude )}) }
                                    return Polygon(exterior: exteriorRing, holes: interiorRings)
                                }
                                let multiPolygon = MultiPolygon(polygons: polygons)
                                self = .multiPolygon(multiPolygon)
                            default:
                                throw DecodingError.dataCorruptedError(forKey: .type, in: values, debugDescription: "Unsupported type")
                            }
                        }
                        
                        func encode(to encoder: Encoder) throws {
                            var container = encoder.container(keyedBy: CodingKeys.self)
                            switch self {
                            case .polygon(let polygon):
                                try container.encode("Polygon", forKey: .type)
                                let coordinates = polygon.exterior.points.map { CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x) }
                                try container.encode(coordinates, forKey: .coordinates)
                            case .multiPolygon(let multiPolygon):
                                try container.encode("MultiPolygon", forKey: .type)
                                let coordinates = multiPolygon.polygons.map { polygon in
                                    polygon.exterior.points.map { CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x) }
                                }
                                try container.encode(coordinates, forKey: .coordinates)
                            }
                        }
                    }
                }
            }
        }
        
        // MARK: Getters
        var iconUrl: URL? { URL(string: tags.iconSquare ?? "") }
        var name: String? { tags.name }
        var type: String? { tags.type }
        var bounds: Bounds? {
            if let polygons = polygons, let unionedPolygon = unionedPolygon {
                return MapCalculations.bounds(from: unionedPolygon.coords)
            } else if let boxEast = tags.boxEast, let boxWest = tags.boxWest, let boxSouth = tags.boxSouth, let boxNorth = tags.boxNorth {
                return Bounds(maxlat: max(boxSouth, boxNorth),
                              maxlon: max(boxEast, boxWest),
                              minlat: min(boxSouth, boxNorth),
                              minlon: min(boxEast, boxWest))
            }
            return nil
        }
        
        // MARK: Polygons
        var polygons: [Polygon]? {
            guard let geoJson = tags.geoJson else { return nil }
            
            var result: [Polygon] = []
            switch geoJson.type {
            case "FeatureCollection":
                guard let features = geoJson.features else { break }
                for feature in features {
                    switch feature.geometry {
                    case .polygon(let polygon):
                        result.append(polygon)
                    case .multiPolygon(let multiPolygon):
                        result.append(contentsOf: multiPolygon.polygons)
                    }
                }
            case "MultiPolygon":
                guard let coords = geoJson.coordinates?.first else { break }
                let exteriorRing = try? Polygon.LinearRing(points: coords.map { Point(x: $0.latitude, y: $0.longitude )} )
                guard let exterior = exteriorRing else { break }
                
                let interiorRings = try? geoJson.coordinates?.dropFirst().map { try Polygon.LinearRing(points: $0.map { Point(x: $0.latitude, y: $0.longitude) }) }
                let polygon = Polygon(exterior: exterior, holes: interiorRings ?? [])
                result.append(polygon)
            case "Polygon":
                guard let coords = geoJson.coordinates?.first else { break }
                let exteriorRing = try? Polygon.LinearRing(points: coords.map { Point(x: $0.latitude, y: $0.longitude )} )
                guard let exterior = exteriorRing else { break }
                let polygon = Polygon(exterior: exterior)
                result.append(polygon)
            default: break
            }
            
            return result
        }
        
        var unionedPolygon: Polygon? {
            guard let polygons = polygons, polygons.count > 0 else { return nil }
            return polygons.reduce(into: polygons[0]) { result, polygon in
                do {
                    try result.union(with: polygon)
                } catch {
                    print("Failed to union polygons: \(error)")
                }
            }
        }
        
        // MARK: centerCoord
        var centerCoord: CLLocationCoordinate2D? {
            if let polygons = polygons {
                guard polygons.count > 0 else { return nil }
                guard let center: Point = try? polygons[0].centroid() else { return nil }
                return CLLocationCoordinate2D(latitude: center.x, longitude: center.y)
            } else if let bounds = bounds {
                guard let e = tags.boxEast, let w = tags.boxWest, let s = tags.boxSouth, let n = tags.boxNorth else { return nil }
                let lat = (s + n) / 2.0
                let lon = (e + w) / 2.0
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            } else { return nil }
            
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
