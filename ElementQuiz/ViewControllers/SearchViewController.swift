//
//  SearchViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 03.04.2024.
//

import UIKit
import SnapKit

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
    private let user: User = DataManager.shared.fetchUser()
    var userSelectedOptionalParameter: ElementParameters = .atomicMass {
        didSet {
            refreshTableView()
            self.navigationItem.title = userSelectedOptionalParameter.descriptionHumanReadable()
        }
    }
    private var userSelectedOrder: OrderCases = .unordered {
        didSet {
            self.refreshOrderButton()
            self.refreshTableView()
        }
    }
    
    private func fetchElementsList() -> [ChemicalElementModel] {
        var order: Bool? = nil
        switch userSelectedOrder {
        case .ascending:
            order = true
        case .descending:
            order = false
        case .unordered:
            order = nil
        }
        
        return DataManager.shared.fetchSortedAndFilteredElements(
            defaultlyOrderedBy: .atomicMass,
            userAttribute: userSelectedOptionalParameter,
            isAscending: order,
            searchText: textField.text,
            togglePosition: switcher.isOn == true,
            taggedElements: chosenElements
        )
    }
    
    private lazy var presetsMenu = UIMenu(title: "Clear your table or append to current", children: presetsMenuElements)
    private lazy var presetsMenuElements: [UIMenuElement] = []
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        field.textColor = CustomColors.generalTextColor
        field.textAlignment = .justified
        field.placeholder = " 🔎  search"
        field.setPlaceholderColor(CustomColors.generalTextColor)
        field.autocorrectionType = .no
        field.keyboardType = .asciiCapable
        return field
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")?.rotate(radians: .pi/4)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(Self.clearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var presetsMenuButton: UIButton = {
        let setupButton = UIButton()
        setupButton.setTitle("Presets", for: .normal)
        let color = CustomColors.secondaryTextColor
        
        setupButton.setTitleColor(color, for: .normal)
        setupButton.layer.borderColor = color.cgColor
        setupButton.backgroundColor = CustomColors.generalAppPhont

        setupButton.layer.borderWidth = 2
        setupButton.layer.cornerRadius = 4
        setupButton.showsMenuAsPrimaryAction = true
        setupButton.menu = presetsMenu
        setupButton.translatesAutoresizingMaskIntoConstraints = false
        return setupButton
    }()
    
    private lazy var orderButton: UIButton = {
        let button = UIButton()
        let color = CustomColors.secondaryTextColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 4
        button.layer.borderColor = color.cgColor
        button.imageView?.tintColor = color
        button.addTarget(self, action: #selector(Self.orderButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var countLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir", size: 20)
        label.textColor = CustomColors.generalTextColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = CustomColors.secondaryTextColor
        switcher.addTarget(self, action: #selector(Self.refreshTableView), for: .touchUpInside)
        return switcher
    }()
        
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellForElement.reusableIdentifier)
        tableView.rowHeight = 90
//        tableView.backgroundColor = CustomColors.generalAppPhont
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
        self.navigationItem.title = userSelectedOptionalParameter.descriptionHumanReadable()
        self.navigationItem.rightBarButtonItem = settingsButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppPhont
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColors.generalTextColor]
        backButton.tintColor = CustomColors.generalTextColor
        settingsButton.tintColor = CustomColors.generalTextColor
        view.backgroundColor = CustomColors.generalAppPhont
        
        setup()
        addSubViews()
        layout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateUserInfo()
    }
    
    private func addSubViews() {
        view.addSubview(textField)
        view.addSubview(clearButton)
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
        
        clearButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField)
            make.trailing.equalTo(textField.snp.trailing)
            make.height.equalTo(textField.snp.height)
            make.width.equalTo(textField.snp.height)
        }
        
        clearButton.imageView?.snp.makeConstraints({ make in
            make.center.equalToSuperview()
        })
        
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
        textField.delegate = self
        textField.text = getUserSearchedText()
        
        countLabelUpdateText()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configurePresetsMenuButton()
        refreshOrderButton()
        
        getOptionalParameter()
        getUserSelectedElements()
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
            let image = UIImage(systemName: "arrow.left.arrow.right")?.rotate(radians: .pi/2)?.withTintColor(CustomColors.secondaryTextColor)
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
                result = currentElement.density != -1.0 ? "\(currentElement.density) g/cm3" : "unknown"
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
        case .boil:
            if let boilText: String = currentElement.boil  {
                let boil = Float(boilText) != nil ? Float(boilText) : nil
                if let boil = boil {
                    result += "\(boilText) K / " + String(format: "%.2f", boil - 273.15) + " C"
                }
            } else {
                result = " - - - "
            }
        case .melt:
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
        case .electronegativityPauling:
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
        case .electronConfiguration:
            result = currentElement.electronConfiguration
        case .electronConfigurationSemantic:
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
        case .block:
            result = currentElement.block
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
    
    @objc func clearButtonTapped() {
        textField.text = ""
        refreshTableView()
    }
    
    @objc func showSettings() {
        let vc = ParametersButtonViewController(delegate: self, parameters: ElementParameters.allValues.sorted())
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - ParametersButtonDelegate
extension SearchViewController: ParametersButtonDelegate {
    func didChangeParameter(parameter: ElementParameters) {
        // do not swap
        textField.text = ""
        self.userSelectedOptionalParameter = parameter
    }
}

//MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        refreshTableView()
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Work with user data
extension SearchViewController {
    private func getOptionalParameter() {
        userSelectedOptionalParameter = ElementParameters(rawValue: user.searchTableOptionalParameter) ?? .atomicMass
    }
    
    private func getUserSelectedElements() {
        chosenElements = user.searchTableSelectedElements
    }
    
    private func getUserSearchedText() -> String {
        return user.searchTableSearchedText
    }
    
    private func updateUserInfo() {
        user.searchTableOptionalParameter = userSelectedOptionalParameter.rawValue
        user.searchTableSelectedElements = chosenElements
        user.searchTableSearchedText = textField.text ?? ""
        DataManager.shared.saveUserData(from: user)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchElementsList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CellForElement(style: .default, reuseIdentifier: CellForElement.reusableIdentifier)
        let elementList = fetchElementsList()
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
        let elementList = fetchElementsList()
        let element = elementList[indexPath.row]
        let info = informationAbout(selected: userSelectedOptionalParameter, for: element)
        let vc = UpscaledTextViewController()
        vc.configure(elementName: element.name, parameter: userSelectedOptionalParameter.descriptionHumanReadable(), info: info)
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Cell for element
final private class CellForElement: UITableViewCell {
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
        contentView.backgroundColor = CustomColors.generalAppPhont
        
        elementNumberLabel.font = UIFont(name: "Avenir", size: 15)
        symbolLabel.font = UIFont(name: "Avenir", size: 40)
        symbolLabel.textAlignment = .center
        symbolLabel.textColor = CustomColors.generalTextColor
        
        nameLabel.font = UIFont(name: "Avenir", size: 15)
        nameLabel.textAlignment = .left
        nameLabel.textColor = CustomColors.generalTextColor
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.adjustsFontSizeToFitWidth = true
        
        infoLabel.font = UIFont(name: "Avenir", size: 25)
        infoLabel.minimumScaleFactor = 0.35
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.textAlignment = .left
        infoLabel.textColor = CustomColors.generalTextColor
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
        //MARK: phont of cell
        parentView.backgroundColor = CustomColors.generalAppPhont
        
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
}

//MARK: - UpscaledTextViewController
final class UpscaledTextViewController: UIViewController {
    private lazy var labelName: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir", size: 35)
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var labelParameter: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir", size: 30)
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        var text = UITextView()
        text.font = UIFont(name: "Avenir", size: 27)
        text.textColor = CustomColors.generalTextColor
//        text.textAlignment = .justified
        text.isEditable = false
        text.isSelectable = false
        return text
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane") ?? UIImage(), for: .normal)
        button.tintColor = CustomColors.secondaryTextColor
        button.backgroundColor = CustomColors.generalAppPhont
        button.layer.borderColor = CustomColors.secondaryTextColor.cgColor
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
        shareButton.snp.makeConstraints { make in
            make.bottom.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(labelParameter.snp.bottom).offset(10)
            make.leading.equalTo(labelName)
            make.trailing.equalTo(labelName)
            make.bottom.equalTo(shareButton.snp.top).offset(-5)
        }
        

    }
    
    private func setup() {
        view.backgroundColor = CustomColors.generalAppPhont
        labelName.textColor = CustomColors.generalTextColor
        labelParameter.textColor = CustomColors.generalTextColor
        descriptionTextView.textColor = CustomColors.generalTextColor
        descriptionTextView.backgroundColor = CustomColors.generalAppPhont
    }
    
    func configure(elementName: String, parameter: String, info: String) {
        labelName.text = elementName
        labelParameter.text = parameter
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

extension UITextField {
    func setPlaceholderColor(_ color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
