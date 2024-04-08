//
//  SearchViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 03.04.2024.
//

import UIKit
import SnapKit

enum ElementParameters: String {
    case atomicMass = "Atomic mass"
    case density = "Density"
    case category = "Category"
    case latinName = "Latin name"
    case phase = "Phase"
    case valency = "Valency"
    case boilTemperature = "Boil temperature"
    case meltTemperature = "Melt temperature"
    case molarHeat = "Molar heat"
    case group = "Group"
    case period = "Period"
    case elecrtonAffinity = "Electron affinity"
    case electronegativityByPauling = "Elecronegativity by Pauling"
    case oxidationDegree = "Oxidation degree"
    case elecronConfiguration = "Electron configuration"
    case elecronConfigurationSemantic = "Electron configuration (semantic)"
    case shells = "Shells"
    case ionizationEnergies = "Ionization energies"
    case discovered = "Discovered"
    case named = "Named"
    case appearance = "Appearance"
    
    static var allValues: [String] {
        return [
            self.atomicMass.rawValue,
            self.density.rawValue,
            self.category.rawValue,
            self.latinName.rawValue,
            self.phase.rawValue,
            self.valency.rawValue,
            self.boilTemperature.rawValue,
            self.meltTemperature.rawValue,
            self.molarHeat.rawValue,
            self.group.rawValue,
            self.period.rawValue,
            self.elecrtonAffinity.rawValue,
            self.electronegativityByPauling.rawValue,
            self.oxidationDegree.rawValue,
            self.elecronConfiguration.rawValue,
            self.elecronConfigurationSemantic.rawValue,
            self.shells.rawValue,
            self.ionizationEnergies.rawValue,
            self.discovered.rawValue,
            self.named.rawValue,
            self.appearance.rawValue
        ]
    }
}

private enum OrderCases {
    case ascending
    case descending
    case unordered
}

private var chosenElements: Set<String> = []
private let chosenSquareImages = ["square.fill", "square.inset.filled", "square.dashed.inset.filled"]
private let chosenCircleImages = ["circle.fill", "circle.inset.filled", "circle.dashed.inset.filled"]
private let unchosenSquareImages = ["square.dotted", "square.dashed", "square"]
private let unchosenCircleImages = ["circle.dotted", "circle.dashed", "circle"]

final class SearchViewController: UIViewController {
    private let dataSource: ElementQuizDataSource
    private let fixedElementList: [ChemicalElementModel]
    var userSelectedOptionalParameter: ElementParameters = .atomicMass {
        didSet {
            refreshTableView()
            self.navigationItem.title = userSelectedOptionalParameter.rawValue
        }
    }
    private var userSelectedOrder: OrderCases = .unordered {
        didSet {
            self.refreshOrderButton()
            self.refreshTableView()
        }
    }
    
