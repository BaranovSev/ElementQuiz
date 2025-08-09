//
//  Colors.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 08.12.2023.
//

import UIKit


enum SelectionBoxType {
    case square
    case round
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
        }
    }
}


struct UserSelectionStyle {
    static private var selectedType: SelectionBoxType = .square
    static var currentType: SelectionBoxType {
        return selectedType
    }
    static func setStyle(_ style: SelectionBoxType) {
        selectedType = style
    }
}

enum Theme: String, CaseIterable {
    case standard = "Standard colors"
    case darkBlue = "Night blue"
    case brown = "Autumn brown"
}

struct CustomColors {
    private static var currentTheme: Theme = .standard
    
    private static var colors: (
        generalAppFont: UIColor,
        generalTextColor: UIColor,
        softAppColor: UIColor,
        progressBarColor: UIColor,
        salutteColor: UIColor,
        bigButtonColor: UIColor,
        forHeaders: UIColor,
        periodicTableTextColor: UIColor,
        fontForCell: UIColor,
        alphaFontInCell: UIColor
    ) {
        
        switch currentTheme {
        case .standard:
            return (
                generalAppFont: UIColor(named: "white_richBlack") ?? UIColor.white,
                generalTextColor: UIColor(named: "oxfordBlue_lavender") ?? UIColor.white,
                softAppColor: UIColor(named: "oxfordBlue_charcoal") ?? UIColor.white,
                progressBarColor: UIColor(named: "gold") ?? UIColor.white,
                salutteColor: UIColor(named: "gold") ?? UIColor.white,
                bigButtonColor: UIColor(named: "ultraViolet") ?? UIColor.white,
                forHeaders: UIColor(named: "charcoal_lavender") ?? UIColor.white,
                periodicTableTextColor: UIColor(named: "oxfordBlue_white") ?? UIColor.white,
                fontForCell: UIColor(named: "lavender_charcoal") ?? UIColor.white,
                alphaFontInCell: UIColor(named: "white_with_alpha") ?? UIColor.white
            )
            
        case .darkBlue:
            return (
                generalAppFont: UIColor(named: "dark_richBlack_blackBlue") ?? UIColor.white,
                generalTextColor: UIColor(named: "dark_columbiaBlue_airSuperiorityBlue") ?? UIColor.white,
                softAppColor: UIColor(named: "dark_charocal_lapisLazuli") ?? UIColor.white,
                progressBarColor: UIColor(named: "dark_gold") ?? UIColor.white,
                salutteColor: UIColor(named: "dark_gold") ?? UIColor.white,
                bigButtonColor: UIColor(named: "dark_ultraBlue") ?? UIColor.white,
                forHeaders: UIColor(named: "dark_airSuperiorityBlue") ?? UIColor.white,
                periodicTableTextColor: UIColor(named: "dark_richBlack_blackBlue") ?? UIColor.white, //here the same as generalAppPhont
                fontForCell: UIColor(named: "dark_charocal_oxfordBlue") ?? UIColor.white,
                alphaFontInCell: UIColor(named: "dark_white_with_alpha") ?? UIColor.white
            )
            
        case .brown:
            return (
                generalAppFont: UIColor(named: "brown_generalAppFont") ?? UIColor.white,
                generalTextColor: UIColor(named: "brown_generalTextColor") ?? UIColor.white,
                softAppColor: UIColor(named: "brown_softAppColor") ?? UIColor.white,
                progressBarColor: UIColor(named: "brown_gold") ?? UIColor.white,
                salutteColor: UIColor(named: "brown_gold") ?? UIColor.white,
                bigButtonColor: UIColor(named: "brown_ultraBrown") ?? UIColor.white,
                forHeaders: UIColor(named: "brown_forHeaders") ?? UIColor.white,
                periodicTableTextColor: UIColor(named: "brown_periodicTableTextColor") ?? UIColor.white,
                fontForCell: UIColor(named: "brown_fontForCell") ?? UIColor.white,
                alphaFontInCell: UIColor(named: "brown_white_with_alpha") ?? UIColor.white
            )
        }
    }
    
