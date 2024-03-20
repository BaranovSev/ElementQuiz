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
            let categoryInfo = [CustomColors.choseColor(categoryName) : percentageOfprogress(categoryName)]
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
}
