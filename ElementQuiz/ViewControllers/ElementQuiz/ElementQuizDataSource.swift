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
            color: CustomColors.choseColor(model.category)
        )
    }
}
