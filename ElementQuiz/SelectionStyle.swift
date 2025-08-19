//
//  SelectionStyle.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 10.08.2025.
//

enum SelectionBoxType: String, CaseIterable {
    case square
    case round
    case heart
    case star
    case seal
    case triangle
    case diamond
    case hexagon
}

extension SelectionBoxType {
    var images: (chosen: [String], unchosen: [String]) {
        switch self {
        case .square:
            return (["square.fill", "square.inset.filled", "square.dashed.inset.filled"],
                    ["square.dotted", "square.dashed", "square"])
        case .round:
            return (["circle.fill", "circle.inset.filled", "circle.dashed.inset.filled"],
                    ["circle.dotted", "circle.dashed", "circle"])
        case .heart:
            return (["heart.fill"],
                    ["heart"])
        case .star:
            return (["star.fill"],
                    ["star"])
        case .seal:
            return (["seal.fill"],
                    ["seal"])
        case .triangle:
            return (["triangle.fill"],
                    ["triangle"])
        case .diamond:
            return (["diamond.fill"],
                    ["diamond"])
        case .hexagon:
            return (["hexagon.fill"],
                    ["hexagon"])
        }
    }
}


struct UserSelectionStyle {
    static private var selectedType: SelectionBoxType = DataManager.shared.fetchUserSelectorTheme()
    static var currentType: SelectionBoxType {
        return selectedType
    }
    static func setStyle(_ style: SelectionBoxType) {
        selectedType = style
        DataManager.shared.updatePreferredSelectorTheme(style)
    }
}