    private lazy var presetsMenu = UIMenu(title: "Clear your table or append to current", children: presetsMenuElements)
    private lazy var presetsMenuElements: [UIMenuElement] = []
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        field.textColor = UIColor.black
        field.textAlignment = .justified
        field.placeholder = "search"
        field.autocorrectionType = .no
        field.keyboardType = .asciiCapable
        return field
    }()
    
    private lazy var presetsMenuButton: UIButton = {
        let setupButton = UIButton()
        setupButton.setTitle("Presets", for: .normal)
        let color = CustomColors.lightPurple
        
        setupButton.setTitleColor(UIColor(cgColor: color), for: .normal)
        setupButton.layer.borderColor = color
        setupButton.backgroundColor = .white

        setupButton.layer.borderWidth = 2
        setupButton.layer.cornerRadius = 4
        setupButton.showsMenuAsPrimaryAction = true
        setupButton.menu = presetsMenu
        setupButton.translatesAutoresizingMaskIntoConstraints = false
        return setupButton
    }()
    
    private lazy var orderButton: UIButton = {
        let button = UIButton()
        let color = CustomColors.lightPurple
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 4
        button.layer.borderColor = color
        button.imageView?.tintColor = UIColor(cgColor: color)
        button.addTarget(self, action: #selector(Self.orderButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var countLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir", size: 20)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor(cgColor: CustomColors.lightPurple)
        switcher.addTarget(self, action: #selector(Self.refreshTableView), for: .touchUpInside)
        return switcher
    }()
    
    // selected chosenElements.count from fixedElementList.count tab to hide show , infoLabel swap to another parameter of elements. enum? search by parameter or all visible text on cell? add sort btn 0-9 9-0 ascendin descending only for value. image name config func
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellForElement.reusableIdentifier)
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(dataSource: ElementQuizDataSource, fixedElementList: [ChemicalElementModel]) {
        self.dataSource = dataSource
        self.fixedElementList = fixedElementList

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(showSettings))
        
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = userSelectedOptionalParameter.rawValue
        self.navigationItem.rightBarButtonItem = settingsButton
        self.navigationController?.navigationBar.backgroundColor = .white
        backButton.tintColor = .black
        settingsButton.tintColor = .black
        view.backgroundColor = .white
        
        setup()
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        view.addSubview(textField)
        view.addSubview(switcher)
        view.addSubview(countLabel)
        view.addSubview(orderButton)
        view.addSubview(presetsMenuButton)
        view.addSubview(tableView)
    }
    
    private func layout() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-15)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        presetsMenuButton.snp.makeConstraints { make in
            make.centerY.equalTo(switcher)
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(35)
            make.width.greaterThanOrEqualTo(70)
        }
        
        orderButton.snp.makeConstraints { make in
            make.centerY.equalTo(switcher)
            make.leading.equalTo(presetsMenuButton.snp.trailing).offset(15)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }
        
        orderButton.imageView?.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-5)
            make.width.equalToSuperview().offset(-5)
        })
        
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(orderButton.snp.trailing).offset(15)
            make.centerY.equalTo(switcher)
            make.trailing.equalTo(switcher.snp.leading).offset(-15)
        }
        
        switcher.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(15)
            make.trailing.equalTo(textField.snp.trailing).offset(-15)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(switcher.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setup() {
        textField.becomeFirstResponder()
        textField.delegate = self
        
        countLabelUpdateText()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configurePresetsMenuButton()
        refreshOrderButton()
    }
    
    private func configurePresetsMenuButton() {
        let categories: [String] = Array(Set(fixedElementList.map({ $0.category }))).sorted()
        let clearAll = UIAction(title: "clear all") { action in
            chosenElements = []
            self.refreshTableView()
        }
        
        presetsMenuElements.append(clearAll)
        
        for category in categories {
            let action = UIAction(title: category) { action in
                let categoryElements = self.fixedElementList.filter { $0.category == category }
                
                categoryElements.forEach { element in
                    chosenElements.insert(element.symbol)
                }
                
                self.refreshTableView()
            }
            
            presetsMenuElements.append(action)
        }
    }
    
    private func refreshOrderButton() {
        switch userSelectedOrder {
        case .ascending:
            orderButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        case .descending:
            orderButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        case .unordered:
            let image = UIImage(systemName: "arrow.left.arrow.right")?.rotate(radians: .pi/2)?.withTintColor(UIColor(cgColor: CustomColors.lightPurple))
            orderButton.setImage(image, for: .normal)
        }
    }
    
    private func countLabelUpdateText() {
        let text = switcher.isOn ? "shown \(chosenElements.count) from \(fixedElementList.count)"  : "shown all \(fixedElementList.count)"
        countLabel.text = text
    }
    
    private func informationAbout(selected parameter: ElementParameters, for currentElement: ChemicalElementModel) -> String {
        var result = ""
        switch parameter {
        case .atomicMass:
            result = String(currentElement.atomicMass)
        case .density:
            if let densityText: String = currentElement.density  {
                result = "\(densityText) g/cm3"
            } else {
                result = "unknown"
            }
        case .category:
            result = currentElement.category
        case .latinName:
            result = currentElement.latinName
        case .phase:
            result = currentElement.phase
        case .valency:
            if currentElement.valency.isEmpty != true {
                var valencyText: [String] = []
                for valency in currentElement.valency {
                    valencyText.append(valency.toRoman())
                }
                
                result = valencyText.joined(separator: ", ")
            } else {
                result = "unknown"
            }
        case .boilTemperature:
            if let boilText: String = currentElement.boil  {
                let boil = Float(boilText) != nil ? Float(boilText) : nil
                if let boil = boil {
                    result += "\(boilText) K / " + String(format: "%.2f", boil - 273.15) + " C"
                }
            } else {
                result = " - - - "
            }
        case .meltTemperature:
            if let meltText: String = currentElement.melt  {
                let melt = Float(meltText) != nil ? Float(meltText) : nil
                if let melt = melt {
                    result += "\(meltText) K / " + String(format: "%.2f", melt - 273.15) + " C"
                }
            } else {
                result = " - - - "
            }
        case .molarHeat:
            if let molarHeatText: String = currentElement.molarHeat  {
                let molarHeat = Float(molarHeatText) != nil ? Float(molarHeatText) : nil
                if let molarHeat = molarHeat {
                    result = "\(molarHeat) J/(mol·K)"
                }
            } else {
                result = " - - - "
            }
        case .group:
            result = String(currentElement.group)
        case .period:
            result = String(currentElement.period)
        case .elecrtonAffinity:
            if let electronAffinityText: String = currentElement.electronAffinity  {
                let electronAffinity = Float(electronAffinityText) != nil ? Float(electronAffinityText) : nil
                if let electronAffinity = electronAffinity {
                    result = "\(electronAffinity) kJ/mol"
                }
            } else {
                result = " - - - "
            }
        case .electronegativityByPauling:
            if let electronegativityPaulingText: String = currentElement.electronegativityPauling  {
                let electronegativityPauling = Float(electronegativityPaulingText) != nil ? Float(electronegativityPaulingText) : nil
                if let electronegativityPauling = electronegativityPauling {
                    result = "\(electronegativityPauling)"
                }
            } else {
                result = " - - - "
            }
        case .oxidationDegree:
            if currentElement.oxidationDegree.isEmpty != true {
                var oxidationText: [String] = []
                for oxidation in currentElement.oxidationDegree {
                    oxidationText.append(String(oxidation))
                }
                
                result = oxidationText.joined(separator: ", ")
            } else {
                result = " - - - "
            }
        case .elecronConfiguration:
            result = currentElement.electronConfiguration
        case .elecronConfigurationSemantic:
            result = currentElement.electronConfigurationSemantic
        case .shells:
            if currentElement.shells.isEmpty != true {
                var shellsText: [String] = []
                for shell in currentElement.shells {
                    shellsText.append(String(shell))
                }
                
                result = shellsText.joined(separator: ", ")
            } else {
                result = "unknown"
            }
        case .ionizationEnergies:
            if currentElement.ionizationEnergies.isEmpty != true {
                var ionizationEnergiesText: [String] = []
                for item in currentElement.ionizationEnergies {
                    ionizationEnergiesText.append(String(item))
                }
                
                result = ionizationEnergiesText.joined(separator: ", ")
            } else {
                result = " - - - "
            }
        case .discovered:
            result = currentElement.discoveredBy ?? " - - - "
        case .named:
            result = currentElement.namedBy ?? " - - - "
        case .appearance:
            result = currentElement.appearance ?? " - - - "
        }
        
        return result
    }
    
    @objc func refreshTableView() {
        countLabelUpdateText()
        tableView.reloadData()
    }
    
    @objc func orderButtonTapped() {
        switch userSelectedOrder {
        case .unordered:
            userSelectedOrder = .ascending
        case .ascending:
            userSelectedOrder = .descending
        case .descending:
            userSelectedOrder = .unordered
        }
    }
    
    @objc func backAction() {
        self.dismiss(animated: true)
    }
    
    @objc func showSettings() {
        let vc = ParametersButtonViewController(delegate: self)
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let text = textField.text {
            print(text)
        }
        
        return true
    }
}

