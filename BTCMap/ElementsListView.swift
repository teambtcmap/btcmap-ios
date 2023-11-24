//
//  ElementsListView.swift
//  BTCMap
//
//  Created by salva on 11/22/23.
//

import Foundation
import SwiftUI

struct ElementsListView: View {
    @EnvironmentObject var appState: AppState
    var elementsRepo: ElementsRepository { appState.elementsRepository }
    
    @State private var elements: [API.Element] = []
//
    //HERE: TODO: When select an item and on that merchant detail view, hightlight pin
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Spacer()
                    Text("nearby_merchants".localized)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 15)
                    Spacer()
                }
                
                if elements.isEmpty { NoElementsView() }

                ForEach(elements) { element in
                    NavigationLink(destination: ElementView(element: element)) {
                        ElementRowView(element: element)
                    }
                }
                .listRowSeparator(.visible)
                .listRowSeparatorTint(Color.BTCMap_DiscordLightBlack)
                .listRowBackground(Color.BTCMap_DiscordDarkBlack)

            }
            .background(Color.BTCMap_DiscordDarkBlack)
            
            // rebuild on bounds change or filtered items change
            .onReceive(appState.mapState.$bounds) { newBounds in
                elements = ElementsRepository.elements(elements: elementsRepo.filteredItems,
                                                       within: newBounds)
            }
            .onReceive(elementsRepo.$filteredItems) { newItems in
                //HACK: There was a timing bug where `elements` here wasn't updating on app start. Wasn't able to fix the underlying issue so added this 0.5 delay for now
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    elements = ElementsRepository.elements(elements: elementsRepo.filteredItems,
                                                           within: appState.mapState.bounds)
                }
            }
        }
        .accentColor(.BTCMap_WarmWhite)
    }
}

