//
//  StartViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 24.12.2023.
//

import UIKit
import SnapKit


final class StartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - Properties
    private var timer: Timer?
    private var dataSource: ElementQuizDataSource = ElementQuizDataSource()
    private let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private let user: User = DataManager.shared.fetchUser()
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
    
    private lazy var collectionOfTools: UICollectionView = {
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

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
        scrollView.addSubview(collectionOfTools)
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
        
        collectionOfTools.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(horizontalStack.snp.bottom).offset(40)
            make.width.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(150)
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
}

// MARK: - CollectionView data source protocol
extension StartViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categories: [String] = Array(Set(fixedElementList.map({ $0.category })))
        let count = categories.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categories: [String] = Array(Set(fixedElementList.map({ $0.category }))).sorted()
        let string = categories[indexPath.row]
        let color = CustomColors.choseColor(string)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.layer.backgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        let parentView = UIView()
        parentView.layer.cornerRadius = 10
        parentView.layer.borderWidth = 2.0
        parentView.layer.borderColor = CustomColors.lightPurple
        
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = UIFont(name: "Avenir", size: 20)
        label.minimumScaleFactor = 0.5
        label.text = String(categories[indexPath.row])
        label.textColor = .black
        
        let infoColor = UIView()
        infoColor.backgroundColor = color
        infoColor.layer.cornerRadius = 4
        
        cell.addSubview(parentView)
        parentView.addSubview(label)
        parentView.addSubview(infoColor)
        
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categories: [String] = Array(Set(fixedElementList.map({ $0.category }))).sorted()
        let string = categories[indexPath.row]
        let vc = CategoryTestViewController(fixedElementList: fixedElementList, currentCategory: string)
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }

}
