//
//  API.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import Foundation
import os
import CoreLocation

// API Documentation: https://wiki.btcmap.org/api/introduction.html
class API {
    let logger = Logger(subsystem: "org.btcmap.app", category: "API")
    let rest: REST = .init(base: URL(string: "https://api.btcmap.org/")!)
    var encoder: JSONEncoder { rest.encoder }
    var decoder: JSONDecoder { rest.decoder }
    
    typealias Completion<Response> = (Result<Response, Error>) -> Void    
}

// MARK: - Calls
extension API {
    // MARK: Generic
    func items<Item: Decodable>(_ since: String?, resource: String, completion: @escaping API.Completion<[Item]>) {
        let query: REST.Query? = {
            guard let since = since else { return nil }
            return ["updated_since": since]
        }()
        rest.get("v2/\(resource)", query: query, completion: completion)
    }
    
    // MARK: Specific
    func elements(_ since: String? = nil, completion: @escaping Completion<[Element]>) {
        items(since, resource: "elements", completion: completion )
    }
    
    func areas(_ since: String? = nil, completion: @escaping Completion<[Area]>) {
        items(since, resource: "areas", completion: completion )
    }
}
