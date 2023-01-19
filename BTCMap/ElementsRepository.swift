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
    
    required init(api: API) {
        logger.log("Init")
        self.api = api
        queue.async { self.start() }
    }
        
    @Published private(set) var items: Array<API.Element> = []
    
    private struct BadLibraryURLError: Error {}
    private struct BadBundledURLError: Error {}
    
    internal func start() {
        do {
            logger.log("Copy bundled elements if needed")
            try copyBundledElementsIfNeeded()
            logger.log("Fetch local elements")
            let elements = try fetchLocal()
            logger.log("Fetched local elements: \(elements.count)")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.items = elements
                self.queue.async { self.check(since: self.calculateLastUpdate()) }
            }
        } catch {
            // TODO: Quick fix for bug where on fresh install, if no elements.json found above in `do` block, we'd skip to `catch` and never hit API.
            //  Map would remain without data. Added line below but need to re-work this initialization flow.
            self.queue.async { self.check() }
            logger.fault("Failed start with error: \(error as NSError)")
        }
    }
    
    // MARK: Local
    private func copyBundledElementsIfNeeded() throws {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let elementsURL = libraryURL.appendingPathComponent("elements.json")
        if !FileManager.default.fileExists(atPath: elementsURL.path) {
            guard let bundledURL = Bundle.main.url(forResource: "elements", withExtension: "json") else { throw BadBundledURLError() }
            try FileManager.default.copyItem(at: bundledURL, to: elementsURL)
        }
    }
    
    internal func storeLocal(_ items: [API.Element]) throws {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let elementsURL = libraryURL.appendingPathComponent("elements.json")
        let data = try api.encoder.encode(items)
        try data.write(to: elementsURL)
    }
    
    internal func fetchLocal() throws -> [API.Element] {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let elementsURL = libraryURL.appendingPathComponent("elements.json")
        let data = try Data(contentsOf: elementsURL)
        return try api.decoder.decode([API.Element].self, from: data)
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
        logger.log("Start checking created and changed elements")
        api.elements(since) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let elements):
                self.logger.log("Loaded created and changed elements: \(elements.count)")
                guard !elements.isEmpty else { return }
                var currentElements = self.items
                self.queue.async {
                    let elementsId = elements.reduce(into: Set<String>()) { $0.insert($1.id) }
                    currentElements = currentElements.filter { !elementsId.contains($0.id) } + elements
                    DispatchQueue.main.async {
                        self.items = currentElements
                    }
                    do {
                        self.logger.log("Store created and changed elements: \(currentElements.count)")
                        try self.storeLocal(currentElements)
                    } catch {
                        self.logger.log("Failed store created and changed elements with error: \(error as NSError)")
                    }
                }
            case .failure(let error):
                self.logger.fault("Failed load elements since with error: \(error as NSError)")
            }
        }
    }
}
