//
//  ElementQuizDataSource.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 10.12.2023.
//

import UIKit

final class ElementQuizDataSource {
    func elementToDisplayItem(_ model: ChemicalElementModel) -> ElementIconView.DisplayItem {
        ElementIconView.DisplayItem(
            symbolTitle: model.symbol,
            elementNumberTitle: String(model.number),
            atomicMassTitle: String(format: "%.3f", model.atomicMass),
            color: choseColorForIcon(categiry: model.category)
        )
    }
    
    private func choseColorForIcon(categiry: String) -> UIColor {
        switch categiry {
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
