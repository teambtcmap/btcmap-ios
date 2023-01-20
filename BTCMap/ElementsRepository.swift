//
//  Elements.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation
import os

class ElementsRepository: ObservableObject, Repository {
    
    typealias Item = API.Element
        
    let api: API
    let logger = Logger(subsystem: "org.btcmap.app", category: "Elements")
    let queue = DispatchQueue(label: "org.btcmap.app.elements")
    let bundledJsonPath: String = "elements"
    let documentPath: String = "elements"
    let description: String = "elements"

    required init(api: API) {
        logger.log("Init")
        self.api = api
        queue.async { self.start() }
    }
        
    @Published private(set) var items: Array<API.Element> = []
        
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
                self.items = items
                self.queue.async { self.check(since: self.calculateLastUpdate()) }
            }
        } catch {
            self.queue.async { self.check() }
            logger.fault("Failed start with error: \(error as NSError) - fetching all from api")
        }
    }
    
    // MARK: Local
    private func fetchBundledItemsIfNeeded() throws -> [Item]? {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let url = libraryURL.appendingPathComponent(documentPath)
        if !FileManager.default.fileExists(atPath: url.path) {
            guard let bundledURL = Bundle.main.url(forResource: bundledJsonPath, withExtension: "json") else { throw BadBundledURLError() }
            let data = try Data(contentsOf: bundledURL)
            let items = try api.decoder.decode([Item].self, from: data)
            return items
        }
        return nil
    }
    
    internal func storeLocal(_ items: [API.Element]) throws {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let url = libraryURL.appendingPathComponent(documentPath)
        let data = try api.encoder.encode(items)
        try data.write(to: url)
    }
    
    internal func fetchLocal() throws -> [API.Element] {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let url = libraryURL.appendingPathComponent(documentPath)
        let data = try Data(contentsOf: url)
        return try api.decoder.decode([Item].self, from: data)
    }
    
    // MARK: Remote
    private func calculateLastUpdate() -> String? {
        let elements = self.items
        guard !elements.isEmpty else { return nil }
        var since = elements[0].updatedAt
        for i in 1..<elements.count {
            if elements[i].updatedAt > since {
                since = elements[i].updatedAt
            }
        }
        logger.log("Calculate last update: \(since)")
        return since
    }
    
    private func check(since: String? = nil) {
        logger.log("Start checking created and changed \(self.description)")
        api.elements(since) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let elements):
                self.logger.log("Loaded created and changed \(self.description): \(elements.count)")
                guard !elements.isEmpty else { return }
                var currentElements = self.items
                self.queue.async {
                    let elementsId = elements.reduce(into: Set<String>()) { $0.insert($1.id) }
                    currentElements = currentElements.filter { !elementsId.contains($0.id) } + elements
                    DispatchQueue.main.async {
                        self.items = currentElements
                    }
                    do {
                        self.logger.log("Store created and changed \(self.description): \(currentElements.count)")
                        try self.storeLocal(currentElements)
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