//MARK: - SearchViewController calculated properties aka helpers
extension SearchViewController {
    private var elementListFiltered: [ChemicalElementModel] {
        get {
            switcher.isOn ? fixedElementList.filter{ chosenElements.contains($0.symbol)} : fixedElementList
        }
    }
    
    private var sortedElementsList: [ChemicalElementModel] {
        return elementListFiltered.sorted(by: { a, b in
            
            func customSorting<T: Comparable>(_ a: T, _ b: T) -> Bool {
                var result: Bool = false
                if userSelectedOrder == OrderCases.ascending {
                    result =  a < b
                } else if userSelectedOrder == OrderCases.descending {
                    result = a > b
                }
                return result
            }
            
            switch userSelectedOptionalParameter {
            case .atomicMass:
                return customSorting(a.atomicMass, b.atomicMass)
            case .density:
                return customSorting(Double(a.density ?? "-9999999") ?? 0 , Double(b.density ?? "-9999999") ?? 0)
            case .category:
                return customSorting(a.category, b.category)
            case .latinName:
                return customSorting(a.latinName, b.latinName)
            case .phase:
                return customSorting(a.phase, b.phase)
            case .valency:
                return customSorting(a.valency.count, b.valency.count)
            case .boilTemperature:
                return customSorting(Double(a.boil ?? "-9999999") ?? 0 , Double(b.boil ?? "-9999999") ?? 0)
            case .meltTemperature:
                return customSorting(Double(a.melt ?? "-9999999") ?? 0 , Double(b.melt ?? "-9999999") ?? 0)
            case .molarHeat:
                return customSorting(Double(a.molarHeat ?? "-9999999") ?? 0 , Double(b.molarHeat ?? "-9999999") ?? 0)
            case .group:
                return customSorting(a.group, b.group)
            case .period:
                return customSorting(a.period, b.period)
            case .elecrtonAffinity:
                return customSorting(Double(a.electronAffinity ?? "-9999999") ?? 0 , Double(b.electronAffinity ?? "-9999999") ?? 0)
            case .electronegativityByPauling:
                return customSorting(Double(a.electronegativityPauling ?? "-9999999") ?? 0 , Double(b.electronegativityPauling ?? "-9999999") ?? 0)
            case .oxidationDegree:
                return customSorting(a.oxidationDegree.count, b.oxidationDegree.count)
            case .elecronConfiguration:
                return customSorting(a.electronConfiguration, b.electronConfiguration)
            case .elecronConfigurationSemantic:
                return customSorting(a.electronConfigurationSemantic, b.electronConfigurationSemantic)
            case .shells:
                return customSorting(a.shells.count, b.shells.count)
            case .ionizationEnergies:
                return customSorting(a.ionizationEnergies.count, b.ionizationEnergies.count)
            case .discovered:
                return customSorting(a.discoveredBy ?? "" , b.discoveredBy ?? "")
            case .named:
                return customSorting(a.namedBy ?? "" , b.namedBy ?? "")
            case .appearance:
                return customSorting(a.appearance ?? "" , b.appearance ?? "")
            }
        })
    }
}
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let elementList = userSelectedOrder != .unordered ? sortedElementsList : elementListFiltered
        return elementList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CellForElement(style: .default, reuseIdentifier: CellForElement.reusableIdentifier)
        let elementListFiltered = self.elementListFiltered
        let elementList = userSelectedOrder != .unordered ? sortedElementsList : elementListFiltered

