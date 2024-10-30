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
    case lessons([String])
    case categoryTest([String])
    case bigGames([String])
    case userStatistic([String])
    
    var items: [String] {
        switch self {
        case .periodicTable(let items),
                .tools(let items),
                .lessons(let items),
                .categoryTest(let items),
                .bigGames(let items),
                .userStatistic(let items):
            return items
        }
    }
    
    var count: Int {
        items.count
    }
    
    var title: String {
        switch self {
        case .periodicTable(_):
            return "Periodic tables 👨🏻‍🏫"
        case .tools(_):
            return "Tools 🛠️"
        case .lessons(_):
            return "Lessons 📜"
        case .categoryTest(_):
            return "Category test 📚"
        case .bigGames(_):
            return "Big games 👑"
        case .userStatistic(_):
            return "User statistic 📊"
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
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1250)
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
        label.text = currentElement?.name
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.textColor = CustomColors.secondaryTextColor
        return label
    }()
    
    private lazy var latinNameLabel: UILabel = {
        var label = UILabel()
        label.text = currentElement?.latinName
        label.font = UIFont(name: "Hoefler Text", size: 20)
        label.textColor = CustomColors.secondaryTextColor
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
        button.backgroundColor = CustomColors.purple
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
        label.textColor = CustomColors.secondaryTextColor
        return label
    }()
    
    private lazy var smallButton: UIButton = {
        var button = UIButton()
        button.setTitle("repeat", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 18)
        button.setTitleColor(CustomColors.secondaryTextColor, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .clear
        button.layer.borderColor = CustomColors.secondaryTextColor.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(Self.showElementInfoViewControllerForRepeating), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        var collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = CustomColors.generalAppPhont
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self

        return collectionView
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
            make.height.equalTo(UIScreen.main.bounds.width * 3)
            make.bottom.equalToSuperview()
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
                                   .lessons(["History", "Terminology", "General knowledge", "Difficult material"]),
                                   .categoryTest(categories),
                                   .bigGames(typeOfQuestions),
                                   .userStatistic(["User"])]

        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseId)
        collectionView.register(PeriodicTableCollectionViewCell.self, forCellWithReuseIdentifier: PeriodicTableCollectionViewCell.reuseId)
        collectionView.register(ToolsCollectionViewCell.self, forCellWithReuseIdentifier: ToolsCollectionViewCell.reuseId)
        collectionView.register(LessonsCollectionViewCell.self, forCellWithReuseIdentifier: LessonsCollectionViewCell.reuseId)
        collectionView.register(BigGameCollectionViewCell.self, forCellWithReuseIdentifier: BigGameCollectionViewCell.reuseId)
        collectionView.register(UserStatisticCollectionViewCell.self, forCellWithReuseIdentifier: UserStatisticCollectionViewCell.reuseId)
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToolsCollectionViewCell.reuseId, for: indexPath) as? ToolsCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configureCell(typeOfTable: tools[indexPath.row], imageName: tools[indexPath.row])
            return cell
        case .lessons(let lessons):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LessonsCollectionViewCell.reuseId, for: indexPath) as? LessonsCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configureCell(lessonName: lessons[indexPath.row])
            return cell
        case .categoryTest(let categories):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseId, for: indexPath) as? CategoryCollectionViewCell
            else {
                return UICollectionViewCell()
            }

            let color = CustomColors.choseColor(categories[indexPath.row])
            cell.configureCell(category: categories[indexPath.row],
                               countOfElements: String(fixedElementList.filter {$0.category == categories[indexPath.row]}.count),
                               color: color,
                               imageName: "book_" + String(indexPath.row))
            return cell
        case .bigGames(let questionTypes):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigGameCollectionViewCell.reuseId, for: indexPath) as? BigGameCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configureCell(typeOfGame: questionTypes[indexPath.row])
            return cell
        case .userStatistic(let statistic):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserStatisticCollectionViewCell.reuseId, for: indexPath) as? UserStatisticCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configureCell(typeOfTable: statistic[indexPath.row])
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
        case .lessons(_):
            vc = LessonViewController()
        case .categoryTest(let categories):
            vc = CategoryTestViewController(fixedElementList: fixedElementList, currentCategory: categories[indexPath.row])
        case .bigGames(let questionTypes):
            vc = BigGameViewController(fixedElementList: fixedElementList, dataSource: dataSource, typeOfGame: QuestionAbout(rawValue: questionTypes[indexPath.row]) ?? QuestionAbout.atomicMassQuestion)
        case .userStatistic(_):
            vc = StatisticViewControler()
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
            case .lessons(_):
                return self.createLessonsSection()
            case .categoryTest(_):
                return self.createCategoryTestSection()
            case .bigGames(_):
                return self.createBigGameSection()
            case .userStatistic(_):
                return self.createUserStatisticSection()
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
                                                            heightDimension: .fractionalHeight(0.9)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.14)),
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

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.08)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .none,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        return section
    }
    
    private func createLessonsSection() -> NSCollectionLayoutSection {        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.49),
                                                            heightDimension: .fractionalHeight(1)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.15)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .groupPaging,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
        return section
    }

    private func createCategoryTestSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.49),
                                                            heightDimension: .fractionalHeight(1)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.15)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .groupPaging,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
        return section
    }

    private func createBigGameSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalHeight(1)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.29), heightDimension: .fractionalHeight(0.12)),
                                                       subitems: [item])

        let section = createLayoutSection(group: group,
                                          behavior: .continuous,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 0, leading: 10, bottom: 20, trailing: 10)
        return section
    }
    
    private func createUserStatisticSection() -> NSCollectionLayoutSection {
        let containerWidth = UIScreen.main.bounds.width

        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(containerWidth/3),
                                                            heightDimension: .absolute(containerWidth/3)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)),
                                                       subitems: [item])
        
        let inset: CGFloat = 10
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: (containerWidth / 3) - inset, bottom: 0, trailing: (containerWidth / 3) - inset)

        let section = createLayoutSection(group: group,
                                          behavior: .none,
                                          interGroupSpacing: 5.0,
                                          supplementaryItems: [supplementaryHeaderItem()])
        section.contentInsets = .init(top: 20, leading: inset, bottom: 0, trailing: inset)
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
    private let parentView: UIView = UIView()
    private let label: UILabel = UILabel()
    private let countLabel: UILabel = UILabel()
    private let infoColor: UIView = UIView()
    private let booksImageView: UIImageView = UIImageView()
    
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
        let corner = 10.0
        parentView.layer.cornerRadius = corner
        parentView.backgroundColor = CustomColors.backgroundForCell
        booksImageView.contentMode = .scaleAspectFit
        booksImageView.clipsToBounds = true
        label.textAlignment = .left
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        infoColor.layer.cornerRadius = parentView.layer.cornerRadius
        countLabel.font = UIFont(name: "Impact", size: 35)
        countLabel.textAlignment = .center
        countLabel.layer.masksToBounds = true
        countLabel.layer.cornerRadius = 25
        countLabel.textColor = CustomColors.generalTextColor
        countLabel.backgroundColor = CustomColors.customWhite
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(infoColor)
        parentView.addSubview(booksImageView)
        parentView.addSubview(label)
        parentView.addSubview(countLabel)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        infoColor.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().dividedBy(5)
            make.width.equalToSuperview()
        }
        
        booksImageView.snp.makeConstraints { make in
            make.bottom.equalTo(infoColor.snp.bottom).offset(-3)
            make.right.equalToSuperview()
            make.height.width.equalToSuperview().multipliedBy(0.6)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalTo(booksImageView.snp.top).offset(2)
        }
        
        countLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.top.greaterThanOrEqualTo(label.snp.bottom).offset(5)
            make.bottom.greaterThanOrEqualTo(infoColor.snp.top).offset(-10)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.greaterThanOrEqualTo(booksImageView.snp.leading)
        }
    }
    
    func configureCell(category: String, countOfElements: String, color: UIColor, imageName: String) {
        label.text = category
        countLabel.text = countOfElements
        infoColor.backgroundColor = color
        booksImageView.image = UIImage(named: imageName) ?? UIImage()
    }
}


