//
//  UserStatisticDataSource.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 03.01.2024.
//

import UIKit

final class UserStatisticDataSource {
    func infoToDisplayItem(learned: [ChemicalElementModel], total: [ChemicalElementModel]) -> CircleProgressBar.DisplayItem {
        
        var elementsCategoryArray: [[UIColor:CGFloat]] = []

        func percentageOfprogress(_ categoryName: String) -> CGFloat {
            CGFloat(learned.filter { $0.category == categoryName }.count) / CGFloat(total.filter { $0.category == categoryName }.count)
        }
        
        func createViewModelForCategory(_ categoryName: String) {
            let categoryInfo = [choseColorFor(categiry: categoryName) : percentageOfprogress(categoryName)]
            elementsCategoryArray.append(categoryInfo)
        }
        
        createViewModelForCategory("actinide")
        createViewModelForCategory("alkali metal")
        createViewModelForCategory("alkaline earth metal")
        createViewModelForCategory("diatomic nonmetal")
        createViewModelForCategory("lanthanide")
        createViewModelForCategory("metalloid")
        createViewModelForCategory("noble gas")
        createViewModelForCategory("polyatomic nonmetal")
        createViewModelForCategory("post-transition metal")
        createViewModelForCategory("transition metal")
        createViewModelForCategory("unknown")
        
        return CircleProgressBar.DisplayItem(array: elementsCategoryArray)
    }
    

    private func choseColorFor(categiry: String) -> UIColor {
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
