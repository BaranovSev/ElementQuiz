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
//    private let color = CGColor(red: 0.3, green: 0.25, blue: 0.65, alpha: 0.7)
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
        scrollView.backgroundColor = CustomColors.generalAppPhont
        scrollView.accessibilityScroll(.down)
        return scrollView
    }()
    
    private lazy var elementIcon: ElementIconView = {
        var elementIcon = ElementIconView(displayItem: dataSource.elementToDisplayItem(currentElement ?? fixedElementList.first!))
        return elementIcon
    }()
    
    private lazy var localizedNameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 40)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        return label
    }()
    
    private lazy var latinNameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var groupView: SquareInfoView = {
        return SquareInfoView()
    }()
    
    private lazy var periodView: SquareInfoView = {
        return SquareInfoView()
    }()
    
    private lazy var discoveredByView: HeaderWithText? = {
        return HeaderWithText()
    }()
    
    private lazy var namedByView: HeaderWithText? = nil
    
    private lazy var summaryView: BoxViewWithTextView = {
        return BoxViewWithTextView()
    }()

    private lazy var phaseView: PhaseView = {
        return PhaseView()
    }()
    
    private lazy var appearanceView: HeaderWithText? = nil
    
    private lazy var atomicMassView: HeaderWithText = {
        return HeaderWithText()
    }()
    
    private lazy var densityView: HeaderWithText = {
        return HeaderWithText()
    }()
    
    private lazy var valencyView: PalleteView? = nil
    
    private lazy var oxidationView: PalleteView = {
        return PalleteView()
    }()
    
    private lazy var boilView: TemperatureView? = nil
    
    private lazy var meltView: TemperatureView? = nil
    
    private lazy var molarHeatView: HeaderWithText? = nil
    
    private lazy var electronConfigurationView: HeaderWithText = {
        return HeaderWithText()
    }()
    
    private lazy var electronConfigurationSemanticView: HeaderWithText = {
        return HeaderWithText()
    }()
    
    private lazy var electronAffinityView: HeaderWithText? = nil
    
    private lazy var paulingView: HeaderWithText? = nil
    
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
    
    private lazy var ionizationView: BoxViewWithTextView? = nil
    
    private lazy var bigButton: UIButton = {
        let button = UIButton()
        button.setTitle("Memorize", for: .normal)
        
        button.setTitle("Lets start!", for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        button.backgroundColor = CustomColors.purple
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
        if let discoveredByView = discoveredByView {
            scrollView.addSubview(discoveredByView)
        }
        
        if let appearanceView = appearanceView {
            scrollView.addSubview(appearanceView)
        }
        
        if let namedByView = namedByView {
            scrollView.addSubview(namedByView)
        }
        
        scrollView.addSubview(summaryView)
        scrollView.addSubview(phaseView)
        scrollView.addSubview(atomicMassView)
        scrollView.addSubview(densityView)
        
        if let valencyView = valencyView {
            scrollView.addSubview(valencyView)
        }
        
        scrollView.addSubview(oxidationView)
        
        if let boilView = boilView {
            scrollView.addSubview(boilView)
        }
        
        if let meltView = meltView {
            scrollView.addSubview(meltView)
        }
        
        if let molarHeatView = molarHeatView {
            scrollView.addSubview(molarHeatView)
        }
        
        scrollView.addSubview(electronConfigurationView)
        scrollView.addSubview(electronConfigurationSemanticView)
        
        if let electronAffinityView = electronAffinityView {
            scrollView.addSubview(electronAffinityView)
        }
        
        if let paulingView = paulingView {
            scrollView.addSubview(paulingView)
        }
        scrollView.addSubview(shellsView)
        scrollView.addSubview(electronsView)
        scrollView.addSubview(protonsView)
        scrollView.addSubview(neutronsView)
        
        if let ionizationView = ionizationView {
            scrollView.addSubview(ionizationView)
        }
        
        scrollView.addSubview(bigButton)
    }
    
    private func layout() {
        let standardWidth = UIScreen.main.bounds.width - 20
        var lastView: UIView = periodView
        
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
            make.top.lessThanOrEqualTo(elementIcon.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(standardWidth)
            make.height.greaterThanOrEqualTo(40)
        }

        latinNameLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(localizedNameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(standardWidth)
            make.height.greaterThanOrEqualTo(30)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(latinNameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(standardWidth)
            make.height.greaterThanOrEqualTo(30)
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
        
        summaryView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(standardWidth)
            make.height.greaterThanOrEqualTo(250)
            lastView = summaryView
        }

        if let appearanceView = appearanceView {
            appearanceView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(standardWidth)
                make.height.greaterThanOrEqualTo(100)
                lastView = appearanceView
            }
        }
        
        if let discoveredByView = discoveredByView {
            discoveredByView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(standardWidth)
                make.height.greaterThanOrEqualTo(100)
                lastView = discoveredByView
            }
        }
        
        if let namedByView = namedByView {
            namedByView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(standardWidth)
                make.height.greaterThanOrEqualTo(100)
                lastView = namedByView
            }
        }
                
        phaseView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(standardWidth)
            make.height.equalTo(standardWidth)
            lastView = phaseView
        }
   
        atomicMassView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(standardWidth)
            make.height.equalTo(100)
            lastView = atomicMassView
        }
        
        densityView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
            lastView = densityView
        }
        
        if let valencyView = valencyView {
            valencyView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(phaseView)
                make.height.greaterThanOrEqualTo(100)
                lastView = valencyView
            }
        }

        oxidationView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.greaterThanOrEqualTo(100)
            lastView = oxidationView
        }
        
        if let boilView = boilView {
            boilView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(phaseView)
                make.height.equalTo(phaseView)
                lastView = boilView
            }
        }
        
        if let meltView = meltView {
            meltView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(phaseView)
                make.height.equalTo(phaseView)
                lastView = meltView
            }
        }
        
        if let molarHeatView = molarHeatView {
            molarHeatView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(atomicMassView)
                make.height.equalTo(atomicMassView)
                lastView = molarHeatView
            }
        }
        
        electronConfigurationView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(phaseView)
            make.height.greaterThanOrEqualTo(100) //equalTo(phaseView)
            lastView = electronConfigurationView
        }
        
        electronConfigurationSemanticView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
            lastView = electronConfigurationSemanticView
        }
        
        if let electronAffinityView = electronAffinityView {
            electronAffinityView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(atomicMassView)
                make.height.equalTo(atomicMassView)
                lastView = electronAffinityView
            }
        }
        
        if let paulingView = paulingView {
            paulingView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(atomicMassView)
                make.height.equalTo(atomicMassView)
                lastView = paulingView
            }
        }
        
        shellsView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(atomicMassView)
            make.height.equalTo(atomicMassView)
            lastView = shellsView
        }
        
        protonsView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(30)
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
            lastView = neutronsView
        }
        
        if let ionizationView = ionizationView {
            ionizationView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalTo(phaseView)
                make.height.greaterThanOrEqualTo(atomicMassView)
                lastView = ionizationView
            }
        }


        bigButton.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(200)
        }
    }
}