//        TODO: filtering all the elements by info & btn show selected only
        let element = elementList[indexPath.row]
        let info = informationAbout(selected: userSelectedOptionalParameter, for: element)
        let color = CustomColors.choseColor(element.category)
        cell.configure(
            elementNumber: String(element.number),
            symbol: element.symbol,
            name: element.name,
            info: info,
            color: color
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elementListFiltered = self.elementListFiltered
        let elementList = userSelectedOrder != .unordered ? sortedElementsList : elementListFiltered
        let element = elementList[indexPath.row]
        let info = informationAbout(selected: userSelectedOptionalParameter, for: element)
        let vc = UpscaledTextViewController()
        vc.configure(elementName: element.name, parameter: userSelectedOptionalParameter, info: info)
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Cell for element
final class CellForElement: UITableViewCell {
    private let parentView: UIView = UIView()
    private let elementNumberLabel: UILabel = UILabel()
    private let symbolLabel: UILabel = UILabel()
    private let nameLabel: UILabel = UILabel()
    private let infoLabel: UILabel = UILabel()
    private let infoColorView: UIView = UIView()
    private let separateView: UIView = UIView()
    private let button: UIButton = UIButton()
    
    static let reusableIdentifier = "CellForElement"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        selectionStyle = .none
        
        elementNumberLabel.font = UIFont(name: "Avenir", size: 15)
        symbolLabel.font = UIFont(name: "Avenir", size: 40)
        symbolLabel.textAlignment = .center
        
        nameLabel.font = UIFont(name: "Avenir", size: 15)
        nameLabel.textAlignment = .left
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.adjustsFontSizeToFitWidth = true
        
        infoLabel.font = UIFont(name: "Avenir", size: 25)
        infoLabel.minimumScaleFactor = 0.35
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.textAlignment = .justified
        infoLabel.numberOfLines = 6
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(elementNumberLabel)
        parentView.addSubview(symbolLabel)
        parentView.addSubview(nameLabel)
        parentView.addSubview(infoLabel)
        parentView.addSubview(infoColorView)
        parentView.addSubview(separateView)
        parentView.addSubview(button)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        infoColorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(5)
        }
        
        elementNumberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(infoColorView.snp.trailing).offset(10)
            make.height.equalTo(15)
            make.width.equalTo(75)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(elementNumberLabel.snp.bottom)
            make.leading.equalTo(elementNumberLabel)
            make.height.equalTo(40)
            make.width.equalTo(elementNumberLabel)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom)
            make.bottom.equalTo(separateView.snp.top)
            make.leading.equalTo(elementNumberLabel)
            make.height.equalTo(20)
            make.width.equalTo(elementNumberLabel)
        }
        
        separateView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(20)
            make.leading.equalTo(infoColorView.snp.trailing)
            make.height.equalTo(1)
        }
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(45)
            make.height.equalTo(45)
        }
        
        button.imageView?.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-15)
            make.height.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-5)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalTo(elementNumberLabel.snp.trailing).offset(15)
            make.trailing.equalTo(button.snp.leading)
        }
        
    }
    
    func configure(elementNumber: String, symbol: String, name: String, info: String, color: UIColor) {
        elementNumberLabel.text = String(elementNumber)
        symbolLabel.text = symbol
        nameLabel.text = name
        infoLabel.text = info
        infoColorView.backgroundColor = color
        separateView.backgroundColor = color
        //TODO: white or colored
        parentView.backgroundColor = .white //color.withAlphaComponent(0.1)
        
        button.imageView?.tintColor = color
        choseIconForButton(symbol)
        button.addTarget(self, action: #selector(Self.bookmarkButtonTaped), for: .touchUpInside)
    }
    
    private func choseIconForButton(_ elementSymbol: String) {
        let imageName = chosenElements.contains(elementSymbol) ? chosenSquareImages.shuffled().first! : unchosenSquareImages.shuffled().first!
        //circular check boxes
//        let imageName = chosenElements.contains(elementSymbol) ? chosenCircleImages.shuffled().first! : unchosenCircleImages.shuffled().first!
        button.setImage(UIImage(systemName: imageName) ?? UIImage(), for: .normal)
    }
    
    @objc func bookmarkButtonTaped() {
        guard let string = symbolLabel.text else { return }
        if chosenElements.contains(string) {
            chosenElements.remove(string)
        } else {
            chosenElements.insert(string)
        }
        choseIconForButton(string)
    }
    // TODO: Button was tapped change image fill & add/delete to set
}

