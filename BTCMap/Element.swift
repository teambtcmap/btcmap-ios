//
//  Element.swift
//  BTCMap
//
//  Created by salva on 11/30/23.
//

import Foundation
import CoreLocation

extension API {
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
}
