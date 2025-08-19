//
//  ElementIconView.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 05.12.2023.
//

import UIKit
import SnapKit

final class ElementIconView: UIView {
    private var dataSource: ElementQuizDataSource?

    lazy var elementNumberLabel: UILabel = {
        var label = UILabel()
        label.textColor = CustomColors.softAppColor
        label.font = UIFont(name: "Hoefler Text", size: 24)
        addSubview(label)
        return label
    }()

    lazy var symbolLabel: UILabel  = {
        var label = UILabel()
        label.textColor = CustomColors.softAppColor
        label.font = UIFont(name: "Menlo Bold", size: 40)
        addSubview(label)
        return label
    }()

    lazy var atomicMassLabel: UILabel =  {
        var label = UILabel()
        label.textColor = CustomColors.softAppColor
        label.font = UIFont(name: "Hoefler Text", size: 24)
        addSubview(label)
        return label
    }()
    
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
        symbolLabel.textColor = CustomColors.softAppColor
        elementNumberLabel.textColor = CustomColors.softAppColor
        atomicMassLabel.textColor = CustomColors.softAppColor
        backgroundColor = displayItem.color
    }
    
    func setup() {
        layer.cornerRadius = 15

        layout()
    }
    
    func layout() {
        elementNumberLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        atomicMassLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
