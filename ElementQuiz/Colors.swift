//
//  Colors.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 08.12.2023.
//

import UIKit

enum Theme: String {
    case standard
    case dark
}

struct CustomColors {
    private static var currentTheme: Theme = .dark
    
    private static var colors: (phontColor: UIColor, secondaryColor: UIColor, softColor: UIColor, progressBarColor: UIColor, salutteColor: UIColor, bigButtonColor: UIColor, mainColor: UIColor, forHeaders: UIColor, periodicTableTextColor: UIColor, phontForCell: UIColor, alphaPhontInCell: UIColor) {
        
        switch currentTheme {
        case .standard:
            return (
                UIColor(named: "white_richBlack") ?? UIColor.white,
                UIColor(named: "lavender_black") ?? UIColor.white,
                UIColor(named: "oxfordBlue_charcoal") ?? UIColor.white,
                UIColor(named: "gold") ?? UIColor.white,
                UIColor(named: "gold") ?? UIColor.white,
                UIColor(named: "ultraViolet") ?? UIColor.white,
                UIColor(named: "oxfordBlue_lavender") ?? UIColor.white,
                UIColor(named: "charcoal_lavender") ?? UIColor.white,
                UIColor(named: "oxfordBlue_white") ?? UIColor.white,
                UIColor(named: "lavender_charcoal") ?? UIColor.white,
                UIColor(named: "white_with_alpha") ?? UIColor.white
            )
            
        case .dark:
            return (
                UIColor(named: "dark_white_richBlack") ?? UIColor.black,
                UIColor(named: "dark_lavender_black") ?? UIColor.black,
                UIColor(named: "dark_oxfordBlue_charcoal") ?? UIColor.black,
                UIColor(named: "dark_gold") ?? UIColor.black,
                UIColor(named: "dark_gold") ?? UIColor.black,
                UIColor(named: "dark_ultraViolet") ?? UIColor.black,
                UIColor(named: "dark_oxfordBlue_lavender") ?? UIColor.black,
                UIColor(named: "dark_charcoal_lavender") ?? UIColor.black,
                UIColor(named: "dark_oxfordBlue_white") ?? UIColor.black,
                UIColor(named: "dark_lavender_charcoal") ?? UIColor.black,
                UIColor(named: "dark_white_with_alpha") ?? UIColor.black
            )
        }
    }
    
    static var softAppColor: UIColor {
        return colors.softColor
    }
    static var generalTextColor: UIColor {
        return colors.mainColor
    }
    static var secondaryTextColor: UIColor {
        return colors.forHeaders
    }
    static var generalAppPhont: UIColor {
        return colors.phontColor
    }
    static var periodicTableTextColor: UIColor {
        return colors.periodicTableTextColor
    }
    static var backgroundForCell: UIColor {
        return colors.phontForCell
    }
    static var progressBarColor: UIColor {
        return colors.progressBarColor
    }
    static var salutteColor: UIColor {
        return colors.salutteColor
    }
    static var alphaPhontInCell: UIColor {
        return colors.alphaPhontInCell
    }
    static var bigButtonColor: UIColor {
        return colors.bigButtonColor
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

    
    //TODO: uncomment >
////    theme colors
//    //dark blue theme
//    static private let phontColor = UIColor(named: "white_richBlack") ?? UIColor.white
//    static private let secondaryColor = UIColor(named: "lavender_black") ?? UIColor.white
//    static private let softColor = UIColor(named: "oxfordBlue_charcoal") ?? UIColor.white
//    static private let goldSoft = UIColor(named: "gold") ?? UIColor.white
//    static private let purpleButton = UIColor(named: "ultraViolet") ?? UIColor.white
//    static private let mainColor = UIColor(named: "oxfordBlue_lavender") ?? UIColor.white
//    static private let forHeaders = UIColor(named: "charcoal_lavender") ?? UIColor.white
//    static private let oxfordBlueWhite = UIColor(named: "oxfordBlue_white") ?? UIColor.white
//    static private let phontForCell = UIColor(named: "lavender_charcoal") ?? UIColor.white
//    static private let whiteCustomAlpha = UIColor(named: "white_with_alpha") ?? UIColor.white
//
//    static let softAppColor = softColor
//    static let generalTextColor = mainColor
//    static let secondaryTextColor = forHeaders
//    static let generalAppPhont = phontColor
//// TODO: - chose color for secondary
//    static let blackWhite = oxfordBlueWhite
//    static let backgroundForCell = phontForCell
//    static let gold = goldSoft
//    static let customWhite = whiteCustomAlpha
//
//    //Absolute black
////    static let generalAppPhont = secondaryColor
////    static let backgroundForCell = phontColor
//    //Violete
//
////    static let secondaryColor
//    static let purple = purpleButton

    
//TODO: uncomment <
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

