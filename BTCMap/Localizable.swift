//
//  Localizable.swift
//
//  Created by Vitaly Berg on 10/5/21.
//  Copyright © 2021 Vitaly Berg. All rights reserved.
//

import Foundation

extension String {
    var localized: String { NSLocalizedString(self, comment: "") }
    func localized(_ arguments: CVarArg...) -> String { String(format: self.localized, arguments: arguments) }
}