//MARK: - ParametersButtonViewController
final class ParametersButtonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let parameters = ElementParameters.allValues
    private let delegate: SearchViewController
    private lazy var label: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir", size: 30)
        label.textColor = .black
        label.textAlignment = .justified
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellWithLabel.reusableIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(delegate: SearchViewController) {
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        setup()
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        view.addSubview(label)
        view.addSubview(tableView)
    }
    
    private func layout() {
        label.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(15)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setup() {
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        label.text = "Select parameter to show:"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ElementParameters.allValues.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CellWithLabel(style: .default, reuseIdentifier: CellWithLabel.reusableIdentifier)
        let parameter = parameters[indexPath.row]
        cell.configure(info: parameter)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parameter = parameters[indexPath.row]
        delegate.userSelectedOptionalParameter = ElementParameters(rawValue: parameter) ?? .category
        self.dismiss(animated: true)
    }
}

//MARK: - cell for parameter table view menu controller
final private class CellWithLabel: UITableViewCell {
    private let parentView: UIView = UIView()
    private let infoLabel: UILabel = UILabel()
    static let reusableIdentifier = "CellWithLabel"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        infoLabel.font = UIFont(name: "Avenir", size: 25)
        infoLabel.minimumScaleFactor = 0.35
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.textAlignment = .justified
        infoLabel.numberOfLines = 2
        
