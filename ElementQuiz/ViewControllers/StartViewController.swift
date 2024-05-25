//
//  StartViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 24.12.2023.
//

import UIKit
import SnapKit

private enum CollectionSections {
    case periodicTable([String])
    case tools([String])
    case categoryTest([String])
    case bigGames([String])
    
    var items: [String] {
        switch self {
        case .periodicTable(let items),
                .tools(let items),
                .categoryTest(let items),
                .bigGames(let items):
            return items
        }
    }
    
    var count: Int {
        items.count
    }
    
    var title: String {
        switch self {
        case .periodicTable(_):
            return "Periodic tables 🧑🏼‍🔬"
        case .tools(_):
            return "Tools 🛠️"
        case .categoryTest(_):
            return "Category test 📚"
        case .bigGames(_):
            return "Big games 👑"
        }
    }
}

final class StartViewController: UIViewController {
    // MARK: - Properties
    private var timer: Timer?
    private var dataSource: ElementQuizDataSource = ElementQuizDataSource()
    private let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private let user: User = DataManager.shared.fetchUser()
    private var collectionViewStructure: [CollectionSections] = []
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
        DataManager.shared.fetchLearnedElements()
    }
    
    private var elementsToLearn: [ChemicalElementModel] {
        DataManager.shared.fetchElementsToLearn()
    }
    
    // MARK: - UI Properties
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: 200, height: 1250)
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
        label.font = UIFont(name: "Hoefler Text", size: 18)
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        return label
    }()
    
    private lazy var smallButton: UIButton = {
        var button = UIButton()
        button.setTitle("repeat", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 18)
        button.setTitleColor(UIColor(cgColor: CustomColors.lightPurple), for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(Self.showElementInfoViewControllerForRepeating), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        var collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
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
        addSubViews()
        startTimer()
        layout()
        setUpForCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
    }
    
    func refresh() {
        smallLabel.text = "progress: \(learnedElements.count)/\(fixedElementList.count)"
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
            make.top.lessThanOrEqualTo(bigButton.snp.bottom).offset(25)
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
            make.top.lessThanOrEqualTo(horizontalStack.snp.bottom).offset(25)
            make.width.equalToSuperview()
            make.height.equalToSuperview()
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
        if let element = elementsToLearn.shuffled().first {
            currentElement = element
        } else {
            currentElement = learnedElements.shuffled().first!
            bigButton.setTitle("Repeat", for: .normal)
        }
    }
}

// MARK: - Show another controllers

