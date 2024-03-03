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
    private var userDataSource: UserStatisticDataSource = UserStatisticDataSource()
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
    
    private lazy var userStatisticProgress: CircleProgressBar = {
        let circleProgressBar = CircleProgressBar(displayItem: userDataSource.infoToDisplayItem(learned: learnedElements, total: fixedElementList))
            return circleProgressBar
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
        scrollView.addSubview(userStatisticProgress)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        
        userStatisticProgress.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(horizontalStack.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(410*userStatisticProgress.sizeIncrement)
            make.width.equalTo(410*userStatisticProgress.sizeIncrement)
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

