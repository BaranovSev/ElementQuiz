//
//  ElementInfoViewClasses.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 28.07.2024.
//

import UIKit
import SnapKit

//MARK: - UI classes
class SquareInfoView: UIView {
    private let elementLabelOne: UILabel = UILabel()
    private let elementLabelTwo: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 15
        elementLabelOne.font = UIFont(name: "Hoefler Text", size: 20)
        elementLabelOne.textColor = CustomColors.softAppColor
        elementLabelTwo.font = UIFont(name: "Menlo Bold", size: 35)
        elementLabelTwo.textColor = CustomColors.softAppColor
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        addSubview(elementLabelOne)
        addSubview(elementLabelTwo)
    }
    
    func layout() {
        elementLabelOne.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        elementLabelTwo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(elementLabelOne.snp.bottom).offset(5)
        }
    }
    
    func configure(color: UIColor, labelOneText: String, labelTwoText: String) {
        self.backgroundColor = color
        elementLabelOne.text = labelOneText
        elementLabelTwo.text = labelTwoText
    }
}

class PhaseView: UIView {
    private let label: UILabel = UILabel()
    private let parentView: UIView = UIView()
    private let imageView: UIImageView = UIImageView()
    private let phaseLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        parentView.layer.cornerRadius = 10
        parentView.layer.borderWidth = 2.0
        parentView.layer.borderColor = CustomColors.softAppColor.cgColor
        parentView.backgroundColor = CustomColors.generalAppPhont
        parentView.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = UIFont(name:"Menlo Bold", size: 30)
        label.text = "Phase"
        label.textColor = CustomColors.softAppColor
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        phaseLabel.font = UIFont(name: "Menlo Bold", size: 35)
        phaseLabel.textColor = CustomColors.softAppColor
        phaseLabel.textAlignment = .center
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
    }
    
    private func addSubViews() {
        addSubview(parentView)
        parentView.addSubview(imageView)

        parentView.addSubview(label)
        parentView.addSubview(phaseLabel)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        label.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-10)
            make.height.equalTo(30)
            make.top.equalTo(parentView.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.width.equalTo(parentView.snp.width).offset(-10)
            make.bottom.equalTo(phaseLabel.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        phaseLabel.snp.makeConstraints { make in
            make.width.equalTo(parentView.snp.width).offset(-10)
            make.bottom.equalTo(parentView.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(phase: String) {
        phaseLabel.text = phase.capitalized
        imageView.image = UIImage(named: phase) ?? UIImage()
    }
}

class AccentBoxView: UIView {
    private let titleLabel: UILabel = UILabel()
    private let infoLabel: UILabel = UILabel()
    private let parentView: UIView = UIView()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 15
        titleLabel.font = UIFont(name: "Menlo Bold", size: 30)
//        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textColor = CustomColors.generalTextColor
        titleLabel.textAlignment = .center
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 15
        titleLabel.layer.borderWidth = 2.0
        titleLabel.backgroundColor = CustomColors.generalAppPhont
        infoLabel.font = UIFont(name: "Avenir", size: 20)
        infoLabel.textColor = CustomColors.generalTextColor
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 4
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.minimumScaleFactor = 0.5
        parentView.layer.cornerRadius = 10
        parentView.layer.borderWidth = 2.0
        parentView.layer.masksToBounds = true
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        addSubview(parentView)
        addSubview(titleLabel)
        addSubview(infoLabel)
    }
    
    func layout() {
        titleLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().offset(15)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        parentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp_centerYWithinMargins)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(parentView).offset(titleLabel.bounds.height)
        }
    }
    
    func configure(titleBorderColor: CGColor, borderColor: CGColor, titleText: String, infoText: String) {
        titleLabel.layer.borderColor = titleBorderColor
        parentView.layer.borderColor = borderColor
        titleLabel.text = " " + titleText + " "
        infoLabel.text = infoText
    }
}

class PalleteView: UIView {
    enum Form {
        case round
        case square
    }
    
    private let titleLabel: UILabel = UILabel()
    private var views: [UILabel] = []
    private let parentStack: UIStackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        configureLayer()
        configureTitleLabel()
        configureParentStack()
        
