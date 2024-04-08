//
//  StatisticsViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 19.03.2024.
//

import UIKit
import SnapKit

final class StatisticViewControler: UIViewController {
    //TODO: pass this properties from StartVC in init
    private let userDataSource: UserStatisticDataSource = UserStatisticDataSource()
    private let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private let user: User = DataManager.shared.fetchUser()
    private var learnedElements: [ChemicalElementModel] {
        get {
            guard let set = user.learnedChemicalElements as? Set<ChemicalElementModel> else {
                return self.fixedElementList
            }
            return Array(set)
        }
    }
    
    // MARK: - UI Properties
    private var categoriesViews: [UIView] = []
    private lazy var youLearnedLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 50)
        label.textColor = .black
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var countOfLearnedElementsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 75)
        label.textAlignment = .center
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        return label
    }()
    
    private lazy var chemicalElementsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 50)
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: 200, height: 1000)
        scrollView.backgroundColor = .white
        scrollView.accessibilityScroll(.down)
        return scrollView
    }()
    
    private lazy var userStatisticProgress: CircleProgressBar = {
        let circleProgressBar = CircleProgressBar(displayItem: userDataSource.infoToDisplayItem(learned: learnedElements, total: fixedElementList))
        return circleProgressBar
    }()
    
    private lazy var totallyPassedLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.textColor = .black
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var countOfMemorizingsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 55)
        label.textAlignment = .center
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        return label
    }()
    
    private lazy var memorizingLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    //with more than N questions
    
    private lazy var inAdditionLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.textColor = .black
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var countOfBigGamesLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 55)
        label.textAlignment = .center
        label.textColor = UIColor(cgColor: CustomColors.lightPurple)
        return label
    }()
    
    private lazy var bigGamesWinsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
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
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.backgroundColor = .white
        backButton.tintColor = .black
        
        setup()
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(youLearnedLabel)
        scrollView.addSubview(countOfLearnedElementsLabel)
        scrollView.addSubview(chemicalElementsLabel)
        scrollView.addSubview(userStatisticProgress)
        for view in categoriesViews {
            scrollView.addSubview(view)
        }
        
        scrollView.addSubview(totallyPassedLabel)
        scrollView.addSubview(countOfMemorizingsLabel)
        scrollView.addSubview(memorizingLabel)
        scrollView.addSubview(inAdditionLabel)
        scrollView.addSubview(countOfBigGamesLabel)
        scrollView.addSubview(bigGamesWinsLabel)
        scrollView.addSubview(shareButton)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        
        youLearnedLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(25)
            make.centerX.equalToSuperview()
        }
        
        countOfLearnedElementsLabel.snp.makeConstraints { make in
            make.top.equalTo(youLearnedLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        chemicalElementsLabel.snp.makeConstraints { make in
            make.top.equalTo(countOfLearnedElementsLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-15)
        }
        
        userStatisticProgress.snp.makeConstraints { make in
            make.top.equalTo(chemicalElementsLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(410*userStatisticProgress.sizeIncrement)
            make.width.equalTo(410*userStatisticProgress.sizeIncrement)
        }
        
        var previousElement: UIView = userStatisticProgress
        
        for view in categoriesViews {
            view.snp.makeConstraints { make in
                make.top.equalTo(previousElement.snp.bottom).offset(25)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-30)
            }
            previousElement = view
        }
        
        totallyPassedLabel.snp.makeConstraints { make in
            make.top.equalTo(previousElement.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
        }
        
        countOfMemorizingsLabel.snp.makeConstraints { make in
            make.top.equalTo(totallyPassedLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        memorizingLabel.snp.makeConstraints { make in
            make.top.equalTo(countOfMemorizingsLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        inAdditionLabel.snp.makeConstraints { make in
            make.top.equalTo(memorizingLabel.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
        }
        
        countOfBigGamesLabel.snp.makeConstraints { make in
            make.top.equalTo(inAdditionLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        bigGamesWinsLabel.snp.makeConstraints { make in
            make.top.equalTo(countOfBigGamesLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(bigGamesWinsLabel.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
    }
    
    private func setup() {
        youLearnedLabel.text = "You learned"
        countOfLearnedElementsLabel.text = String(learnedElements.count)
        chemicalElementsLabel.text = learnedElements.count != 1 ? "chemical elements" : "chemical element"
        
        addDescriptionCell()
        
        totallyPassedLabel.text = "Totally passed"
        // TODO: counOfMemorizings change to real
        let counOfMemorizings = 10
        countOfMemorizingsLabel.text = String(counOfMemorizings)
        memorizingLabel.text = counOfMemorizings != 1 ? "memorizings" : "memorizing"
        
        inAdditionLabel.text = "In addition with"
        // TODO: counOfBigGames change to real
        let countOfBigGames = 10
        countOfBigGamesLabel.text = String(countOfBigGames)
        bigGamesWinsLabel.text = countOfBigGames != 1 ? "big games wins" : "big game wins"
    }
    
    private func addDescriptionCell() {
        var categories = Set<String>()
        for element in fixedElementList {
            categories.insert(element.category)
        }
        
        for category in Array(categories).sorted() {
            returnCell(category: category)
        }
        
        func returnCell(category: String) {
            lazy var cell: UIView = {
                let cell = UIView()
                let infoColor = UIView()
                infoColor.backgroundColor = CustomColors.choseColor(category)
                infoColor.layer.cornerRadius = 4
                let label = UILabel()
                let learnedElementsFromCategory = learnedElements.filter {$0.category == category}.count
                let total = fixedElementList.filter {$0.category == category}.count
                label.text = "\(category): \(learnedElementsFromCategory) from \(total)"
                
                label.font = UIFont(name: "Menlo", size: 20)
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
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
                    make.trailing.equalToSuperview().offset(5)
                    make.centerY.equalToSuperview()
                }
                
                return cell
            }()
            
            categoriesViews.append(cell)
        }
    }
    
    @objc private func shareAction() {
        var resultToShare = "Hey everyone! I just wanted to share a major milestone in my journey of learning chemical elements.\n"
        if countOfMemorizingsLabel.text != "0" {
            resultToShare += "I have successfully memorized \(String(describing: countOfLearnedElementsLabel.text)) elements in the periodic table"
        }
        
        if countOfBigGamesLabel.text != "0" && countOfMemorizingsLabel.text != "0" {
            resultToShare += " and played \(String(describing: countOfBigGamesLabel.text)) Big Games."
        } else if countOfBigGamesLabel.text != "0" && countOfMemorizingsLabel.text == "0" {
            resultToShare += "I've successfully passed \(String(describing: countOfBigGamesLabel.text)) Big Games."
        } else if countOfBigGamesLabel.text == "0" && countOfMemorizingsLabel.text != "0" {
            resultToShare += "."
        }
        
        resultToShare += "\nI am so proud of my progress and would love to invite you to join me in this exciting journey of learning. Let's explore the world of chemistry together and unlock the wonders of the chemical elements!\n 🧪🔬📚 #ChemistrySuccess #PeriodicTableGoals #JoinMe"
        let share = UIActivityViewController(
            activityItems: [resultToShare],
            applicationActivities: nil
        )
        share.overrideUserInterfaceStyle = .dark
        present(share, animated: true, completion: nil)
    }
    
    @objc func backAction() {
        self.dismiss(animated: true)
    }
}
