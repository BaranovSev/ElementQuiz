//
//  PeriodicTableViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 09.03.2024.
//

import UIKit
import SnapKit

enum PeriodicTableMode: String {
    case short = "short poliatomic"
    case wide = "wide poliatomic"
    case classic = "classic"
    case standard = "standard"
    static var allValues: [String] {
        return [
            short.rawValue,
            wide.rawValue,
            classic.rawValue,
            standard.rawValue
        ]
    }
}

final class PeriodicTableViewController: UIViewController {
    private let dataSource: ElementQuizDataSource
    private let fixedElementList: [ChemicalElementModel]
    private let user: User = DataManager.shared.fetchUser()
    private let stateOfTableMode: PeriodicTableMode
    private let spacing = 3
    private let parametersForMenuButton = [ElementParameters.valency.rawValue,
                                           ElementParameters.density.rawValue,
                                           ElementParameters.oxidationDegree.rawValue,
                                           ElementParameters.boil.rawValue,
                                           ElementParameters.melt.rawValue,
                                           ElementParameters.shells.rawValue,
                                           ElementParameters.block.rawValue,
                                           ElementParameters.electronegativityPauling.rawValue,
                                           ElementParameters.elecrtonAffinity.rawValue,
                                           ElementParameters.phase.rawValue,
                                           ElementParameters.molarHeat.rawValue
    ]

    var optionalPropertiesForCell: ElementParameters = .valency {
        didSet {
            swapPeriodicTable()
            refreshNavigationItemTitle()
        }
    }
    private var scale = 1.0 {
        didSet {
            if scale > 1.7 {
                scale = 1.7
            }
            
            if scale < 0.55 {
                scale = 0.55
            }
        }
    }
    private let sizeOfCell = 100
    private var scaledSizeOfCell: Int {
        Int(Double(sizeOfCell) * scale)
    }

