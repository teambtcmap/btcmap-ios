//
//  Elements.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation
import os
import GEOSwift

class ElementsRepository: ObservableObject, Repository {
    typealias Item = API.Element
        
    let api: API
    let logger = Logger(subsystem: "org.btcmap.app", category: "Elements")
    let queue = DispatchQueue(label: "org.btcmap.app.elements")
    let defaults = UserDefaults.standard
    let defaultLastUpdatedKey = "lastUpdate_elements"
    let bundledJsonPath: String = "elements"
    let documentPath: String = "elements"
    let description: String = "elements"
    
    private var searchText: String = "" {
        didSet {
            filteredItems = filterItems(by: searchText) }
    }
    
    required init(api: API) {
        logger.log("Init")
        self.api = api
        queue.async { self.start() }
    }
    
    private(set) var allItems: Array<API.Element> = [] {
        didSet {
            filteredItems = filterItems(by: searchText)
        }
    }
    
    /// Filtered by search
    @Published private(set) var filteredItems: Array<API.Element> = []

    internal func start() {
        do {
            let items = try {
                logger.log("Fetch bundled \(self.description) if needed")
                if let fetchedItems = try fetchBundledItemsIfNeeded() {
                    try storeLocal(fetchedItems)
                    return fetchedItems
                } else {
                    logger.log("Fetch local \(self.description)")
                    let items = try fetchLocal()
                    logger.log("Fetched local \(self.description): \(items.count)")
                    return items
                }
            }()
            
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
        api.elements(since) { [weak self] result in
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

// MARK: - Filter elements by search
extension ElementsRepository {
    func searchStringDidChange(_ searchText: String) {
        self.searchText = searchText
    }
    
    fileprivate func filterItems(by searchText: String) -> Array<API.Element> {
        let filtered = allItems.filter { element in
            searchText.isEmpty || (element.osmJson.name.localizedCaseInsensitiveContains(searchText))
        }.filter { $0.deletedAt.isEmpty }
        return filtered
    }
}

// MARK: - Filter elements by geometry
extension ElementsRepository {
    static func elements(elements: Array<API.Element>,
                         within bounds: Bounds) -> Array<API.Element> {
        let filtered = elements.filter {
            guard let coord = $0.coord else { return false }
            return coord.latitude > bounds.minlat &&
            coord.latitude < bounds.maxlat &&
            coord.longitude > bounds.minlon &&
            coord.longitude < bounds.maxlon
        }
        return filtered
    }
    
    static func elements(elements: Array<API.Element>,
                         within polygon: Polygon) -> Array<API.Element> {
        let filtered = elements.filter {
            guard let coord = $0.coord else { return false }
            let contains = try? polygon.contains(coord.toPoint())
            guard let contains = contains else { return true }
            return contains
        }
        return filtered
    }
}
