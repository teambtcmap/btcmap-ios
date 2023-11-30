//
//  User.swift
//  BTCMap
//
//  Created by salva on 11/30/23.
//

import Foundation

extension API {
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