    // MARK: - UI Properties
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: 2000, height: 1200)
        scrollView.backgroundColor = CustomColors.generalAppPhont
        return scrollView
    }()
    
    init(dataSource: ElementQuizDataSource, fixedElementList: [ChemicalElementModel], stateOfTableMode: PeriodicTableMode) {
        self.dataSource = dataSource
        self.fixedElementList = fixedElementList
        self.stateOfTableMode = stateOfTableMode

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
        self.navigationItem.rightBarButtonItem = settingsButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppPhont
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColors.generalTextColor]
        backButton.tintColor = CustomColors.generalTextColor
        settingsButton.tintColor = CustomColors.generalTextColor

        refreshNavigationItemTitle()
        addSubViews()
        layout()
        swapPeriodicTable()
        getScaleParameterForTable()
        getContentOffset()
        getOptionalParameterForState()
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateUserInfo()
    }
    
    private func refreshNavigationItemTitle() {
        self.navigationItem.title = stateOfTableMode.rawValue + " | " + self.optionalPropertiesForCell.descriptionHumanReadable().lowercased()
    }
    
    // MARK: - Private Methods
    private func addCellsOfElements() {
        let listOfElementsForTable = stateOfTableMode != .classic && stateOfTableMode != .standard ? fixedElementList : fixedElementList.dropLast(2)
        for element in listOfElementsForTable {
            lazy var elementIcon: PeriodicTableCellView = {
                let color: UIColor = {
                    switch stateOfTableMode {
                    case .standard:
                        if [1, 6, 7, 8, 15, 16, 34].contains(element.number) {
                            return CustomColors.nonmetal
                        } else if [118].contains(element.number) {
                            return CustomColors.nobleGas
                        } else if [84].contains(element.number) {
                            return CustomColors.metalloid
                        } else if [9, 17, 35, 53, 85, 117].contains(element.number) {
                            return CustomColors.halogen
                        } else if [113, 114, 115, 116].contains(element.number) {
                            return CustomColors.postTransitionMetal
                        } else if [109, 110, 111].contains(element.number) {
                            return CustomColors.transitionMetal
                        } else {
                            return CustomColors.choseColor(element.category)
                        }
                    case .short, .wide:
                        return CustomColors.choseColor(element.category)
                    case .classic:
                        return CustomColors.choseColor(element.block)
                    }
                }()
                let optionalProperty = informationAbout(selected: optionalPropertiesForCell, for: element)
                let elementIcon = PeriodicTableCellView(symbol: element.symbol,
                                                        number: element.number,
                                                        name: element.name,
                                                        atomicMass: element.atomicMass,
                                                        optional: optionalProperty,
                                                        color: color
                )
                
                if scale > 1.0 {
                    elementIcon.optionalLabel.font = UIFont(name: "Menlo", size: 13 * scale * 0.9)
                }
                elementIcon.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                tapGesture.accessibilityValue = element.symbol
                elementIcon.addGestureRecognizer(tapGesture)
                
                elementIcon.accessibilityValue = element.symbol
                
                return elementIcon
            }()
            
            scrollView.addSubview(elementIcon)
            let position = findPositionsFor(cell: elementIcon)
            layoutForCell(view: elementIcon, x: position.0, y: position.1)
        }
    }
    
    private func addEmptyCells() {
        lazy var cellForLantanoides: EmptyCell = {
            let cell = EmptyCell(text: "57-71", category: "lanthanide")
            cell.accessibilityValue = "lanthanide"
            return cell
        }()

        lazy var cellForActinides: EmptyCell = {
            let cell = EmptyCell(text: "89-103", category: "actinide")
            cell.accessibilityValue = "actinide"
            return cell
        }()

        scrollView.addSubview(cellForLantanoides)
        scrollView.addSubview(cellForActinides)
        
        let positionL = findPositionsFor(cell: cellForLantanoides)
        let positionA = findPositionsFor(cell: cellForActinides)
        layoutForCell(view: cellForLantanoides, x: positionL.0, y: positionL.1)
        layoutForCell(view: cellForActinides, x: positionA.0, y: positionA.1)
    }
    
    private func addSubViews() {
        view.addSubview(scrollView)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
    }
    
    private func addDescriptionCell() {
        func returnCell(category: String) -> UIView {
            lazy var cell: UIView = {
                let cell = UIView()
                let infoColor = UIView()
                infoColor.backgroundColor = CustomColors.choseColor(category)
                infoColor.layer.cornerRadius = 4
                let label = UILabel()
                switch category {
                case "s", "p", "d", "f":
                    label.text = category + "-block"
                default :
                    label.text = category
                }
                label.font = UIFont(name: "Menlo", size: 15 * (scale + 0.25))
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                label.textColor = CustomColors.generalTextColor
                label.textAlignment = .left
                cell.addSubview(infoColor)
                cell.addSubview(label)
                
                infoColor.snp.makeConstraints { make in
                    make.leading.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.height.equalTo(15)
                    make.width.equalTo(15)
                }
                
                label.snp.makeConstraints { make in
                    make.leading.equalTo(infoColor.snp.trailing).offset(5)
                    make.centerY.equalToSuperview()
                }
    
                return cell
            }()
            return cell
        }
        
        switch stateOfTableMode {
        case .short, .wide, .standard:
            var categories: Set<String> = []
            for element in fixedElementList {
                categories.insert(element.category)
            }
            
            if stateOfTableMode == .standard {
                categories.remove("diatomic nonmetal")
                categories.remove("polyatomic nonmetal")
                categories.remove("unknown")
                categories.insert("nonmetal")
                categories.insert("halogen")
            }
            
            var x = 1
            var y = 4
            let xx = 8
            var yy = 4
            
            for category in categories.sorted() {
                if category != "actinide" && category != "lanthanide" {
                    let cell = returnCell(category: category)
                    
                    let ypos = x * scaledSizeOfCell + (x - 1) * spacing
                    let xpos = y * scaledSizeOfCell + (y - 1) * spacing
                    
                    if x >= 3 {
                        y += 3
                        x = 1
                    } else {
                        x += 1
                    }
                    
                    scrollView.addSubview(cell)
                    cell.snp.makeConstraints { make in
                        make.height.equalTo(scaledSizeOfCell)
                        make.width.equalTo(Int(Double(scaledSizeOfCell) * 1.5))
                        make.top.equalToSuperview().offset(ypos)
                        make.leading.equalToSuperview().offset(xpos)
                    }
                } else {
                    let cell = returnCell(category: category)
                    let ypos = xx * scaledSizeOfCell + (xx - 1) * spacing
                    let xpos = yy * scaledSizeOfCell + (yy - 1) * spacing
                    
                    yy += 2
                    
                    scrollView.addSubview(cell)
                    cell.snp.makeConstraints { make in
                        make.height.equalTo(scaledSizeOfCell)
                        make.width.equalTo(Int(Double(scaledSizeOfCell) * 1.5))
                        make.top.equalToSuperview().offset(ypos)
                        make.leading.equalToSuperview().offset(xpos)
                    }
                }
            }
        case .classic:
            var elementsBlocks: Set<String> = []
            for element in fixedElementList {
                elementsBlocks.insert(element.block)
            }
            var x = 3
            let y = 1
            for block in elementsBlocks.sorted() {
                let cell = returnCell(category: block)
                let xpos = x * scaledSizeOfCell + (x - 1) * spacing
                let ypos = y * scaledSizeOfCell + (y - 1) * spacing
                
                x += 2
                
                scrollView.addSubview(cell)
                cell.snp.makeConstraints { make in
                    make.height.equalTo(scaledSizeOfCell/2)
                    make.width.equalTo(Int(Double(scaledSizeOfCell) * 1.5))
                    make.top.equalToSuperview().offset(ypos)
                    make.leading.equalToSuperview().offset(xpos)
                }
            }
        }
    }
    
    @objc func backAction() {
        self.dismiss(animated: true)
    }
}

