//
//  HomeViewModel.swift
//  BTCMap
//
//  Created by salva on 11/26/23.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedElement: API.Element?
    @Published var deselectedElement: API.Element?
    private var cancellables = Set<AnyCancellable>()

    init(mapViewController: MapViewController) {
        mapViewController.selectedElementPublisher
            .sink { [weak self] element in
                self?.selectedElement = element
            }
            .store(in: &cancellables)
        
        mapViewController.deselectedElementPublisher
            .sink { [weak self] element in
                self?.deselectedElement = element
            }
            .store(in: &cancellables)
    }
}
