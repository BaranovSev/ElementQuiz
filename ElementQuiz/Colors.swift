//
//  Colors.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 08.12.2023.
//

import UIKit

enum Theme: String {
    case standard = "standard"
    case darkBlue = "darkBlue"
}

struct CustomColors {
    private static var currentTheme: Theme = .darkBlue
    
    private static var colors: (
        generalAppPhont: UIColor,
        softAppColor: UIColor,
        progressBarColor: UIColor,
        salutteColor: UIColor,
        bigButtonColor: UIColor,
        generalTextColor: UIColor,
        forHeaders: UIColor,
        periodicTableTextColor: UIColor,
        phontForCell: UIColor,
        alphaPhontInCell: UIColor
    ) {
        
        switch currentTheme {
        case .standard:
            return (
                generalAppPhont: UIColor(named: "white_richBlack") ?? UIColor.white,
                softAppColor: UIColor(named: "oxfordBlue_charcoal") ?? UIColor.white,
                progressBarColor: UIColor(named: "gold") ?? UIColor.white,
                salutteColor: UIColor(named: "gold") ?? UIColor.white,
                bigButtonColor: UIColor(named: "ultraViolet") ?? UIColor.white,
                generalTextColor: UIColor(named: "oxfordBlue_lavender") ?? UIColor.white,
                forHeaders: UIColor(named: "charcoal_lavender") ?? UIColor.white,
                periodicTableTextColor: UIColor(named: "oxfordBlue_white") ?? UIColor.white,
                phontForCell: UIColor(named: "lavender_charcoal") ?? UIColor.white,
                alphaPhontInCell: UIColor(named: "white_with_alpha") ?? UIColor.white
            )
            
        case .darkBlue:
            return (
                generalAppPhont: UIColor(named: "dark_richBlack_blackBlue") ?? UIColor.white,
                softAppColor: UIColor(named: "dark_charcoal_lapisLazuli") ?? UIColor.white,
                progressBarColor: UIColor(named: "dark_gold") ?? UIColor.white,
                salutteColor: UIColor(named: "dark_gold") ?? UIColor.white,
                bigButtonColor: UIColor(named: "dark_ultraBlue") ?? UIColor.white,
                generalTextColor: UIColor(named: "dark_columbiaBlue_airSuperiorityBlue") ?? UIColor.white,
                forHeaders: UIColor(named: "dark_airSuperiorityBlue") ?? UIColor.white,
                periodicTableTextColor: UIColor(named: "dark_richBlack_blackBlue") ?? UIColor.white, //here the same as generalAppPhont
                phontForCell: UIColor(named: "dark_charocal_oxfordBlue") ?? UIColor.white,
                alphaPhontInCell: UIColor(named: "dark_white_with_alpha") ?? UIColor.white
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
    static var generalAppPhont: UIColor {
        return colors.generalAppPhont
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