// MARK: - Show another controllers
private extension PeriodicTableViewController {
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let elementSymbol = sender.accessibilityValue {
            let elements = fixedElementList.filter{ $0.symbol == elementSymbol }
            guard let element = elements.first else {
                fatalError("No any elements with that symbol / place PeriodicTableViewController -> @objc func handleTap")
            }
            showElementInfoViewController(element)
        }
    }
    
    func showElementInfoViewController(_ element: ChemicalElementModel) {
        let vc = ElementInfoViewController()
        vc.currentElement = element
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func showSettings() {
        let vc = ParametersButtonViewController (delegate: self, parameters: parametersForMenuButton.sorted())
        self.present(vc, animated: true, completion: nil)
    }
}

private extension PeriodicTableViewController {
    @objc func swapPeriodicTable() {
        scrollView.removeAllSubviews()
        scrollView.zoomAllSubviews(scale: scale)
        resizeScrollViewContentSize()
        addPeriodNumberCell()
        addDescriptionCell()
        addGroupNumberCell()
        addCellsOfElements()

        if stateOfTableMode == .short || stateOfTableMode == .standard {
            addEmptyCells()
        }
    }
}

private extension PeriodicTableViewController {
    func layoutForCell(view: UIView, x: Int , y: Int) {
        if let view = view as? PeriodicTableCellView {
            hideSomeLabels(in: view)
        }
        
        let ypos = y * scaledSizeOfCell + (y - 1) * spacing
        let xpos = x * scaledSizeOfCell + (x - 1) * spacing
        
        view.snp.makeConstraints { make in
            make.height.equalTo(scaledSizeOfCell)
            make.width.equalTo(scaledSizeOfCell)
            make.top.equalToSuperview().offset(ypos)
            make.leading.equalToSuperview().offset(xpos)
        }
    }
    
