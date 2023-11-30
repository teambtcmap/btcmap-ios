//
//  Event.swift
//  BTCMap
//
//  Created by salva on 11/30/23.
//

import Foundation

extension API {
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
}
