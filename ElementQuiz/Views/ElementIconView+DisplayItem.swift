//
//  ElementIconView+DisplayItem.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 05.12.2023.
//

import UIKit

extension ElementIconView {
    struct DisplayItem {
        let symbolTitle: String
        let elementNumberTitle: String
        let atomicMassTitle: String
        let color: UIColor
        
        static var element1: Self {
            DisplayItem(
                symbolTitle: "symbolLabel",
                elementNumberTitle: "El #1",
                atomicMassTitle: "mass1",
                color: UIColor(cgColor: CGColor(red: 0.8, green: 0.5, blue: 0.35, alpha: 1))
            )
        }
        
        static var element2: Self {
            DisplayItem(
                symbolTitle: "symbolLabe2",
                elementNumberTitle: "El #2",
                atomicMassTitle: "mass2",
                color: CustomColors.actinide
            )
        }
        
        static var element3: Self {
            DisplayItem(
                symbolTitle: "symbolLabe3",
                elementNumberTitle: "El #3",
                atomicMassTitle: "mass3",
                color: UIColor(cgColor: CGColor(red: 0.1, green: 0.5, blue: 0.35, alpha: 1))
            )
        }
    }
}