    func findPositionsFor(cell: UIView) -> (Int, Int){
        var x = 0
        var y = 0
        if let cell = cell as? PeriodicTableCellView, let elementSymbol = cell.accessibilityValue {
            let element = fixedElementList.filter{ $0.symbol == elementSymbol }.first!
            switch stateOfTableMode {
            case .short, .standard:
                x = Int(element.xpos)
                y = Int(element.ypos)
            case .wide:
                x = Int(element.wxpos)
                y = Int(element.wypos)
            case .classic:
                x = Int(element.cxpos)
                y = Int(element.cypos)
            }
            return(x, y)
        } else {
            if let cell = cell as? EmptyCell {
                if cell.accessibilityValue == "lanthanide" {
                    x = 3
                    y = 6
                }
                
                if cell.accessibilityValue == "actinide" {
                    x = 3
                    y = 7
                }
            }
            return (x, y)
        }
    }
    
    func hideSomeLabels(in view: PeriodicTableCellView) {
        let normal = 90
        let small = 73
        let big = 130
        
        if  scaledSizeOfCell <= small {
            view.atomicMassLabel.isHidden = true
            view.nameLabel.isHidden = true
        } else if scaledSizeOfCell >= normal {
            view.atomicMassLabel.isHidden = false
            view.nameLabel.isHidden = false
        } else {
            view.atomicMassLabel.isHidden = false
            view.nameLabel.isHidden = true
        }
        
        if scaledSizeOfCell >= big {
            view.optionalLabel.isHidden = false
        } else {
            view.optionalLabel.isHidden = true
        }
    }
    
    func resizeScrollViewContentSize() {
        switch stateOfTableMode {
        case .short, .standard:
            scrollView.contentSize = CGSize(width: 18 * scaledSizeOfCell + Int(Double(200) * scale) , height: 10 * scaledSizeOfCell + 200)
        case .wide:
            scrollView.contentSize = CGSize(width: 32 * scaledSizeOfCell + Int(Double(200) * scale) + 100 , height: 8 * scaledSizeOfCell + 200)
        case .classic:
            scrollView.contentSize = CGSize(width: 14 * scaledSizeOfCell + Int(Double(200) * scale) , height: 14 * scaledSizeOfCell + 210)
        }
    }
}

private extension PeriodicTableViewController {
    func returnCell(string: String) -> UIView {
        lazy var cell: UIView = {
            let cell = UIView()
            let label = UILabel()
            label.text = string
            label.font = UIFont(name: "Menlo Bold", size: 20 * (scale + 0.25))
            label.adjustsFontSizeToFitWidth = true
            label.textColor = CustomColors.generalTextColor
            label.minimumScaleFactor = 0.5
            label.textAlignment = .center
            cell.addSubview(label)

            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            return cell
        }()
        return cell
    }
    
    private func addPeriodNumberCell() {
        let periodNumbers = stateOfTableMode != .classic && stateOfTableMode != .standard ? Array(1...8) : Array(1...7)
        
        var x = 1
        let y = 0
        
        for number in periodNumbers {
            let cell = returnCell(string: String(number))
            if stateOfTableMode == .classic && (number == 4 || number == 5 || number == 6 || number == 7) {
                let coloredView = UIView()
                coloredView.backgroundColor = CustomColors.backgroundForCell //.lightGray
                coloredView.layer.cornerRadius = 2
                cell.addSubview(coloredView)
                
                coloredView.snp.makeConstraints { make in
                    make.width.equalTo(3)
                    make.height.equalToSuperview()
                    make.trailing.equalToSuperview()
                }
            }
            let ypos = x * scaledSizeOfCell + (x - 1) * spacing
            let xpos = y * scaledSizeOfCell + (y - 1) * spacing
            if stateOfTableMode == .classic && (number == 4 || number == 5 || number == 6 || number == 7) {
                x += 2
            } else {
                x += 1
            }
            scrollView.addSubview(cell)
            cell.snp.makeConstraints { make in
                if stateOfTableMode == .classic && (number == 4 || number == 5 || number == 6 || number == 7) {
                    make.height.equalTo(scaledSizeOfCell * 2)
                } else {
                    make.height.equalTo(scaledSizeOfCell)
                }
                make.width.equalTo(scaledSizeOfCell / 2)
                make.top.equalToSuperview().offset(ypos)
                make.leading.equalToSuperview().offset(xpos)
            }
        }
    }
    