        addSubview(titleLabel)
        addSubview(parentStack)
    }
    
    private func configureLayer() {
        layer.cornerRadius = 15
        layer.borderWidth = 2.0
        backgroundColor = CustomColors.generalAppPhont
    }
    
    private func configureTitleLabel() {
        titleLabel.font = UIFont(name: "Menlo Bold", size: 30)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textColor = CustomColors.generalTextColor
        titleLabel.textAlignment = .center
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 15
        titleLabel.layer.borderWidth = 2.0
        titleLabel.backgroundColor = CustomColors.generalAppPhont
    }
    
    private func configureParentStack() {
        parentStack.axis = .vertical
        parentStack.distribution = .fillProportionally
        parentStack.alignment = .center
        parentStack.spacing = 10
    }
    
    private func createLabels(from intArray: [Int], form: Form, toRoman: Bool) {
        views.forEach { $0.removeFromSuperview() }
        if !intArray.isEmpty {
            views = intArray.map { createLabel(for: $0, form: form, toRoman: toRoman) }
        } else {
            let label = UILabel()
            label.font = UIFont(name: "Avenir", size: 25)
            label.text = "unknown"
            label.textColor = CustomColors.generalTextColor
            label.textAlignment = .center
            parentStack.addArrangedSubview(label)
        }
        
        addSubViews()
        layout()
    }
    
    private func createLabel(for value: Int, form: Form, toRoman: Bool) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 20)
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        label.text = toRoman ? String(value.toRoman()) : String(value)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = (form == .square) ? 2 : 20
//        label.layer.borderWidth = 2.0
//        label.layer.borderColor = CustomColors.secondaryTextColor.cgColor
        if toRoman == false {
            if value == 0 {
                label.backgroundColor = CustomColors.backgroundForCell
            } else if value < 0 {
                label.backgroundColor = CustomColors.redLight
                label.textColor = CustomColors.softAppColor
            } else {
                label.backgroundColor = CustomColors.greenLight
                label.textColor = CustomColors.softAppColor
            }
        } else {
            label.backgroundColor = CustomColors.backgroundForCell
        }
        
        return label
    }
    
    private func addSubViews() {
        let itemsInRow = 3
        var horizontalStack: UIStackView?
        
        for (index, view) in views.enumerated() {
            if index % itemsInRow == 0 {
                horizontalStack = createHorizontalStack()
                parentStack.addArrangedSubview(horizontalStack!)
            }
            
            horizontalStack?.addArrangedSubview(view)
        }
    }
    
    private func createHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }
    
    private func layout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        
        parentStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(25)
        }
        
        views.forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.width.equalTo(40)
            }
        }
    }
    
    func configure(titleBorderColor: CGColor, borderColor: CGColor, form: Form, toRoman: Bool, titleText: String, infoText: [Int]) {
        titleLabel.layer.borderColor = titleBorderColor
        layer.borderColor = borderColor
        titleLabel.text = " " + titleText + " "
        createLabels(from: infoText, form: form, toRoman: toRoman)
    }
}