private extension StartViewController {
    @objc func showElementInfoViewController() {
        let vc = ElementInfoViewController()
        vc.currentElement = currentElement
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func showStatisticsViewController() {
        let vc = StatisticViewControler()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    @objc func showElementInfoViewControllerForRepeating() {
        if user.learnedChemicalElements.count != 0 {
            let vc = ElementInfoViewController()
            vc.currentElement = DataManager.shared.fetchElementToRepeat()
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - CollectionView data source protocol
extension StartViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    private func setUpForCollectionView() {
        let periodicTableStyles = PeriodicTableMode.allValues
        let categories: [String] = Array(Set(fixedElementList.map({ $0.category }))).sorted()
        let typeOfQuestions = QuestionAbout.allValues
        collectionViewStructure = [.periodicTable(periodicTableStyles),
                                   .tools(["Search table"]),
                                   .categoryTest(categories),
                                   .bigGames(typeOfQuestions)]

        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseId)
        collectionView.register(PeriodicTableCollectionViewCell.self, forCellWithReuseIdentifier: PeriodicTableCollectionViewCell.reuseId)
        collectionView.register(BigGameCollectionViewCell.self, forCellWithReuseIdentifier: BigGameCollectionViewCell.reuseId)
        collectionView.register(CustomHeaderView.self, forSupplementaryViewOfKind:     UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomHeaderView.reuseId)

        collectionView.collectionViewLayout = createLayoutForCollectionView()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionViewStructure.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewStructure[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionViewStructure[indexPath.section] {
        case .periodicTable(let types):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeriodicTableCollectionViewCell.reuseId, for: indexPath) as? PeriodicTableCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configureCell(typeOfTable: types[indexPath.row])
            return cell
        case .tools(let tools):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeriodicTableCollectionViewCell.reuseId, for: indexPath) as? PeriodicTableCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configureCell(typeOfTable: tools[indexPath.row])
            return cell
        case .categoryTest(let categories):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseId, for: indexPath) as? CategoryCollectionViewCell
            else {
                return UICollectionViewCell()
            }

            let color = CustomColors.choseColor(categories[indexPath.row])
            cell.configureCell(category: categories[indexPath.row], color: color)
            return cell
        case .bigGames(let questionTypes):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigGameCollectionViewCell.reuseId, for: indexPath) as? BigGameCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configureCell(typeOfGame: questionTypes[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var vc: UIViewController = UIViewController()
        
        switch collectionViewStructure[indexPath.section] {
        case .periodicTable(let types):
            vc = PeriodicTableViewController(dataSource: dataSource, fixedElementList: fixedElementList, stateOfTableMode: PeriodicTableMode(rawValue: types[indexPath.row]) ?? PeriodicTableMode.classic)
        case .tools(_):
            vc = SearchViewController(dataSource: dataSource, fixedElementList: fixedElementList)
        case .categoryTest(let categories):
            vc = CategoryTestViewController(fixedElementList: fixedElementList, currentCategory: categories[indexPath.row])
        case .bigGames(let questionTypes):
            vc = BigGameViewController(fixedElementList: fixedElementList, dataSource: dataSource, typeOfGame: QuestionAbout(rawValue: questionTypes[indexPath.row]) ?? QuestionAbout.atomicMassQuestion)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: CustomHeaderView.reuseId,
                                                                         for: indexPath) as! CustomHeaderView

            header.configure(text: collectionViewStructure[indexPath.section].title)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

//MARK: - Compositional layout for collectionView
extension StartViewController {
    private func createLayoutForCollectionView() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            let section = self.collectionViewStructure[sectionIndex]

            switch section {
            case .periodicTable(_):
                return self.createPeriodicTableSection()
            case .tools(_):
                return self.createToolsSection()
            case .categoryTest(_):
                return self.createCategoryTestSection()
            case .bigGames(_):
                return self.createBigGameSection()
            }
        }
    }

    private func createLayoutSection(group: NSCollectionLayoutGroup,
                                behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
                                interGroupSpacing: CGFloat,
                                supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = behavior
        section.interGroupSpacing = interGroupSpacing
        section.boundarySupplementaryItems = supplementaryItems
        return section
    }

    private func createPeriodicTableSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.49),
                                                            heightDimension: .fractionalHeight(1)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.18)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .groupPaging,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
        return section
    }

    private func createToolsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.99),
                                                            heightDimension: .fractionalHeight(1)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.1)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .none,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        return section
    }

    private func createCategoryTestSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.32),
                                                            heightDimension: .fractionalHeight(1)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.18)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .groupPaging,
                                          interGroupSpacing: 0.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        return section
    }

    private func createBigGameSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalHeight(1)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(0.15)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .continuous,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        return section
    }

    private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(30.0)),
              elementKind: UICollectionView.elementKindSectionHeader,
              alignment: .top)
    }
}

//MARK: - Cells
private final class CategoryCollectionViewCell: UICollectionViewCell {
    static let reuseId = "CategoryCollectionViewCell"
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
        label.textColor = .black
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
    static let reuseId = "PeriodicTableCollectionViewCell"
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
        label.textColor = .black
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 30)
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
    static let reuseId = "BigGameCollectionViewCell"
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
        label.textColor = .black
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
    static let reuseId = "CustomHeaderView"
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
        label.textAlignment = .left
        label.numberOfLines = 3
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
    }
    
    private func addSubViews() {
        addSubview(label)
    }
    
    private func layout() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
    }
    
    func configure(text: String) {
        label.text = text
    }
}