    private func addGroupNumberCell() {
        let x = 0
        var y = 1
        
        switch stateOfTableMode {
        case .short, .standard:
            let groupNumbers = Array(1...18)
            for number in groupNumbers {
                let cell = returnCell(string: String(number))
                let ypos = x * scaledSizeOfCell + (x - 1) * spacing
                let xpos = y * scaledSizeOfCell + (y - 1) * spacing
                y += 1
                scrollView.addSubview(cell)
                cell.snp.makeConstraints { make in
                    make.height.equalTo(scaledSizeOfCell / 2)
                    make.width.equalTo(scaledSizeOfCell)
                    make.top.equalToSuperview().offset(ypos)
                    make.leading.equalToSuperview().offset(xpos)
                }
            }
        case .wide:
            let groupNumbers = Array(1...18)
            for number in groupNumbers {
                let cell = returnCell(string: String(number))
                if number == 3 {
                    let coloredView = UIView()
                    coloredView.backgroundColor = CustomColors.backgroundForCell//.lightGray
                    coloredView.layer.cornerRadius = 2
                    cell.addSubview(coloredView)
                    
                    coloredView.snp.makeConstraints { make in
                        make.height.equalTo(3)
                        make.width.equalToSuperview()
                        make.bottom.equalToSuperview()
                    }
                }
                
                let ypos = x * scaledSizeOfCell + (x - 1) * spacing
                let xpos = y * scaledSizeOfCell + (y - 1) * spacing
                if number == 3 {
                    y += 15
                } else {
                    y += 1
                }
                scrollView.addSubview(cell)
                cell.snp.makeConstraints { make in
                    make.height.equalTo(scaledSizeOfCell / 2)
                    if number == 3 {
                        make.width.equalTo(scaledSizeOfCell * 15 + spacing * 14)
                    } else {
                        make.width.equalTo(scaledSizeOfCell)
                    }
                    make.top.equalToSuperview().offset(ypos)
                    make.leading.equalToSuperview().offset(xpos)
                }
            }
        case .classic:
            let groupRoman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"]
            for number in groupRoman {
                let cell = returnCell(string: number)

                if number == "VIII" {
                    let coloredView = UIView()
                    coloredView.backgroundColor = CustomColors.backgroundForCell//.lightGray
                    coloredView.layer.cornerRadius = 2
                    cell.addSubview(coloredView)
                    
                    coloredView.snp.makeConstraints { make in
                        make.height.equalTo(3)
                        make.width.equalToSuperview()
                        make.bottom.equalToSuperview()
                    }
                }
                let ypos = x * scaledSizeOfCell + (x - 1) * spacing
                let xpos = y * scaledSizeOfCell + (y - 1) * spacing
                y += 1
                scrollView.addSubview(cell)
                cell.snp.makeConstraints { make in
                    make.height.equalTo(scaledSizeOfCell / 2)
                    if number == "VIII" {
                        make.width.equalTo(scaledSizeOfCell * 4)
                    } else {
                        make.width.equalTo(scaledSizeOfCell)
                    }
                    make.top.equalToSuperview().offset(ypos)
                    make.leading.equalToSuperview().offset(xpos)
                }
            }
        }
    }
}

// MARK: - GestureRecognizer
private extension PeriodicTableViewController {
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= Double(gesture.scale)
            swapPeriodicTable()
            