private extension ElementInfoViewController {
    func setup() {
        view.backgroundColor = CustomColors.generalAppPhont
        showInformation()
    }
    
    func showInformation() {
        guard let currentElement = self.currentElement else { return }
        
        localizedNameLabel.text = currentElement.name
        latinNameLabel.text = "latin: " + currentElement.latinName
        categoryLabel.text = "category: " + currentElement.category
        categoryLabel.textColor = CustomColors.choseColor(currentElement.category)
        
        let group = String(currentElement.group)
        groupView.configure(color: UIColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0), labelOneText: "Group:", labelTwoText: group)
        
        let period = String(currentElement.period)
        periodView.configure(color: UIColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0), labelOneText: "Period:", labelTwoText: period)
        
        let phase = currentElement.phase
        phaseView.configure(phase: phase)
        
        let atomicMass = String(currentElement.atomicMass)
        atomicMassView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Atomic mass", infoText: atomicMass)
        
        let density = currentElement.density != -1.0 ? String(currentElement.density) + " g/cm3" : "unknown"
        densityView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Density", infoText: density)
        
        let valency = currentElement.valency
        if !valency.isEmpty {
            valencyView = PalleteView()
            valencyView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, form: .square, toRoman: true, titleText: "Valency", infoText: valency)
        }
        
        
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
        
        if kelvinBoil != "- - -" {
            boilView = TemperatureView()
            boilView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Boil temperature", labelOneText: kelvinBoil, labelTwoText: celsiusBoil, labelThreeText: farenheitBoil, imageName: "boiling")
        }
        
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
        
        if kelvinMelt != "- - -" {
            meltView = TemperatureView()
            meltView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Melt temperature", labelOneText: kelvinMelt, labelTwoText: celsiusMelt, labelThreeText: farenheitMelt, imageName: "melting")
        }

        

        if let molarHeat = currentElement.molarHeat {
            molarHeatView = HeaderWithText()
            molarHeatView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Molar heat capacity", infoText: String(molarHeat) + " J/(mol·K)")
        }
        
        let electronConfiguration = currentElement.electronConfiguration
        electronConfigurationView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Electron configuration", infoText: electronConfiguration)
        
        let electronConfigurationSemantic = currentElement.electronConfigurationSemantic
        electronConfigurationSemanticView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Semantic configuration", infoText: electronConfigurationSemantic)
        
        if let electronAffinity = currentElement.electronAffinity {
            electronAffinityView = HeaderWithText()
            electronAffinityView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Electron affinity", infoText: String(electronAffinity) + " kJ/mol")
        }
        
        if let electronegativityPauling = currentElement.electronegativityPauling {
            paulingView = HeaderWithText()
            paulingView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Pauling electronegativity", infoText: String(electronegativityPauling))
        }

        
        let shells = currentElement.shells.map({ String($0) }).joined(separator: ", ")
        shellsView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Shells", infoText: shells)
        
        let electrons = currentElement.number
        let protons = currentElement.number
        let neutrons = Int16(round(currentElement.atomicMass)) - currentElement.number
        
        electronsView.configure(color: UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0), labelOneText: "Electrons", labelTwoText: String(electrons))
        protonsView.configure(color: UIColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0), labelOneText: "Protons", labelTwoText: String(protons))
        neutronsView.configure(color: UIColor(red: 1.0, green: 0.9294, blue: 0.8, alpha: 1.0), labelOneText: "Neutrons", labelTwoText: String(neutrons))
        
        let ionizationEnergies: [Double] = currentElement.ionizationEnergies
        if currentElement.ionizationEnergies.isEmpty != true {
            ionizationView = BoxViewWithTextView()
            let ionizationText: String =  ionizationEnergies.map({ String($0) }).joined(separator: "\n")
            ionizationView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Ionization energies", infoText: ionizationText)
        }
        
        if let discoveredBy = currentElement.discoveredBy {
            discoveredByView = HeaderWithText()
            discoveredByView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Discovered by", infoText: discoveredBy, infoIsBold: false)
        }
        
        if let namedBy = currentElement.namedBy {
            namedByView = HeaderWithText()
            namedByView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Named by", infoText: namedBy, infoIsBold: false)
        }
        
        let summary = currentElement.summary
        summaryView.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Summary", infoText: summary, alignment: .justified)
        
        if let appearance = currentElement.appearance {
            appearanceView = HeaderWithText()
            appearanceView?.configure(titleBorderColor: CustomColors.choseColor(currentElement.category).cgColor, borderColor: UIColor.gray.cgColor, titleText: "Appearance", infoText: appearance, alignment: appearance != "- - -" ? .justified : .center, infoIsBold: false)
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