        parentView.layer.borderWidth = 2
        parentView.layer.cornerRadius = 4
        parentView.layer.borderColor = CustomColors.lightPurple
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(infoLabel)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(info: String) {
        infoLabel.text = info
    }
}

//MARK: - UpscaledTextViewController
final class UpscaledTextViewController: UIViewController {
    let parameters = ElementParameters.allValues
    private lazy var labelName: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir", size: 35)
        label.textColor = .black
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var labelParameter: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir", size: 30)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        var text = UITextView()
        text.font = UIFont(name: "Avenir", size: 27)
        text.textColor = .black
        text.textAlignment = .justified
        text.isEditable = false
        text.isSelectable = false
        return text
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane") ?? UIImage(), for: .normal)
        button.tintColor = UIColor(cgColor: CustomColors.lightPurple)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(Self.shareAction), for: .touchUpInside)
        button.imageView?.snp.makeConstraints { make in
            make.height.equalToSuperview().offset(-19)
            make.width.equalToSuperview().offset(-15)
            make.center.equalToSuperview()
        }
        return button
    }()
        
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setup()
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        view.addSubview(labelName)
        view.addSubview(labelParameter)
        view.addSubview(descriptionTextView)
        view.addSubview(shareButton)
    }
    
    private func layout() {
        labelName.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-15)
        }
        
        labelParameter.snp.makeConstraints { make in
            make.top.equalTo(labelName.snp.bottom).offset(10)
            make.leading.equalTo(labelName)
            make.trailing.equalTo(labelName)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(labelParameter.snp.bottom).offset(10)
            make.leading.equalTo(labelName)
            make.trailing.equalTo(labelName)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-15)
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
    }
    
    private func setup() {
        view.backgroundColor = .white
    }
    
    func configure(elementName: String, parameter: ElementParameters, info: String) {
        labelName.text = elementName
        labelParameter.text = parameter.rawValue
        descriptionTextView.text = info
    }
    
    @objc private func shareAction() {
        guard let name = labelName.text,
              let parameter = labelParameter.text,
              let description = descriptionTextView.text else {
                  return
              }
        let resultToShare = parameter + " of " + name + ":\n" + description

        let share = UIActivityViewController(
            activityItems: [resultToShare],
            applicationActivities: nil
        )
        share.overrideUserInterfaceStyle = .dark
        present(share, animated: true, completion: nil)
    }
}

