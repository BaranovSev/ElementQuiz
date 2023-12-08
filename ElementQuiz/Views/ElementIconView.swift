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
    
    var displayItem: DisplayItem? {
        didSet {
            refresh()
        }
    }
    
    init(displayItem: DisplayItem) {
        super.init(frame: .zero)
        self.displayItem = displayItem
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

private extension ElementIconView {
    func refresh() {
        guard let displayItem = displayItem else { return }
        
        symbolLabel.text = displayItem.symbolTitle
        elementNumberLabel.text = displayItem.elementNumberTitle
        atomicMassLabel.text = displayItem.atomicMassTitle
        backgroundColor = displayItem.color
    }
    
    func setup() {
        layout()
    }
    
    func layout() {
        //constraints
    }
}
