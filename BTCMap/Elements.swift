//
//  Elements.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation
import os

class Elements {
    let api: API
    let logger = Logger(subsystem: "org.btcmap.app", category: "Elements")
    let queue = DispatchQueue(label: "org.btcmap.app.elements")
    
    init(api: API) {
        logger.log("Init")
        self.api = api
        queue.async { self.start() }
    }
    
    static let changed = Notification.Name("BTCMapElementsChanged")
    static let elements = "elements"
    
    private(set) var elements: [API.Element] = []
    
    private struct BadLibraryURLError: Error {}
    private struct BadBundledURLError: Error {}
    
    private func start() {
        do {
            logger.log("Copy bundled elements if needed")
            try copyBundledElementsIfNeeded()
            logger.log("Fetch local elements")
            let elements = try fetchElements()
            logger.log("Fetched local elements: \(elements.count)")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.elements = elements
                NotificationCenter.default.post(name: Self.changed, object: self, userInfo: [
                    Self.elements: elements
                ])
                self.queue.async { self.check(since: self.calculateLastUpdate()) }
            }
        } catch {
            // TODO: Quick fix for bug where on fresh install, if no elements.json found above in `do` block, we'd skip to `catch` and never hit API.
            //  Map would remain without data. Added line below but need to re-work this initialization flow.
            self.queue.async { self.check() }
            logger.fault("Failed start with error: \(error as NSError)")
        }
    }
    
    private func copyBundledElementsIfNeeded() throws {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let elementsURL = libraryURL.appendingPathComponent("elements.json")
        if !FileManager.default.fileExists(atPath: elementsURL.path) {
            guard let bundledURL = Bundle.main.url(forResource: "elements", withExtension: "json") else { throw BadBundledURLError() }
            try FileManager.default.copyItem(at: bundledURL, to: elementsURL)
        }
    }
    
    private func storeElements(_ elements: [API.Element]) throws {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let elementsURL = libraryURL.appendingPathComponent("elements.json")
        let data = try api.encoder.encode(elements)
        try data.write(to: elementsURL)
    }
    
    private func fetchElements() throws -> [API.Element] {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let elementsURL = libraryURL.appendingPathComponent("elements.json")
        let data = try Data(contentsOf: elementsURL)
        return try api.decoder.decode([API.Element].self, from: data)
    }
    
    private func calculateLastUpdate() -> String? {
        let elements = self.elements
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
                var currentElements = self.elements
                self.queue.async {
                    let elementsId = elements.reduce(into: Set<String>()) { $0.insert($1.id) }
                    currentElements = currentElements.filter { !elementsId.contains($0.id) } + elements
                    DispatchQueue.main.async {
                        self.elements = currentElements
                        NotificationCenter.default.post(name: Self.changed, object: self, userInfo: [
                            Self.elements: elements
                        ])
                    }
                    do {
                        self.logger.log("Store created and changed elements: \(currentElements.count)")
                        try self.storeElements(currentElements)
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
