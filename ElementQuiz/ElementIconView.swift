//
//  ElementIconView.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 05.12.2023.
//

import UIKit

final class ElementIconView: UIView {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var elementNumberLabel: UILabel!
    @IBOutlet weak var atomicMassLabel: UILabel!
    
    func configure(for element: ChemicalElement) {
        switch element.category {
        case "actinide":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.8, green: 0.25, blue: 0.65, alpha: 1))
        case "alkali metal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.8, green: 0, blue: 0, alpha: 1))
        case "alkaline earth metal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.8, green: 0.5, blue: 0.35, alpha: 1))
        case "diatomic nonmetal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.56, green: 0.82, blue: 0.27, alpha: 1))
        case "lanthanide":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 0.35, blue: 1, alpha: 1))
        case "metalloid":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.32, green: 0.35, blue: 0.1, alpha: 1))
        case "noble gas":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1))
        case "polyatomic nonmetal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 0.7, blue: 0.1, alpha: 1))
        case "post-transition metal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
        case "transition metal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.88, green: 0.5, blue: 0.45, alpha: 1))
        case "unknown, but predicted to be an alkali metal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.8, green: 0, blue: 0, alpha: 0.75))
        case "unknown, predicted to be noble gas":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 0.75))
        case "unknown, probably metalloid":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.32, green: 0.35, blue: 0.1, alpha: 0.75))
        case "unknown, probably post-transition metal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75))
        case "unknown, probably transition metal":
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.88, green: 0.5, blue: 0.45, alpha: 0.75))
        default:
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        }
        
        symbolLabel.text = element.symbol
        elementNumberLabel.text = String(element.number)
        atomicMassLabel.text = String(format: "%.3f", element.atomicMass)
    }
}
