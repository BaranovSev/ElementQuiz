//
//  ElementInfoViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 13.01.2024.
//

import UIKit
import SnapKit

final class ElementInfoViewController: UIViewController {
    // MARK: - Properties
    private var dataSource: ElementQuizDataSource = ElementQuizDataSource()
    private let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private let color = CGColor(red: 0.3, green: 0.25, blue: 0.65, alpha: 0.7)
    var currentElement: ChemicalElementModel? {
        didSet {
            guard let currentElement = currentElement else { return }
            elementIcon.displayItem = ElementQuizDataSource().elementToDisplayItem(currentElement)
            localizedNameLabel.text = currentElement.name
            latinNameLabel.text = "latin: " + currentElement.latinName
            categoryLabel.text = "category: " + currentElement.category
            categoryLabel.textColor = CustomColors.choseColor(currentElement.category)
            
            setTextToDescriptionTextView()
        }
    }
    
    // MARK: - UI Properties
    
    private lazy var elementIcon: ElementIconView = {
        var elementIcon = ElementIconView(displayItem: dataSource.elementToDisplayItem(currentElement ?? fixedElementList.first!))
        return elementIcon
    }()
    
    private lazy var localizedNameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        return label
    }()
    
    private lazy var latinNameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 20)
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 25)
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        var label = UITextView()
        label.font = UIFont(name: "Hoefler Text", size: 20)
        label.textColor = .black
        label.textAlignment = .justified
        label.isEditable = false
        label.isSelectable = false
        return label
    }()

    private lazy var bigButton: UIButton = {
        let button = UIButton()
        button.setTitle("Memorize", for: .normal)
        
        button.setTitle("Lets start!", for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(Self.showElementMemorizingController), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        addSubViews()
        layout()
    }
    
    // MARK: - Private Methods
    private func addSubViews() {
        view.addSubview(elementIcon)
        view.addSubview(localizedNameLabel)
        view.addSubview(latinNameLabel)
        view.addSubview(categoryLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(bigButton)
    }
    
    private func layout() {
        elementIcon.snp.makeConstraints { make in
            make.top.lessThanOrEqualToSuperview().offset(50)
            make.height.equalTo(140)
            make.width.equalTo(140)
            make.centerX.equalToSuperview()
        }

        localizedNameLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(elementIcon.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        latinNameLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(localizedNameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(latinNameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(categoryLabel.snp.bottom).offset(10)
            make.bottom.greaterThanOrEqualTo(bigButton.snp.top).offset(-4)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(Int(UIScreen.main.bounds.height * 0.3))
        }

        bigButton.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(200)
        }
    }
}

private extension ElementInfoViewController {
    func setup() {
        view.backgroundColor = .white
    }
    
    func setTextToDescriptionTextView(){
        guard let currentElement = self.currentElement else { return }
        if let discoveredText = currentElement.discoveredBy {
            descriptionTextView.text += "\nDiscovered by: " + discoveredText + "\n"
        }
        
        if let namedText = currentElement.namedBy {
            descriptionTextView.text += "\nNamed by: " + namedText + "\n"
        }
        
        descriptionTextView.text += "\n" + currentElement.summary + "\n"
        if let appearance = currentElement.appearance {
            descriptionTextView.text += "\n" + "Appearance: " + appearance + "\n"
        }
        
        descriptionTextView.text += "\nAtomic mass: " + String(currentElement.atomicMass) + "\n"
        descriptionTextView.text += "\nPeriod: " + String(currentElement.period) + "\n"
        descriptionTextView.text += "\nGroup: " + String(currentElement.group) + "\n"
        descriptionTextView.text += "\nPhase: " + currentElement.phase + "\n"
        
        if let boilText: String = currentElement.boil  {
            let boil = Float(boilText) != nil ? Float(boilText) : nil
            if let boil = boil {
                descriptionTextView.text += "\nBoil temperature: \(boilText) K / " + String(format: "%.2f", boil - 273.15) + " C" + "\n"
            }
        }
        
        if let meltText: String = currentElement.melt  {
            let melt = Float(meltText) != nil ? Float(meltText) : nil
            if let melt = melt {
                descriptionTextView.text += "\nMelt temperature: \(meltText) K / " + String(format: "%.2f", melt - 273.15) + " C" + "\n"
            }
        }
        
        if currentElement.density != -1.0 {
            descriptionTextView.text += "\nDensity: \(currentElement.density) g/cm3" + "\n"
        } else {
            descriptionTextView.text += "\nDensity: unknown" + "\n"
        }
        
        if let molarHeatText: String = currentElement.molarHeat  {
            let molarHeat = Float(molarHeatText) != nil ? Float(molarHeatText) : nil
            if let molarHeat = molarHeat {
                descriptionTextView.text += "\nMolar heat: \(molarHeat) J/(mol·K)" + "\n"
            }
        }
        
        if currentElement.valency.isEmpty != true {
            descriptionTextView.text += "\nValency: "
            var valencyText: [String] = []
            for valency in currentElement.valency {
                valencyText.append(valency.toRoman())
            }
            
            descriptionTextView.text += valencyText.joined(separator: ", ")
            descriptionTextView.text += "\n"
        }
        
        if currentElement.oxidationDegree.isEmpty != true {
            descriptionTextView.text += "\nOxidation degree: "
            var oxidationText: [String] = []
            for oxidation in currentElement.oxidationDegree {
                oxidationText.append(String(oxidation))
            }
            
            descriptionTextView.text += oxidationText.joined(separator: ", ")
            descriptionTextView.text += "\n"
        }
        
        descriptionTextView.text += "\n" + "Electronic configuration" + "\n"
        descriptionTextView.text += "\n" + currentElement.electronConfiguration + "\n"
        descriptionTextView.text += "\n" + currentElement.electronConfigurationSemantic + "\n"
        if let electronAffinityText: String = currentElement.electronAffinity  {
            let electronAffinity = Float(electronAffinityText) != nil ? Float(electronAffinityText) : nil
            if let electronAffinity = electronAffinity {
                descriptionTextView.text += "\nElectron affinity: \(electronAffinity) kJ/mol" + "\n"
            }
        }
        
        if let electronegativityPaulingText: String = currentElement.electronegativityPauling  {
            let electronegativityPauling = Float(electronegativityPaulingText) != nil ? Float(electronegativityPaulingText) : nil
            if let electronegativityPauling = electronegativityPauling {
                descriptionTextView.text += "\nElectronegativity by Pauling: \(electronegativityPauling)" + "\n"
            }
        }
        
        if currentElement.shells.isEmpty != true {
            descriptionTextView.text += "\nShells: "
            var shellsText: [String] = []
            for shell in currentElement.shells {
                shellsText.append(String(shell))
            }
            
            descriptionTextView.text += shellsText.joined(separator: ", ")
            descriptionTextView.text += "\n"
        }

        if currentElement.ionizationEnergies.isEmpty != true {
            descriptionTextView.text += "\nIonization energies: \n"
            var ionizationEnergiesText: [String] = []
            for item in currentElement.ionizationEnergies {
                ionizationEnergiesText.append(String(item))
            }
            
            descriptionTextView.text += ionizationEnergiesText.joined(separator: ", \n")
            descriptionTextView.text += "\n"
        }
    }
}

private extension ElementInfoViewController {
    @objc func showElementMemorizingController() {
        guard let currentElement = currentElement else { return }
        let vc = ElementMemorizingController(fixedElementList: fixedElementList, currentElement: currentElement)
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
}
