//
//  RepositoryProtocol.swift
//  BTCMap
//
//  Created by salva on 1/19/23.
//

import Foundation
import os

protocol Repository<Item> {
    associatedtype Item
    var api: API { get }
    var logger: Logger { get }
    var queue: DispatchQueue { get }
    var items: Array<Item> {get}
    
    init(api: API)
    
    func start()
    func storeLocal(_ items: Array<Item>) throws
    func fetchLocal() throws -> Array<Item>
}
