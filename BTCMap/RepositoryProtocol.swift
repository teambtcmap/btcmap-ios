//
//  RepositoryProtocol.swift
//  BTCMap
//
//  Created by salva on 1/19/23.
//

import Foundation
import os

protocol Repository<Item> {
    associatedtype Item: Codable
    var api: API { get }
    var logger: Logger { get }
    var queue: DispatchQueue { get }
    var defaults: UserDefaults { get }
    var defaultLastUpdatedKey: String { get }
    var bundledJsonPath: String { get }
    var documentPath: String { get }
    var description: String { get }
    
    var lastUpdated: String? { get }

    var items: Array<Item> {get}
    
    init(api: API)
    
    func start()
    func fetchBundledItemsIfNeeded() throws -> [Item]?
    func storeLocal(_ items: Array<Item>) throws
    func fetchLocal() throws -> Array<Item>
    func deleteLocal() throws
    
    func calculateLastUpdate() -> String?
    func clearLastUpdated()
    func fetchRemote(since: String?)
}

internal struct BadLibraryURLError: Error {}
internal struct BadBundledURLError: Error {}

extension Repository {
    internal func fetchBundledItemsIfNeeded() throws -> [Item]? {
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
    
    internal func storeLocal(_ items: [Item]) throws {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let url = libraryURL.appendingPathComponent(documentPath)
        let data = try api.encoder.encode(items)
        try data.write(to: url)
    }
    
    internal func fetchLocal() throws -> [Item] {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let url = libraryURL.appendingPathComponent(documentPath)
        let data = try Data(contentsOf: url)
        return try api.decoder.decode([Item].self, from: data)
    }
    
    internal func deleteLocal() throws {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { throw BadLibraryURLError() }
        let url = libraryURL.appendingPathComponent(documentPath)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw NSError(domain: "com.example.MyApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete local file"])
        }
    }
    
    var lastUpdated: String? {
        return defaults.string(forKey: defaultLastUpdatedKey) ?? calculateLastUpdate()
    }
    
    func clearLastUpdated() {
        defaults.removeObject(forKey: defaultLastUpdatedKey)
    }
}
