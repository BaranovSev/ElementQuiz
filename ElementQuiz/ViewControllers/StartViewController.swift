//
//  StartViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 24.12.2023.
//

import UIKit
import SnapKit


final class StartViewController: UIViewController {
    // MARK: - Properties
    private var timer: Timer?
    private var dataSource: ElementQuizDataSource = ElementQuizDataSource()
    private let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private let user: User = DataManager.shared.fetchUser()
    private var collectionViewStructure: [[String : [String]]] = []
    private var currentElement: ChemicalElementModel? {
        didSet {
            guard let currentElement = currentElement else { return }
            elementIcon.displayItem = ElementQuizDataSource().elementToDisplayItem(currentElement)
            localizedNameLabel.text = currentElement.name
            
            if currentElement.latinName == currentElement.name {
                latinNameLabel.text = ""
            } else {
                latinNameLabel.text = currentElement.latinName
            }
        }
    }
    
    private var learnedElements: [ChemicalElementModel] {
        get {
            guard let set = user.learnedChemicalElements as? Set<ChemicalElementModel> else {
                return self.fixedElementList
            }
            return Array(set)
        }
    }
    
    private var elementsToLearn: [ChemicalElementModel] {
        fixedElementList.filter {
            !learnedElements.contains($0)
        }
    }
    
    // MARK: - UI Properties
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: 200, height: 1000)
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
        label.text = currentElement?.name
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        return label
    }()
    
    private lazy var latinNameLabel: UILabel = {
        var label = UILabel()
        label.text = currentElement?.latinName
        label.font = UIFont(name: "Hoefler Text", size: 20)
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        return label
    }()

    private lazy var bigButton: UIButton = {
        let button = UIButton()
        if elementsToLearn.count == 0 {
            button.setTitle("Reiterate", for: .normal)

        } else {
            button.setTitle("Learn", for: .normal)
        }
        
        button.setTitle("Lets start!", for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(Self.showElementInfoViewController), for: .touchUpInside)
        return button
    }()
    
    private lazy var horizontalStack: UIStackView = {
        var stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 30
        return stack
    }()
    
    private lazy var smallLabel: UILabel = {
        var label = UILabel()
        label.text = "progress: \(learnedElements.count)/\(fixedElementList.count)"
        label.font = UIFont(name: "Hoefler Text", size: 15)
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        return label
    }()
    
    private lazy var smallButton: UIButton = {
        var button = UIButton()
        button.setTitle("repeat", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 15)
        button.setTitleColor(UIColor(cgColor: CustomColors.lightPurple), for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 100)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        var collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self

        return collectionView
    }()
    
    private lazy var statisticsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person") ?? UIImage(), for: .normal)
        button.tintColor = UIColor(cgColor: CustomColors.lightPurple)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 35
        button.addTarget(self, action: #selector(Self.showStatisticsViewController), for: .touchUpInside)
        button.imageView?.snp.makeConstraints { make in
            make.height.equalToSuperview().offset(-19)
            make.width.equalToSuperview().offset(-15)
            make.center.equalToSuperview()
        }
        return button
    }()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpForCollectionView()
        addSubViews()
        startTimer()
        layout()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Private Methods
    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(elementIcon)
        scrollView.addSubview(localizedNameLabel)
        scrollView.addSubview(latinNameLabel)
        scrollView.addSubview(bigButton)
        scrollView.addSubview(horizontalStack)
        horizontalStack.addSubview(smallLabel)
        horizontalStack.addSubview(smallButton)
        scrollView.addSubview(collectionView)
        view.addSubview(statisticsButton)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }

        elementIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
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

        bigButton.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(latinNameLabel.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(200)
        }

        horizontalStack.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(bigButton.snp.bottom).offset(40)
            make.leading.equalTo(bigButton.snp_leadingMargin).offset(-50)
            make.trailing.equalTo(bigButton.snp_trailingMargin).offset(50)
            make.height.equalTo(30)
        }
        
        smallLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
            make.width.greaterThanOrEqualTo(75)
            make.centerY.equalToSuperview()
        }
        
        smallButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
            make.width.greaterThanOrEqualTo(75)
            make.centerY.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(horizontalStack.snp.bottom).offset(40)
            make.width.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        statisticsButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.height.equalTo(70)
            make.width.equalTo(70)
        }
    }
}

// MARK: - Timer extension
private extension StartViewController {
    func startTimer() {
        runEveryTenSeconds()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(runEveryTenSeconds), userInfo: nil, repeats: true)
    }
    
    @objc func runEveryTenSeconds() {
        currentElement = elementsToLearn.shuffled().first!
    }
}

// MARK: - Show another controllers

