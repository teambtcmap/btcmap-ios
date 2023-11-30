//
//  AreasRepository.swift
//  BTCMap
//
//  Created by salva on 1/19/23.
//

import Foundation
import Combine
import CoreLocation
import os

class AreasRepository: ObservableObject, Repository {
    typealias Item = API.Area
        
    let api: API
    let logger = Logger(subsystem: "org.btcmap.app", category: "Areas")
    let queue = DispatchQueue(label: "org.btcmap.app.areas")
    let defaults = UserDefaults.standard
    let defaultLastUpdatedKey = "lastUpdate_areas"
    let bundledJsonPath: String = "areas"
    let documentPath: String = "areas"
    let description: String = "areas"

    required init(api: API) {
        logger.log("Init")
        self.api = api
        queue.async { self.start() }
    }
        
    @Published private(set) var allItems: Array<API.Area> = []
    lazy var communities: Array<API.Area> = { allItems.filter { $0.type != "country" } }()

    // MARK: Start
    internal func start() {
        do {
            guard OneTimeActions.hasPerformed(.wipeAreasLocalForPolygonBug) else {
                OneTimeAction_WipeAreasLocalForPolygonBug(areasRepository: self).perform()
                throw OneTimeActionError.notPerformed }

            logger.log("Fetch local \(self.description)")                        
            let items = try fetchLocal()
            logger.log("Fetched local \(self.description): \(items.count)")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.allItems = items
                self.queue.async { self.fetchRemote(since: self.lastUpdated) }
            }
        } catch {
            self.queue.async { self.fetchRemote() }
            logger.fault("Failed start with error: \(error as NSError) - fetching all from api")
        }
    }
    
    // MARK: Remote
    internal func calculateLastUpdate() -> String? {
        let items = self.allItems
        guard !items.isEmpty else { return nil }
        let since = items.sorted { $0.updatedAt > $1.updatedAt }.first?.updatedAt
        logger.log("Calculate last update: \(String(describing: since))")
        defaults.set(since, forKey: defaultLastUpdatedKey)
        return since
    }
    
    internal func fetchRemote(since: String? = nil) {
        logger.log("Start checking created and changed \(self.description)")
        api.areas(since) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                self.logger.log("Loaded created and changed \(self.description): \(items.count)")
                guard !items.isEmpty else { return }
                var currentItems = self.allItems
                self.queue.async {
                    let itemsId = items.reduce(into: Set<String>()) { $0.insert($1.id) }
                    currentItems = currentItems.filter { !itemsId.contains($0.id) } + items
                    DispatchQueue.main.async {
                        self.allItems = currentItems
                    }
                    do {
                        self.logger.log("Store created and changed \(self.description): \(currentItems.count)")
                        try self.storeLocal(currentItems)
                    } catch {
                        self.logger.log("Failed store created and changed \(self.description) with error: \(error as NSError)")
                    }
                }
            case .failure(let error):
                self.logger.fault("Failed load \(self.description) since with error: \(error as NSError)")
            }
        }
    }
}