private final class PeriodicTableCollectionViewCell: UICollectionViewCell {
    static let reuseId = "PeriodicTableCollectionViewCell"
    let parentView: UIView = UIView()
    let label: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    
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
        parentView.backgroundColor = CustomColors.backgroundForCell
        parentView.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        imageView.contentMode = .scaleAspectFit
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(label)
        parentView.addSubview(imageView)
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
            make.top.equalTo(parentView.snp.top)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.width.equalTo(parentView.snp.width).offset(-10)
            make.bottom.equalTo(parentView.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
        }
    }
    
    func configureCell(typeOfTable: String) {
        label.text = typeOfTable
        imageView.image = UIImage(named: typeOfTable) ?? UIImage()
    }
}

private final class ToolsCollectionViewCell: UICollectionViewCell {
    static let reuseId = "ToolsTableCollectionViewCell"
    let parentView: UIView = UIView()
    let label: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    
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
        parentView.backgroundColor = CustomColors.backgroundForCell
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(label)
        parentView.addSubview(imageView)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        label.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualToSuperview().offset(-5)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(imageView.snp.leading)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
            make.trailing.equalToSuperview()
        }
    }
    
    func configureCell(typeOfTable: String, imageName: String) {
        label.text = typeOfTable
        imageView.image = UIImage(named: imageName)
    }
}

