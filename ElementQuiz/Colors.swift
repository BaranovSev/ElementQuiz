//
//  Colors.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 08.12.2023.
//

import UIKit

struct CustomColors {
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
    static let unknownAlkaliMetal = UIColor(named: "unknownAlkaliMetal") ?? UIColor.white
    static let unknownNobleGas = UIColor(named: "unknownNobleGas") ?? UIColor.white
    static let unknownMetalloid = UIColor(named: "unknownMetalloid") ?? UIColor.white
    static let unknownpPostTransitionMetal = UIColor(named: "unknownPostTransitionMetal") ?? UIColor.white
    static let unknownTransitionMetal = UIColor(named: "unknownTransitionMetal") ?? UIColor.white
    static let unknownElement = UIColor(named: "unknownElement") ?? UIColor.white
    static let lightPurple = CGColor(red: 0.3, green: 0.25, blue: 0.65, alpha: 0.7)
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
        default:
            return UIColor.black
        }
    }
}