class TemperatureView: UIView {
    private let parentView: UIView = UIView()
    private let imageView: UIImageView = UIImageView()
    private let verticalStack: UIStackView = UIStackView()
    private let titleLabel: UILabel = UILabel()
    private let labelOne: UILabel = UILabel()
    private let labelTwo: UILabel = UILabel()
    private let labelThree: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        configureParentView()
        configureTitleLabel()
        configureVerticalStack()
        configureInnerLables()
        configureImageView()
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        addSubview(parentView)
        addSubview(titleLabel)
        parentView.addSubview(verticalStack)
        verticalStack.addArrangedSubview(labelOne)
        verticalStack.addArrangedSubview(labelTwo)
        verticalStack.addArrangedSubview(labelThree)
        parentView.addSubview(imageView)
    }
    
    private func configureParentView() {
        parentView.layer.cornerRadius = 10
        parentView.layer.borderWidth = 2.0
        parentView.layer.masksToBounds = true
    }
    
    private func configureTitleLabel() {
        titleLabel.font = UIFont(name: "Menlo Bold", size: 30)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textColor = CustomColors.generalTextColor
        titleLabel.textAlignment = .center
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 15
        titleLabel.layer.borderWidth = 2.0
        titleLabel.backgroundColor = CustomColors.generalAppPhont
    }
    
    private func configureVerticalStack() {
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillProportionally
        verticalStack.alignment = .leading
        verticalStack.spacing = 10
    }
    
    private func configureInnerLables() {
        labelOne.font = UIFont(name: "Avenir", size: 20)
        labelOne.textColor = CustomColors.generalTextColor
        labelOne.textAlignment = .left
        labelOne.adjustsFontSizeToFitWidth = true
        labelOne.minimumScaleFactor = 0.5
        
        labelTwo.font = UIFont(name: "Avenir", size: 20)
        labelTwo.textColor = CustomColors.generalTextColor
        labelTwo.textAlignment = .left
        labelTwo.adjustsFontSizeToFitWidth = true
        labelTwo.minimumScaleFactor = 0.5
        
        labelThree.font = UIFont(name: "Avenir", size: 20)
        labelThree.textColor = CustomColors.generalTextColor
        labelThree.textAlignment = .left
        labelThree.adjustsFontSizeToFitWidth = true
        labelThree.minimumScaleFactor = 0.5
    }
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
    }
        
    private func layout() {
        titleLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        parentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp_centerYWithinMargins)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        verticalStack.snp.makeConstraints { make in
            make.top.equalTo(parentView.snp.top).offset(30)
            make.bottom.equalTo(parentView.snp.bottom)
            make.leading.equalTo(parentView.snp.leading).offset(10)
        }
        
        imageView.snp.makeConstraints { make in
            make.trailing.equalTo(parentView.snp.trailing)
            make.leading.equalTo(verticalStack.snp.trailing)
            make.centerY.equalTo(parentView)
            make.width.height.equalTo(parentView.snp.height).dividedBy(1.5)
        }
    }
    
    func configure(titleBorderColor: CGColor, borderColor: CGColor, titleText: String, labelOneText: String, labelTwoText: String, labelThreeText: String, imageName: String) {
        titleLabel.layer.borderColor = titleBorderColor
        titleLabel.backgroundColor = CustomColors.generalAppPhont
        parentView.layer.borderColor = borderColor
        parentView.backgroundColor = CustomColors.generalAppPhont
        titleLabel.text = " " + titleText + " "
        labelOne.text = labelOneText
        labelTwo.text = labelTwoText
        labelThree.text = labelThreeText
        imageView.image = UIImage(named: imageName)
    }
}

class BoxViewWithTextView: UIView {
    private let titleLabel: UILabel = UILabel()
    private let infoTextView: UITextView = UITextView()
    private let parentView: UIView = UIView()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 15
        titleLabel.font = UIFont(name: "Menlo Bold", size: 30)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textColor = CustomColors.generalTextColor
        titleLabel.textAlignment = .center
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 15
        titleLabel.layer.borderWidth = 2.0
        titleLabel.backgroundColor = CustomColors.generalAppPhont
        infoTextView.font = UIFont(name: "Avenir", size: 20)
        infoTextView.textColor = CustomColors.generalTextColor
        infoTextView.textAlignment = .center
        infoTextView.isScrollEnabled = false
        infoTextView.backgroundColor = .clear
        infoTextView.isEditable = false
        parentView.layer.cornerRadius = 10
        parentView.layer.borderWidth = 2.0
        parentView.layer.masksToBounds = true
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        addSubview(parentView)
        addSubview(titleLabel)
        addSubview(infoTextView)
    }
    
    func layout() {
        titleLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().offset(15)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        parentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp_centerYWithinMargins)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        infoTextView.snp.makeConstraints { make in
            make.top.equalTo(parentView.snp.top).offset(20)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(parentView).offset(titleLabel.bounds.height)
            make.height.lessThanOrEqualTo(parentView.snp.height)
        }
    }
    
    func configure(titleBorderColor: CGColor, borderColor: CGColor, titleText: String, infoText: String, alignment: NSTextAlignment? = nil) {
        titleLabel.layer.borderColor = titleBorderColor
        parentView.layer.borderColor = borderColor
        titleLabel.text = " " + titleText + " "
        infoTextView.text = infoText
        infoTextView.textAlignment = alignment ?? .center
    }
}
