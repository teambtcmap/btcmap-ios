//
//  String+URLEncode.swift
//  BTCMap
//
//  Created by salva on 12/25/22.
//

import Foundation

public extension String {
    func urlEncoded() -> String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