            gesture.scale = 1.0
        }
        
    //TODO: anchor point
    }
}

// MARK: - Helpers UIScrollView
private extension UIScrollView {
    func removeAllSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func zoomAllSubviews(scale: CGFloat) {
        for view in self.subviews {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

extension PeriodicTableViewController {
    private func informationAbout(selected parameter: ElementParameters, for currentElement: ChemicalElementModel) -> String {
        var result = ""
        switch parameter {
        case .atomicMass:
            result = String(currentElement.atomicMass)
        case .density:
            if currentElement.density != -1.0 {
                result = "\(currentElement.density) g/cm3"
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
}

//MARK: - ParametersButtonDelegate
extension PeriodicTableViewController: ParametersButtonDelegate {
    func didChangeParameter(parameter: ElementParameters) {
        self.optionalPropertiesForCell = parameter
    }
}

//MARK: - Work with user data
extension PeriodicTableViewController {
    private func getOptionalParameterForState() {
        switch stateOfTableMode {
        case .wide:
            self.optionalPropertiesForCell = ElementParameters(rawValue: user.wideTableOptionalParameter) ?? .valency
        case .short:
            self.optionalPropertiesForCell = ElementParameters(rawValue: user.shortTableOptionalParameter) ?? .valency
        case .classic:
            self.optionalPropertiesForCell =  ElementParameters(rawValue: user.classicTableOptionalParameter) ?? .valency
        case .standard:
            self.optionalPropertiesForCell =  ElementParameters(rawValue: user.standardTableOptionalParameter) ?? .valency
        }
    }
    
    private func updateUserInfo() {
        switch stateOfTableMode {
        case .wide:
            user.wideTableOptionalParameter = optionalPropertiesForCell.rawValue
            user.wideTableScaleParameter = scale
            user.wideOffsetX = Float(scrollView.contentOffset.x)
            user.wideOffsetY = Float(scrollView.contentOffset.y)
        case .short:
            user.shortTableOptionalParameter = optionalPropertiesForCell.rawValue
            user.shortTableScaleParameter = scale
            user.shortOffsetX = Float(scrollView.contentOffset.x)
            user.shortOffsetY = Float(scrollView.contentOffset.y)
        case .classic:
            user.classicTableOptionalParameter = optionalPropertiesForCell.rawValue
            user.classicTableScaleParameter = scale
            user.classicOffsetX = Float(scrollView.contentOffset.x)
            user.classicOffsetY = Float(scrollView.contentOffset.y)
        case .standard:
            user.standardTableOptionalParameter = optionalPropertiesForCell.rawValue
            user.standardTableScaleParameter = scale
            user.standardOffsetX = Float(scrollView.contentOffset.x)
            user.standardOffsetY = Float(scrollView.contentOffset.y)
        }
        
        DataManager.shared.saveUserData(from: user)
    }
    
    private func getScaleParameterForTable() {
        switch stateOfTableMode {
        case .wide:
            self.scale = user.wideTableScaleParameter
        case .short:
            self.scale = user.shortTableScaleParameter
        case .classic:
            self.scale = user.classicTableScaleParameter
        case .standard:
            self.scale = user.standardTableScaleParameter
        }
    }
    
    private func getContentOffset() {
        func setOffset(x: Float, y: Float) {
            let x = CGFloat(x)
            let y = CGFloat(y)
            self.scrollView.contentOffset.x = x
            self.scrollView.contentOffset.y = y
        }
        
        switch stateOfTableMode {
        case .wide:
            setOffset(x: user.wideOffsetX, y: user.wideOffsetY)
        case .short:
            setOffset(x: user.shortOffsetX, y: user.shortOffsetY)
        case .classic:
            setOffset(x: user.classicOffsetX, y: user.classicOffsetY)
        case .standard:
            setOffset(x: user.standardOffsetX, y: user.standardOffsetY)
        }
    }
}

