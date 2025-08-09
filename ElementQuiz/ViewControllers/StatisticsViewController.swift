//
//  StatisticsViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 19.03.2024.
//

import UIKit
import SnapKit

final class StatisticViewControler: UIViewController {
    private let userDataSource: UserStatisticDataSource = UserStatisticDataSource()
    private let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private let user: User = DataManager.shared.fetchUser()
    private var learnedElements: [ChemicalElementModel] {
        get {
            DataManager.shared.fetchLearnedElements()
        }
    }
    
    // MARK: - UI Properties
    private var categoriesViews: [UIView] = []
    
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height * 2.7)
        scrollView.backgroundColor = CustomColors.generalAppFont
        scrollView.accessibilityScroll(.down)
        return scrollView
    }()
    
    private lazy var avatarView: AvatarClassView = {
        AvatarClassView()
    }()
    
    private lazy var userStatisticProgress: CircleProgressBar = {
        let circleProgressBar = CircleProgressBar(displayItem: userDataSource.infoToDisplayItem(learned: learnedElements, total: fixedElementList))
//        let circleProgressBar = CircleProgressBar(displayItem: userDataSource.infoToDisplayItem(learned: fixedElementList, total: fixedElementList))
        return circleProgressBar
    }()
    
    private lazy var memorizingSection: SliderBox = {
        SliderBox()
    }()
    
    private lazy var lessonsSection: SliderBox = {
        SliderBox()
    }()
    
    private lazy var reactionsSection: SliderBox = {
        SliderBox()
    }()
    
    private lazy var bigGamesSection: SliderBox = {
        SliderBox()
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plane") ?? UIImage(), for: .normal)
        button.tintColor = CustomColors.generalTextColor
        button.backgroundColor = CustomColors.backgroundForCell
        button.layer.cornerRadius = 50
        button.addTarget(self, action: #selector(Self.shareAction), for: .touchUpInside)
        button.imageView?.snp.makeConstraints { make in
            make.height.equalToSuperview().offset(-5)
            make.width.equalToSuperview().offset(-5)
            make.center.equalToSuperview()
        }
        return button
    }()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setup()
        addSubViews()
        layout()
    }
    
    func setupNavBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(showSettings))
        
        backButton.tintColor = CustomColors.generalTextColor
        settingsButton.tintColor = CustomColors.generalTextColor
        
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = settingsButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppFont
        self.navigationController?.navigationBar.barTintColor = CustomColors.generalAppFont
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(avatarView)
        for view in categoriesViews {
            scrollView.addSubview(view)
        }
        
        scrollView.addSubview(userStatisticProgress)
        scrollView.addSubview(memorizingSection)
        scrollView.addSubview(lessonsSection)
        scrollView.addSubview(reactionsSection)
        scrollView.addSubview(bigGamesSection)
        scrollView.addSubview(shareButton)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.height.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }

        var previousElement: UIView = avatarView
        
        for view in categoriesViews {
            view.snp.makeConstraints { make in
                make.top.equalTo(previousElement.snp.bottom).offset(35)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-30)
            }
            previousElement = view
        }
        
        userStatisticProgress.snp.makeConstraints { make in
            make.top.equalTo(previousElement.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(userStatisticProgress.snp.width)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(userStatisticProgress.sizeIncrement)
                
        }
        
        memorizingSection.snp.makeConstraints { make in
            make.top.equalTo(userStatisticProgress.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(memorizingSection.snp.width).dividedBy(2)
        }
        
        lessonsSection.snp.makeConstraints { make in
            make.top.equalTo(memorizingSection.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(memorizingSection)
            make.height.equalTo(memorizingSection)
        }
        
        reactionsSection.snp.makeConstraints { make in
            make.top.equalTo(lessonsSection.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(memorizingSection)
            make.height.equalTo(memorizingSection)
        }
        
        bigGamesSection.snp.makeConstraints { make in
            make.top.equalTo(reactionsSection.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(memorizingSection)
            make.height.equalTo(memorizingSection)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(bigGamesSection.snp.bottom).offset(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(100)
        }
    }
    
    private func setup() {
        let dailyQuote: String = quotes.randomElement()!
//        let dailyQuote: String = quotes[14]
//        let dailyQuote: String = quotes.max()!
        let scoreText: String = String(learnedElements.count) + "/" + String(fixedElementList.count)
        let progress: Float = Float(learnedElements.count) / Float(fixedElementList.count)
        
        avatarView.configure(longText: dailyQuote,
                             scoreText: scoreText,
                             progress: progress)
        
        addDescriptionCell()
        
        let countOfMemorizings = user.countMemorizings
        let countMemorizingQuestions = user.countMemorizingQuestions
        let memorizingHeader = countOfMemorizings != 1 ? "memorizings" : "memorizing"
        let memorizingSideInfoText = "with more than\n\(countMemorizingQuestions)\nquestions"

        memorizingSection.configure(position: .left, 
                                    headerText: memorizingHeader,
                                    score: countOfMemorizings,
                                    subscriptText: "passed",
                                    sideContentText: memorizingSideInfoText,
                                    imageForEvent: "ancient_table")
        
        //TODO: countOfLessons real data need
        let countOfLessons = [0,1,2,3].randomElement()!
        //user.countPassedLessons (by lesson id)
        let totalCountOfLessons = 4
        let lessonsHeader = countOfLessons != 1 ? "lessons" : "lesson"
        let lessonsLeft = totalCountOfLessons - countOfLessons
        let lessonsSideInfoText = lessonsLeft <= 0 ? "Congratulations!\nYou've learned them all." : "still left: \(lessonsLeft)"
        lessonsSection.configure(position: .right,
                                    headerText: lessonsHeader,
                                    score: countOfLessons,
                                    subscriptText: "studied",
                                    sideContentText: lessonsSideInfoText,
                                    imageForEvent: "scroll_lesson")
        
        //TODO: countOfReactions real data need
        let countOfReactions = [0,1,2,3].randomElement()!
        //user.countPassedReactions (by lesson id)
        let totalCountOfReactions = 4
        let reactionsHeader = countOfReactions != 1 ? "reactions" : "reaction"
        let reactionsLeft = totalCountOfReactions - countOfReactions
        let reactionsSideInfoText = reactionsLeft <= 0 ? "Congratulate!\nYou've done them all." : "still left: \(reactionsLeft)"
        reactionsSection.configure(position: .left,
                                    headerText: reactionsHeader,
                                    score: countOfReactions,
                                    subscriptText: "carried out",
                                    sideContentText: reactionsSideInfoText,
                                    imageForEvent: "flask")
        
        let countOfBigGames = user.countBigGames
        let countBigGameQuestions = user.countBigGamesQuestions
        let bigGamesHeader = countOfBigGames != 1 ? "big games" : "big game"
        let bigGamesSideInfoText = "with over \(countBigGameQuestions) questions"
        
        bigGamesSection.configure(position: .right,
                                  headerText: bigGamesHeader,
                                  score: countOfBigGames,
                                  subscriptText: "wins",
                                  sideContentText: bigGamesSideInfoText,
                                  imageForEvent: "caesar_games")
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
                label.textColor = CustomColors.generalTextColor
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
        switch user.countMemorizings {
        case 0:
        resultToShare += ""
        case 1:
            resultToShare += "I have successfully memorized \(String(user.learnedChemicalElements.count)) element with symbol \(user.learnedChemicalElements.first!.key) in the periodic table"
        default:
            resultToShare += "I have successfully memorized \(String(user.learnedChemicalElements.count)) elements in the periodic table"
        }
        
        if user.countBigGames != 0 && user.countMemorizings != 0 {
            resultToShare += " and played \(String(user.countBigGames)) Big Games with more than \(user.countBigGamesQuestions) questions."
        } else if user.countBigGames != 0 && user.countMemorizings == 0 {
            resultToShare += "I've successfully passed \(String(user.countBigGames)) Big Games with more than \(user.countBigGamesQuestions) questions."
        } else if user.countBigGames == 0 && user.countMemorizings != 0 {
            resultToShare += "."
        }
        
        resultToShare += "\nI am so proud of my progress and would love to invite you to join me in this exciting journey of learning. Let's explore the world of chemistry together and unlock the wonders of the chemical elements!\n 🧪🔬📚 #ChemistrySuccess #PeriodicTableGoals #JoinMe \nhttps://apps.apple.com/app/mendelevi/id6504156932"
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
    
    @objc func showSettings() {
        let vc = ThemeSelectorViewController() 
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
}

private final class AvatarClassView: UIView {
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let imageView = UIImageView()
    private let textView = UITextView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func addSubViews() {
        addSubview(progressBar)
        addSubview(imageView)
        addSubview(label)
        addSubview(textView)
    }

    private func setupViews() {
        progressBar.progressTintColor = CustomColors.progressBarColor
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let avatarImage: UIImage = UIImage(named: "Caesar_right") ?? UIImage()
        imageView.image = avatarImage
        
        label.textColor = CustomColors.generalTextColor
        label.font = UIFont(name: "Menlo Bold", size: 30)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .right
        
        textView.backgroundColor = CustomColors.backgroundForCell
        textView.textColor = CustomColors.generalTextColor
        textView.font = UIFont(name: "Avenir", size: 25)
        textView.adjustsFontForContentSizeCategory = true
        textView.layer.cornerRadius = 10
        textView.isScrollEnabled = false
        textView.isEditable = false
        
        addSubViews()
        layout()
    }
    
    func configure(longText: String, scoreText: String, progress: Float) {
        textView.animateText(longText, withDelay: 0.025)
        label.text = scoreText
        progressBar.setProgress(progress, animated: true)
    }

    private func layout() {
        progressBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(25)
            make.height.equalTo(8)
        }

        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.bottom.equalTo(progressBar.snp.top)
        }
        
        label.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.bottom.equalTo(progressBar.snp.top).offset(-15)
        }

        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.bottom.lessThanOrEqualTo(imageView.snp.top)
        }
    }
}

private class SliderBox: UIView {
    enum Position {
        case left
        case right
    }

    private let parentView = UIView()
    private let coloredView = UIStackView()
    private let generalHeaderLabel = UILabel()
    private let generalCountLabel = UILabel()
    private let generalSubscriptLabel = UILabel()
    private var sideContent: UIView?


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func addSubViews() {
        addSubview(parentView)
        parentView.addSubview(coloredView)
        
        if let sideContent = sideContent {
            parentView.addSubview(sideContent)
        }
        
        coloredView.addArrangedSubview(generalHeaderLabel)
        coloredView.addArrangedSubview(generalCountLabel)
        coloredView.addArrangedSubview(generalSubscriptLabel)
    }

    private func setupViews() {
        let corner = 20.0
        parentView.layer.masksToBounds = true
        parentView.layer.cornerRadius = corner
        parentView.layer.borderColor = CustomColors.backgroundForCell.cgColor
        parentView.layer.borderWidth = 2
        parentView.backgroundColor = CustomColors.generalAppFont
        
        coloredView.layer.masksToBounds = true
        coloredView.layer.cornerRadius = corner
        coloredView.backgroundColor = CustomColors.backgroundForCell
        coloredView.axis = .vertical
        coloredView.alignment = .center
        coloredView.distribution = .fillEqually
        coloredView.spacing = 0
        
        generalHeaderLabel.font = UIFont(name: "Avenir", size: 30)
        generalHeaderLabel.textColor = CustomColors.generalTextColor
        generalHeaderLabel.textAlignment = .center
        
        generalCountLabel.font = UIFont(name: "Impact", size: 45)
        generalCountLabel.textColor = CustomColors.generalTextColor
        generalCountLabel.textAlignment = .center
        
        generalSubscriptLabel.font = UIFont(name: "Avenir", size: 30)
        generalSubscriptLabel.textColor = CustomColors.generalTextColor
        generalSubscriptLabel.textAlignment = .center
        
        addSubViews()
    }
    
    func configure(position: Position, headerText: String, score: Int, subscriptText: String, sideContentText: String, imageForEvent: String) {
        generalHeaderLabel.text = headerText
        generalCountLabel.text = String(score)
        generalSubscriptLabel.text = subscriptText

        
        if score != 0 {
            let label = UILabel()
            label.numberOfLines = 3
            label.adjustsFontSizeToFitWidth = true
            label.textColor = CustomColors.backgroundForCell
            label.font = UIFont(name: "Menlo Bold", size: 20)
            label.text = sideContentText
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            sideContent = label
        } else {
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageForEvent) ?? UIImage()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            sideContent = imageView
        }
        
        if let sideContent = sideContent {
            parentView.addSubview(sideContent)
        }

        layout(position: position)
    }
    
    private func layout(position: Position) {
        parentView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        coloredView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            switch position {
            case .left:
                make.leading.equalTo(parentView.snp.leading)
            case .right:
                make.trailing.equalTo(parentView.snp.trailing)
            }
        }
        
        if let sideContent = sideContent {
            sideContent.snp.makeConstraints { make in
                make.height.equalToSuperview()
                make.width.equalTo(sideContent.snp.height)
                switch position {
                case .left:
                    make.trailing.equalToSuperview()
                case .right:
                    make.leading.equalToSuperview()
                }
            }
        }
    }
}

