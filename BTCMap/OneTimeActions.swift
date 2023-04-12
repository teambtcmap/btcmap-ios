//
//  OneTimeActions.swift
//  BTCMap
//
//  Created by salva on 4/11/23.
//

import Foundation

enum OneTimeActionError: Error {
    case notPerformed
}

struct OneTimeActions {
    private static let userDefaults = UserDefaults.standard
    
    enum Action: String, CaseIterable {
        case wipeAreasLocalForPolygonBug
    }
    
    static func hasPerformed(_ action: Action) -> Bool {
        return userDefaults.bool(forKey: action.rawValue)
    }
    
    static func setPerformed(_ action: Action) {
        userDefaults.set(true, forKey: action.rawValue)
    }
    
    static func resetPerformed(_ action: Action) {
        userDefaults.set(false, forKey: action.rawValue)
    }
}

// MARK: - Specific OneTimeActions

/**
 Fixes a bug from v1.1.2. Because Polygons weren't implemented yet in 1.1.2, the Areas weren't cached locally without them. Since we only fetch new areas after the last `updatedAt` date, we weren't re-fetching these areas once the Polygon code was implemented in v1.2.
 */
struct OneTimeAction_WipeAreasLocalForPolygonBug {
    private let areasRepository: AreasRepository
    private let action: OneTimeActions.Action = .wipeAreasLocalForPolygonBug
    
    init(areasRepository: AreasRepository) {
        self.areasRepository = areasRepository
    }
    
    func perform() {
        do {
            try areasRepository.deleteLocal()
            OneTimeActions.setPerformed(action)
        } catch {
            print("Error wiping areas local repo for polygon bug: \(error)")
        }
    }
}
