//
//  CellForPeriodicTableView.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 09.03.2024.
//

import UIKit
import SnapKit

final class PeriodicTableCellView: UIView {
    lazy var elementNumberLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Menlo", size: 15)
        label.minimumScaleFactor = 0.1
        addSubview(label)
        return label
    }()

    lazy var symbolLabel: UILabel  = {
        var label = UILabel()
        label.font = UIFont(name: "Menlo Bold", size: 30)
        label.minimumScaleFactor = 0.1
        addSubview(label)
        return label
    }()
    
    lazy var nameLabel: UILabel  = {
        var label = UILabel()
        label.font = UIFont(name: "Menlo", size: 15)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        addSubview(label)
        return label
    }()

    lazy var atomicMassLabel: UILabel =  {
        var label = UILabel()
        label.font = UIFont(name: "Menlo", size: 13)
        label.minimumScaleFactor = 0.1
        addSubview(label)
        return label
    }()
    
    lazy var optionalLabel: UILabel =  {
        var label = UILabel()
        label.font = UIFont(name: "Menlo", size: 13)
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 4
        addSubview(label)
        return label
    }()
    
    init(symbol: String, number: Int16, name: String, atomicMass: Double, optional: String, color: UIColor) {
        super.init(frame: .zero)
        symbolLabel.text = symbol
        elementNumberLabel.text = String(number)
        nameLabel.text = name
        atomicMassLabel.text = String(format: "%.3f", atomicMass)
        optionalLabel.text = optional
        backgroundColor = color
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

private extension PeriodicTableCellView {
    func setup() {
        layer.cornerRadius = 3

        layout()
    }
    
    func layout() {
        elementNumberLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(5)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(elementNumberLabel.snp.bottom)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(symbolLabel.snp.bottom)
        }
        
        atomicMassLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        optionalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
    }
}

// MARK: - EmptyCell class
final class EmptyCell: UIView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo Bold", size: 15)
        label.textAlignment = .center
        addSubview(label)
        return label
    }()

    private func layout() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setup() {
        layer.cornerRadius = 3
        layout()
    }
    
    init(text: String, category: String) {
        super.init(frame: .zero)
        self.label.text = text
        self.backgroundColor = CustomColors.choseColor(category)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
