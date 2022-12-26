//
//  CommunitiesViewModel.swift
//  BTCMap
//
//  Created by salva on 12/25/22.
//

import Foundation
import os
import Combine

class CommunitiesViewModel: ObservableObject {
    let api: API
    let logger = Logger(subsystem: "org.btcmap.app", category: "Communities")
    let queue = DispatchQueue(label: "org.btcmap.app.communities")
    
    @Published private(set) var areas: [API.Area] = []
    var communities: [API.Area] { areas.filter { $0.type != "country" } }
        
    init(api: API) {
        self.api = api        
        fetchAreas()
    }
    
    func fetchAreas() {
        api.areas() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let areas):
                self.logger.log("Loaded created and changed areas: \(areas.count)")
                DispatchQueue.main.async { self.areas = areas }
            case .failure(let error):
                self.logger.fault("Failed load areas since with error: \(error as NSError)")
            }
        }
    }
}