private final class LessonsCollectionViewCell: UICollectionViewCell {
    static let reuseId = "LessonsCollectionViewCell"
    let parentView: UIView = UIView()
    let label: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    
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
        parentView.backgroundColor = CustomColors.backgroundForCell
        parentView.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        imageView.contentMode = .scaleAspectFit
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(label)
        parentView.addSubview(imageView)
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
            make.top.equalTo(parentView.snp.top)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.width.equalTo(parentView.snp.width).offset(-10)
            make.bottom.equalTo(parentView.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
        }
    }
    
    func configureCell(lessonName: String) {
        label.text = lessonName
        imageView.image = UIImage(named: lessonName) ?? UIImage(named: "coin")
    }
}

private final class BigGameCollectionViewCell: UICollectionViewCell {
    static let reuseId = "BigGameCollectionViewCell"
    let parentView: UIView = UIView()
    let label: UILabel = UILabel()
    let secondaryLabel: UILabel = UILabel()
    
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
        parentView.backgroundColor = CustomColors.backgroundForCell
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        secondaryLabel.textAlignment = .center
        secondaryLabel.textColor = CustomColors.generalTextColor
        secondaryLabel.numberOfLines = 1
        secondaryLabel.font = UIFont(name: "Avenir", size: 20)
        secondaryLabel.minimumScaleFactor = 0.5
        secondaryLabel.adjustsFontSizeToFitWidth = true
        secondaryLabel.layer.masksToBounds = true
        secondaryLabel.layer.cornerRadius = 10
        secondaryLabel.backgroundColor = CustomColors.customWhite
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(label)
        parentView.addSubview(secondaryLabel)
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
            make.top.equalToSuperview().offset(15)
        }
        
        secondaryLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-15)
            make.bottom.lessThanOrEqualToSuperview().offset(-5)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func configureCell(typeOfGame: String) {
        label.text = typeOfGame
        
        switch typeOfGame {
        case "latin name":
            secondaryLabel.text = "🔤🏛️"
        case "common name":
            secondaryLabel.text = "🗣️🌎"
        case "atomic mass":
            secondaryLabel.text = "⚛️⚖️"
        case "order number":
            secondaryLabel.text = "🔢"
        case "category":
            secondaryLabel.text = "📚"
        case "density":
            secondaryLabel.text = "💎"
        case "period":
            secondaryLabel.text = "🪫⚡️🔋"
        case "group":
            secondaryLabel.text = "🗂️"
        case "phase":
            secondaryLabel.text = "🧱💧💨"
        case "boiling point":
            secondaryLabel.text = "🔥♨️🔥"
        case "melting point":
            secondaryLabel.text = "🌡️⬆️🫠"
        default:
            secondaryLabel.text = ""
        }
    }
}

private final class UserStatisticCollectionViewCell: UICollectionViewCell {
    static let reuseId = "UserStatisticCollectionViewCell"
    let imageView: UIImageView = UIImageView()
    let userImage: UIImage = UIImage(named: "user_image") ?? UIImage()
    
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
        imageView.contentMode = .scaleToFill
        imageView.image = userImage
        imageView.layer.cornerRadius = (UIScreen.main.bounds.width / 3) / 2
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = CustomColors.backgroundForCell
    }
    
    private func addSubViews() {
        contentView.addSubview(imageView)
    }
    
    private func layout() {
        imageView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    func configureCell(typeOfTable: String) {
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
        label.textColor = CustomColors.secondaryTextColor
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

