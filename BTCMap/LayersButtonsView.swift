//
//  LayersButtonsView.swift
//  BTCMap
//
//  Created by salva on 4/13/23.
//

import Foundation
import SwiftUI

//TODO: 2. Toggle on/off annotations in MapVC
//TODO: 3. Add polygon logic + toggle on/off


enum MapLayersButtons: Int, CaseIterable {
    case topo
    case satellite
    case elements
    case communities
    
    static var styleCases: [MapLayersButtons] = [.topo, .satellite]
    static var objectsCases: [MapLayersButtons] = [.elements, .communities]

    var systemIcon: String {
        switch self {
        case .topo: return "map"
        case .satellite: return "map.fill"
        case .elements: return "mappin.and.ellipse"
        case .communities: return "person.3.fill"
        }
    }
}

struct LayersButtonsView: View {
    let closure0: () -> Void
    let closure1: () -> Void
    let closure2: () -> Void
    let closure3: () -> Void
    let hideButtons: () -> Void
    
    let buttonsWidth = 70.0
    let buttonsHeight = 50.0

    @Binding var mapStyleSelected: MapLayersButtons
    @Binding var mapObjectsSelected: MapLayersButtons
    let buttonsRow0: [MapLayersButtons] = [.topo, .satellite]
    let buttonsRow1: [MapLayersButtons] = [.elements, .communities]
    
    init(mapStyleSelected: Binding<MapLayersButtons>,
         mapObjectsSelected: Binding<MapLayersButtons>,
         closure0: @escaping () -> Void,
         closure1: @escaping () -> Void,
         closure2: @escaping () -> Void,
         closure3: @escaping () -> Void,
         hideButtons:  @escaping () -> Void) {
        self._mapStyleSelected = mapStyleSelected
        self._mapObjectsSelected = mapObjectsSelected
        self.closure0 = closure0
        self.closure1 = closure1
        self.closure2 = closure2
        self.closure3 = closure3
        self.hideButtons = hideButtons
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            buttonsRow(rowIndex: 0)
            Divider()
                .frame(width: buttonsWidth * 2 + 1, height: 0.5)
                .background(Color.white)
            buttonsRow(rowIndex: 1)
        }
    }
    
    private func button(row: Int, buttonType: MapLayersButtons) -> some View {
        Button(action: {
            row == 0 ? (mapStyleSelected = buttonType) : (mapObjectsSelected = buttonType)
            performClosure(for: buttonType.rawValue)
        }) {
            Image(systemName: buttonType.systemIcon)
                .foregroundColor(row == 0 && buttonType == mapStyleSelected || row == 1 && buttonType == mapObjectsSelected ? .white : .gray.opacity(0.7))
                .frame(width: buttonsWidth, height: buttonsHeight)
                .background(row == 0 ? Color.black.opacity(0.5) : Color.black.opacity(1.0))
        }
    }

    private func buttonsRow(rowIndex: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(rowIndex == 0 ? MapLayersButtons.styleCases : MapLayersButtons.objectsCases, id: \.self) { buttonType in
                button(row: rowIndex, buttonType: buttonType)
                    .cornerRadius(rowIndex == 0 && buttonType == .topo ? 10 : 0, corners: [.topLeft])
                    .cornerRadius(rowIndex == 0 && buttonType == .satellite ? 10 : 0, corners: [.topRight])
                    .cornerRadius(rowIndex == 1 && buttonType == .elements ? 10 : 0, corners: [.bottomLeft])
                    .cornerRadius(rowIndex == 1 && buttonType == .communities ? 10 : 0, corners: [.bottomRight])
                if buttonType != .satellite && buttonType != .communities {
                    Divider()
                        .frame(height: buttonsHeight - 16)
                        .background(Color.white)
                }
            }
        }
        .padding(.bottom, rowIndex < MapLayersButtons.allCases.count - 1 ? 1 : 0)
    }
    
    private func performClosure(for buttonIndex: Int) {
        hideButtons()
        
        switch buttonIndex {
        case 0: closure0()
        case 1: closure1()
        case 2: closure2()
        case 3: closure3()
        default:
            break
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