private extension StartViewController {
    @objc func showElementInfoViewController() {
        let vc = ElementInfoViewController()
        vc.currentElement = currentElement
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func showStatisticsViewController() {
        let vc = StatisticViewControler()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
}

// MARK: - CollectionView data source protocol
extension StartViewController:  UICollectionViewDataSource, UICollectionViewDelegate {
    private func setUpForCollectionView() {
        let periodicTableStyles = PeriodicTableMode.allValues
        let categories: [String] = Array(Set(fixedElementList.map({ $0.category }))).sorted()
        let typeOfQuestions = QuestionAbout.allValues
        collectionViewStructure = [
            ["Periodic table" : periodicTableStyles],
            ["Tools" : ["Search table"]],
            ["Category tests" : categories],
            ["Big games" : typeOfQuestions]
        ]
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.register(PeriodicTableCollectionViewCell.self, forCellWithReuseIdentifier: "PeriodicTableCollectionViewCell")
        collectionView.register(BigGameCollectionViewCell.self, forCellWithReuseIdentifier: "BigGameCollectionViewCell")
        collectionView.register(CustomHeaderView.self, forSupplementaryViewOfKind: 	UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CustomHeaderView")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfSections = collectionViewStructure.count
        
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = collectionViewStructure[section].values.joined().count
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = collectionViewStructure[indexPath.section].keys.joined()
        let values = collectionViewStructure[indexPath.section].values.flatMap { $0 }
        let index = indexPath.row
        let string = values[index]

        var cell: UICollectionViewCell = UICollectionViewCell()
            
        if indexPath.section == 0 {
            let periodicCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeriodicTableCollectionViewCell", for: indexPath) as! PeriodicTableCollectionViewCell
            periodicCell.configureCell(typeOfTable: string)
            cell = periodicCell
        } else if indexPath.section == 1 {
            //This is an ordinary cell with single label at the center
            let periodicCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeriodicTableCollectionViewCell", for: indexPath) as! PeriodicTableCollectionViewCell
            periodicCell.configureCell(typeOfTable: string)
            cell = periodicCell
        } else if indexPath.section == 2 {
            let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            let color = CustomColors.choseColor(string)
            categoryCell.configureCell(category: string, color: color)
            categoryCell.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            cell = categoryCell
        } else if indexPath.section == 3 {
            let bigGameCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BigGameCollectionViewCell", for: indexPath) as! BigGameCollectionViewCell
            bigGameCell.configureCell(typeOfGame: string)
            cell = bigGameCell
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = collectionViewStructure[indexPath.section].keys.joined()
        let values = collectionViewStructure[indexPath.section].values.flatMap { $0 }
        let index = indexPath.row
        let string = values[index]

        var vc: UIViewController = UIViewController()
        
        if indexPath.section == 0 {
            vc = PeriodicTableViewController(dataSource: dataSource, fixedElementList: fixedElementList, stateOfTableMode: PeriodicTableMode(rawValue: string) ?? PeriodicTableMode.classic)
        } else if indexPath.section == 1 {
            vc = SearchViewController(dataSource: dataSource, fixedElementList: fixedElementList)
        } else if indexPath.section == 2 {
            vc = CategoryTestViewController(fixedElementList: fixedElementList, currentCategory: string)
        } else if indexPath.section == 3 {
            vc = BigGameViewController(fixedElementList: fixedElementList, dataSource: dataSource, typeOfGame: QuestionAbout(rawValue: string) ?? QuestionAbout.atomicMassQuestion)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var header = UICollectionReusableView()
        let section = collectionViewStructure[indexPath.section].keys.joined()

        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CustomHeaderView", for: indexPath) as! CustomHeaderView
            headerView.configureHeadetText(text: section)
            
            header = headerView
        }
        return header
    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: 100, height: 100) 
//    }
}

private final class CategoryCollectionViewCell: UICollectionViewCell {
    let parentView: UIView = UIView()
    let label: UILabel = UILabel()
    let infoColor: UIView = UIView()
    
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
        parentView.layer.borderColor = CustomColors.lightPurple
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        infoColor.layer.cornerRadius = 4
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(label)
        parentView.addSubview(infoColor)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        infoColor.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(15)
            make.width.equalTo(15)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(infoColor.snp.bottom).offset(5)
            make.width.equalToSuperview().offset(-15)
            make.bottom.lessThanOrEqualToSuperview().offset(-5)
            make.centerX.equalToSuperview()
        }
    }
    
    func configureCell(category: String, color: UIColor) {
        label.text = category
        infoColor.backgroundColor = color
    }
}


private final class PeriodicTableCollectionViewCell: UICollectionViewCell {
    let parentView: UIView = UIView()
    let label: UILabel = UILabel()
    
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
        parentView.layer.borderColor = CustomColors.lightPurple
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(label)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        label.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-15)
            make.bottom.lessThanOrEqualToSuperview().offset(-5)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func configureCell(typeOfTable: String) {
        label.text = typeOfTable
    }
}

private final class BigGameCollectionViewCell: UICollectionViewCell {
    let parentView: UIView = UIView()
    let label: UILabel = UILabel()
    
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
        parentView.layer.borderColor = CustomColors.lightPurple
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(label)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        label.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-15)
            make.bottom.lessThanOrEqualToSuperview().offset(-5)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func configureCell(typeOfGame: String) {
        label.text = typeOfGame
    }
}

private final class CustomHeaderView: UICollectionReusableView {
    let label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 30)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
    }
    
    private func layout() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
    }
    
    func configureHeadetText(text: String) {
        label.text = text
    }
}