    static var softAppColor: UIColor {
        return colors.softAppColor
    }
    static var generalTextColor: UIColor {
        return colors.generalTextColor
    }
    static var secondaryTextColor: UIColor {
        return colors.forHeaders
    }
    static var generalAppFont: UIColor {
        return colors.generalAppFont
    }
    static var periodicTableTextColor: UIColor {
        return colors.periodicTableTextColor
    }
    static var backgroundForCell: UIColor {
        return colors.fontForCell
    }
    static var progressBarColor: UIColor {
        return colors.progressBarColor
    }
    static var salutteColor: UIColor {
        return colors.salutteColor
    }
    static var alphaFontInCell: UIColor {
        return colors.alphaFontInCell
    }
    static var bigButtonColor: UIColor {
        return colors.bigButtonColor
    }
    
    static func setTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    static func getCurrentTheme() -> Theme {
        return currentTheme
    }

    //Chemical elements colors:
    static let actinide = UIColor(named: "actinide") ?? UIColor.white
    static let alkaliMetal = UIColor(named: "alkaliMetal") ?? UIColor.white
    static let alkalineEarthMetal = UIColor(named: "alkalineEarthMetal") ?? UIColor.white
    static let diatomicNonmetal = UIColor(named: "diatomicNonmetal") ?? UIColor.white
    static let lanthanide = UIColor(named: "lanthanide") ?? UIColor.white
    static let metalloid = UIColor(named: "metalloid") ?? UIColor.white
    static let nobleGas = UIColor(named: "nobleGas") ?? UIColor.white
    static let polyatomicNonmetal = UIColor(named: "polyatomicNonmetal") ?? UIColor.white
    static let postTransitionMetal = UIColor(named: "postTransitionMetal") ?? UIColor.white
    static let transitionMetal = UIColor(named: "transitionMetal") ?? UIColor.white
    static let nonmetal = UIColor(named: "nonmetal") ?? UIColor.white
    static let halogen = UIColor(named: "halogen") ?? UIColor.white
    static let unknownElement = UIColor(named: "unknownElement") ?? UIColor.white
    static let sblock = UIColor(named: "sblock") ?? UIColor.white
    static let pblock = UIColor(named: "pblock") ?? UIColor.white
    static let dblock = UIColor(named: "dblock") ?? UIColor.white
    static let fblock = UIColor(named: "fblock") ?? UIColor.white
    
//    technical colors
    static let greenCorrectAnswer = UIColor(red: 0.298, green: 1.0, blue: 0.298, alpha: 1.0)
    static let greenLight = UIColor(red: 0.400, green: 1.0, blue: 0.400, alpha: 1.0)
    static let redIncorrectAnswer = UIColor(red: 1.0, green: 0.298, blue: 0.298, alpha: 1.0)
    static let redLight = UIColor(red: 1.0, green: 0.400, blue: 0.400, alpha: 1.0)
}

extension CustomColors {
    static func choseColor(_ category: String) -> UIColor {
        switch category {
        case "actinide":
            return CustomColors.actinide
        case "alkali metal":
            return CustomColors.alkaliMetal
        case "alkaline earth metal":
            return CustomColors.alkalineEarthMetal
        case "diatomic nonmetal":
            return CustomColors.diatomicNonmetal
        case "lanthanide":
            return CustomColors.lanthanide
        case "metalloid":
            return CustomColors.metalloid
        case "noble gas":
            return CustomColors.nobleGas
        case "polyatomic nonmetal":
            return CustomColors.polyatomicNonmetal
        case "post-transition metal":
            return CustomColors.postTransitionMetal
        case "transition metal":
            return CustomColors.transitionMetal
        case "unknown":
            return CustomColors.unknownElement
        case "nonmetal":
            return CustomColors.nonmetal
        case "halogen":
            return CustomColors.halogen
        case "s":
            return CustomColors.sblock
        case "p":
            return CustomColors.pblock
        case "d":
            return CustomColors.dblock
        case "f":
            return CustomColors.fblock
        default:
            return UIColor.black
        }
    }
}

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var formattedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if formattedHex.hasPrefix("#") {
            formattedHex.remove(at: formattedHex.startIndex)
        }
        
        guard formattedHex.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: formattedHex).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
