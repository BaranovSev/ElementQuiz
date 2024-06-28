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
    var delegate: StartViewController? = nil
    var currentElement: ChemicalElementModel? {
        didSet {
            guard let currentElement = currentElement else { return }
            elementIcon.displayItem = ElementQuizDataSource().elementToDisplayItem(currentElement)
        }
    }
    
    // MARK: - UI Properties
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 4550)
        scrollView.backgroundColor = .white
        scrollView.accessibilityScroll(.down)
        return scrollView
    }()
    
    private lazy var elementIcon: ElementIconView = {
        var elementIcon = ElementIconView(displayItem: dataSource.elementToDisplayItem(currentElement ?? fixedElementList.first!))
        return elementIcon
    }()
    
    private lazy var localizedNameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.textColor = .black
        return label
    }()
    
    private lazy var latinNameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 20)
        label.textColor = .black
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 20)
        return label
    }()
    
    private lazy var groupView: SquareInfoView = {
        return SquareInfoView()
    }()
    
    private lazy var periodView: SquareInfoView = {
        return SquareInfoView()
    }()
    
    private lazy var discoveredByView: BoxViewWithTextView = {
        return BoxViewWithTextView()
    }()
    
    private lazy var namedByView: BoxViewWithTextView = {
        return BoxViewWithTextView()
    }()
    
    private lazy var summaryView: BoxViewWithTextView = {
        return BoxViewWithTextView()
    }()

    private lazy var phaseView: PhaseView = {
        return PhaseView()
    }()
    
    private lazy var appearanceView: BoxViewWithTextView = {
        return BoxViewWithTextView()
    }()
    
    private lazy var atomicMassView: AccentBoxView = {
        return AccentBoxView()
    }()
    
    private lazy var densityView: AccentBoxView = {
        return AccentBoxView()
    }()
    
    private lazy var valencyView: PalleteView = {
        return PalleteView()
    }()
    
    private lazy var oxidationView: PalleteView = {
        return PalleteView()
    }()
    
    private lazy var boilView: TemperatureView = {
        return TemperatureView()
    }()
    
    private lazy var meltView: TemperatureView = {
        return TemperatureView()
    }()
    
    private lazy var molarHeatView: AccentBoxView = {
        return AccentBoxView()
    }()
    
    private lazy var electronConfigurationView: AccentBoxView = {
        return AccentBoxView()
    }()
    
    private lazy var electronConfigurationSemanticView: AccentBoxView = {
        return AccentBoxView()
    }()
    
    private lazy var electronAffinityView: AccentBoxView = {
        return AccentBoxView()
    }()
    
    private lazy var paulingView: AccentBoxView = {
        return AccentBoxView()
    }()
    
    private lazy var shellsView: AccentBoxView = {
        return AccentBoxView()
    }()

    private lazy var electronsView: SquareInfoView = {
        return SquareInfoView()
    }()
    
    private lazy var protonsView: SquareInfoView = {
        return SquareInfoView()
    }()
    
    private lazy var neutronsView: SquareInfoView = {
        return SquareInfoView()
    }()
    
    private lazy var ionizationView: BoxViewWithTextView = {
        return BoxViewWithTextView()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.refresh()
    }
    
    // MARK: - Private Methods
    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(elementIcon)
        scrollView.addSubview(localizedNameLabel)
        scrollView.addSubview(latinNameLabel)
        scrollView.addSubview(categoryLabel)
        scrollView.addSubview(groupView)
        scrollView.addSubview(periodView)
        scrollView.addSubview(discoveredByView)
        scrollView.addSubview(namedByView)
        scrollView.addSubview(summaryView)
        scrollView.addSubview(phaseView)
        scrollView.addSubview(appearanceView)
        scrollView.addSubview(atomicMassView)
        scrollView.addSubview(densityView)
        scrollView.addSubview(valencyView)
        scrollView.addSubview(oxidationView)
        scrollView.addSubview(boilView)
        scrollView.addSubview(meltView)
        scrollView.addSubview(molarHeatView)
        scrollView.addSubview(electronConfigurationView)
        scrollView.addSubview(electronConfigurationSemanticView)
        scrollView.addSubview(electronAffinityView)
        scrollView.addSubview(paulingView)
        scrollView.addSubview(shellsView)
        scrollView.addSubview(electronsView)
        scrollView.addSubview(protonsView)
        scrollView.addSubview(neutronsView)
        scrollView.addSubview(ionizationView)
        scrollView.addSubview(bigButton)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
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
        
        groupView.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(-90)
            make.height.equalTo(90)
            make.width.equalTo(90)
        }
        
        periodView.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(90)
            make.height.equalTo(groupView.snp.height)
            make.width.equalTo(groupView.snp.width)
        }
        
        discoveredByView.snp.makeConstraints { make in
            make.top.equalTo(periodView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.greaterThanOrEqualTo(100)
        }
        
        namedByView.snp.makeConstraints { make in
            make.top.equalTo(discoveredByView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.greaterThanOrEqualTo(100)
        }
        
        summaryView.snp.makeConstraints { make in
            make.top.equalTo(namedByView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(scrollView.snp.width).offset(-20)
            make.height.greaterThanOrEqualTo(250)
        }
                
        phaseView.snp.makeConstraints { make in
            make.top.equalTo(summaryView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(250)
        }
        
        appearanceView.snp.makeConstraints { make in
            make.top.equalTo(phaseView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.greaterThanOrEqualTo(100)
        }

        
        atomicMassView.snp.makeConstraints { make in
            make.top.equalTo(appearanceView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(100)
        }
        
        densityView.snp.makeConstraints { make in
            make.top.equalTo(atomicMassView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
        }
        
        valencyView.snp.makeConstraints { make in
            make.top.equalTo(densityView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.equalTo(phaseView)
        }
        
        oxidationView.snp.makeConstraints { make in
            make.top.equalTo(valencyView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.equalTo(phaseView)
        }
        
        boilView.snp.makeConstraints { make in
            make.top.equalTo(oxidationView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.equalTo(phaseView)
        }
        
        meltView.snp.makeConstraints { make in
            make.top.equalTo(boilView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.equalTo(phaseView)
        }
        
        molarHeatView.snp.makeConstraints { make in
            make.top.equalTo(meltView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
        }
        
        electronConfigurationView.snp.makeConstraints { make in
            make.top.equalTo(molarHeatView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.equalTo(phaseView)
        }
        
        electronConfigurationSemanticView.snp.makeConstraints { make in
            make.top.equalTo(electronConfigurationView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
        }
        
        electronAffinityView.snp.makeConstraints { make in
            make.top.equalTo(electronConfigurationSemanticView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
        }
        
        paulingView.snp.makeConstraints { make in
            make.top.equalTo(electronAffinityView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
        }
        
        shellsView.snp.makeConstraints { make in
            make.top.equalTo(paulingView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
        }
        
        protonsView.snp.makeConstraints { make in
            make.top.equalTo(shellsView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(90)
        }
        
        electronsView.snp.makeConstraints { make in
            make.top.equalTo(protonsView)
            make.trailing.equalTo(protonsView.snp.leading).offset(-15)
            make.height.width.equalTo(protonsView)
        }
        
        neutronsView.snp.makeConstraints { make in
            make.top.equalTo(protonsView)
            make.leading.equalTo(protonsView.snp.trailing).offset(15)
            make.height.width.equalTo(protonsView)
        }
        
        
        ionizationView.snp.makeConstraints { make in
            make.top.equalTo(neutronsView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.greaterThanOrEqualTo(atomicMassView)
        }

        bigButton.snp.makeConstraints { make in
            make.top.equalTo(ionizationView.snp.bottom).offset(40)
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
        showInformation()
    }
    
    func showInformation() {
        guard let currentElement = self.currentElement else { return }
        
        localizedNameLabel.text = currentElement.name
        latinNameLabel.text = "latin: " + currentElement.latinName
        categoryLabel.text = "category: " + currentElement.category
        categoryLabel.textColor = CustomColors.choseColor(currentElement.category)
        
        let group = String(currentElement.group)
        groupView.configure(color: .green.withAlphaComponent(0.2), labelOneText: "Group:", labelTwoText: group)
        
        let period = String(currentElement.period)
        periodView.configure(color: .red.withAlphaComponent(0.2), labelOneText: "Period:", labelTwoText: period)
        
        let phase = currentElement.phase
        phaseView.configure(phase: phase)
        
        let atomicMass = String(currentElement.atomicMass)
        atomicMassView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Atomic mass", infoText: atomicMass)
        
        let density = currentElement.density != -1.0 ? String(currentElement.density) + " g/cm3" : "unknown"
        densityView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Density", infoText: density)
        
        let valency = currentElement.valency
        valencyView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, form: .square, toRoman: true, titleText: "Valency", infoText: valency)
        
        let oxidationDegree = currentElement.oxidationDegree
        oxidationView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, form: .round, toRoman: false, titleText: "Oxidation degree", infoText: oxidationDegree)
        
        var kelvinBoil: String = "- - -"
        var celsiusBoil: String = "- - -"
        var farenheitBoil: String = "- - -"
        if let boilText: String = currentElement.boil  {
            let boil = Float(boilText) != nil ? Float(boilText) : nil
            if let boil = boil {
                kelvinBoil = "\(boilText) K"
                celsiusBoil = String(format: "%.2f", boil - 273.15) + " C"
                farenheitBoil = String(format: "%.2f", boil * 1,8 - 459,67) + " F"
            }
        }
        
        boilView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Boil temperature", labelOneText: kelvinBoil, labelTwoText: celsiusBoil, labelThreeText: farenheitBoil, imageName: "boiling")
        
        var kelvinMelt: String = "- - -"
        var celsiusMelt: String = "- - -"
        var farenheitMelt: String = "- - -"
        if let meltText: String = currentElement.melt  {
            let melt = Float(meltText) != nil ? Float(meltText) : nil
            if let melt = melt {
                kelvinMelt = "\(meltText) K"
                celsiusMelt = String(format: "%.2f", melt - 273.15) + " C"
                farenheitMelt = String(format: "%.2f", melt * 1,8 - 459,67) + " F"
            }
        }
        
        meltView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Melt temperature", labelOneText: kelvinMelt, labelTwoText: celsiusMelt, labelThreeText: farenheitMelt, imageName: "melting")
        

        let molarHeat = currentElement.molarHeat != nil ? String(currentElement.molarHeat!) + " J/(mol·K)" : "unknown"
        molarHeatView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Molar heat capacity", infoText: molarHeat)
        
        let electronConfiguration = currentElement.electronConfiguration
        electronConfigurationView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Electron configuration", infoText: electronConfiguration)
        
        let electronConfigurationSemantic = currentElement.electronConfigurationSemantic
        electronConfigurationSemanticView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Semantic configuration", infoText: electronConfigurationSemantic)
        
        let electronAffinity = currentElement.electronAffinity != nil ? String(currentElement.electronAffinity!) + " kJ/mol" : "- - -"
        electronAffinityView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Electron affinity", infoText: electronAffinity)
        
        let electronegativityPauling = currentElement.electronegativityPauling != nil ? String(currentElement.electronegativityPauling!) : "- - -"
        paulingView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Pauling electronegativity", infoText: electronegativityPauling)
        
        let shells = currentElement.shells.map({ String($0) }).joined(separator: ", ")
        shellsView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Shells", infoText: shells)
        
        let electrons = currentElement.number
        let protons = currentElement.number
        let neutrons = Int16(round(currentElement.atomicMass)) - currentElement.number
        
        electronsView.configure(color: UIColor.blue.withAlphaComponent(0.2), labelOneText: "Electrons", labelTwoText: String(electrons))
        protonsView.configure(color: UIColor.red.withAlphaComponent(0.2), labelOneText: "Protons", labelTwoText: String(protons))
        neutronsView.configure(color: UIColor.orange.withAlphaComponent(0.2), labelOneText: "Neutrons", labelTwoText: String(neutrons))
        
        let ionizationEnergies: [Double] = currentElement.ionizationEnergies
        let ionizationText: String = currentElement.ionizationEnergies.isEmpty != true ? ionizationEnergies.map({ String($0) }).joined(separator: "\n") : "- - -"
        ionizationView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Ionization energies", infoText: ionizationText)
        
        let discoveredBy = currentElement.discoveredBy ?? "- - -"
        discoveredByView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Discovered by", infoText: discoveredBy)
        
        let namedBy = currentElement.namedBy ?? "- - -"
        namedByView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Named by", infoText: namedBy)
        
        let summary = currentElement.summary
        summaryView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Summary", infoText: summary, alignment: .justified)
        
        let appearance = currentElement.appearance ?? "- - -"
        appearanceView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Appearance", infoText: appearance, alignment: appearance != "- - -" ? .justified : .center)
        
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
