//
//  BigGameViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 28.03.2024.
//


import UIKit
import SnapKit

private enum Mode {
    case flashCard
    case quiz
}

private enum State {
    case question
    case answer
    case score
}

enum QuestionAbout: String {
    case latinNameQuestion = "latin name"
    case commonNameQuestion = "common name"
    case atomicMassQuestion = "atomic mass"
    case orderNumberQuestion = "order number"
    case categoryQuestion = "category"
    case densityQuestion = "density"
    case periodQuestion = "period"
    case groupQuestion = "group"
    case phaseQuestion = "phase"
    case boilingPointQuestion = "boiling point"
    case meltQuestion = "melting point"
    static var allValues: [String] {
        return [
            latinNameQuestion.rawValue,
            commonNameQuestion.rawValue,
            atomicMassQuestion.rawValue,
            orderNumberQuestion.rawValue,
            categoryQuestion.rawValue,
            densityQuestion.rawValue,
            periodQuestion.rawValue,
            groupQuestion.rawValue,
            phaseQuestion.rawValue,
            boilingPointQuestion.rawValue,
            meltQuestion.rawValue
        ]
    }
}

final class BigGameViewController: UIViewController {
    
    private var fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private var shuffledElementList: [ChemicalElementModel] = []
    private var dataSource:  ElementQuizDataSource? = ElementQuizDataSource()
    private var sequenceOfQuestions: [QuestionAbout] = []
    private let user: User = DataManager.shared.fetchUser()
    private var currentElementIndex = 0
    private var currentQuestionIndex = 0
    private var answerIsCorrect: Bool? = nil
    private var correctAnswerCount = 0
    private var state: State = .question
    private var typeOfGame: QuestionAbout {
        didSet {
            currentElementIndex = 0
            currentQuestionIndex = 0
        }
    }
    
    private var fixedSequenceOfQuestions: [QuestionAbout] {
        Array(repeating: typeOfGame, count: fixedElementList.count)
    }
    
    private var currentElement: ChemicalElementModel {
        shuffledElementList[currentQuestionIndex]
    }
    
    init(fixedElementList: [ChemicalElementModel], dataSource: ElementQuizDataSource, typeOfGame: QuestionAbout) {
        self.fixedElementList = fixedElementList
        self.dataSource = dataSource
        self.typeOfGame = typeOfGame
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Elements
    private lazy var elementIcon: ElementIconView = {
        var elementIcon = ElementIconView(displayItem: (dataSource?.elementToDisplayItem(fixedElementList[currentElementIndex]))!)
        return elementIcon
    }()
    
    private lazy var questionLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 27)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var verticalStack: UIStackView = {
        var stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 30
        return stack
    }()
    
    private lazy var smallButton1: UIButton = {
        var button = UIButton()
        button.setTitle("Button 1", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 30)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var smallButton2: UIButton = {
        var button = UIButton()
        button.setTitle("Button 2", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 30)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var smallButton3: UIButton = {
        var button = UIButton()
        button.setTitle("Button 3", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 30)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var smallButton4: UIButton = {
        var button = UIButton()
        button.setTitle("Button 4", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 30)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = .white
        button.layer.borderColor = CustomColors.lightPurple
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        return button
    }()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.backgroundColor = .white
        backButton.tintColor = .black
        
        setupQuestionSequens()
        setUp()
    }
    
    private func saveResultOfGame() {
        user.countBigGames += 1
        user.countBigGamesQuestions += sequenceOfQuestions.count
        DataManager.shared.saveUserData(from: user)
    }
    
    // MARK: - Private Methods
    private func updateQuizUI(_ element: ChemicalElementModel) {
        switch state {
        case .question, .score:
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        case .answer:
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
        
        // Answer buttons
        let answerButtons = [smallButton1, smallButton2, smallButton3, smallButton4]
        
        switch state {
        case .question:
            guard let dataSource = dataSource else {
                return
            }
            
            elementIcon.displayItem = dataSource.elementToDisplayItem(currentElement)
            specialChangesForElementIcon()
            
            let variants: Set<String> = getVariantsOfAnswers()
            
            let randomVariants: [String] = variants.shuffled()
            var localIndex = 0
            for button in answerButtons {
                button.isHidden = false
                button.isEnabled = true
                button.backgroundColor = .white
                button.setTitle(randomVariants[localIndex], for: .normal)
                button.addTarget(self, action: #selector(Self.answerBtnPressed(_:)), for: .touchUpInside)
                localIndex += 1
            }
        case .answer:
            let currentCorrectAnswer = getCorrectAnswer()
            for button in answerButtons {
                if button.titleLabel?.text == currentCorrectAnswer {
                    button.backgroundColor = .green.withAlphaComponent(0.7)
                }
                button.isEnabled = false
            }
        case .score:
            for button in answerButtons {
                button.isEnabled = false
                button.isHidden = true
            }
        }
        
        switch state {
        case .question:
            questionLabel.text = getVariantsOfQuestion()
        case .answer:
            let delayInSeconds = 3.8
            let delay = DispatchTime.now() + delayInSeconds

            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.next()
            }
        case .score:
            //TODO: new controller with result
            saveResultOfGame()
            showCongratulationViewController(totalQuestions: sequenceOfQuestions.count, correctAnswers: correctAnswerCount, fromViewControllerDelegate: self, describeOfSense: typeOfGame.rawValue)
        }
    }
    
    private func refreshUI() {
        updateQuizUI(fixedElementList[currentElementIndex])
    }

    private func setupQuiz() {
        state = .question
        currentQuestionIndex = 0
        answerIsCorrect = nil
        correctAnswerCount = 0
        sequenceOfQuestions = fixedSequenceOfQuestions
    }
    
    private func setupQuestionSequens() {
        sequenceOfQuestions = fixedSequenceOfQuestions
        shuffledElementList = fixedElementList.shuffled()
    }
    
    @objc func answerBtnPressed(_ sender: UIButton) {
        guard let userAnswer = sender.titleLabel?.text else { return }
        answerBtnShouldReturn(answer: userAnswer)
        if answerIsCorrect == true {
            sender.backgroundColor = .green.withAlphaComponent(0.7)
        } else if answerIsCorrect == false {
            sender.backgroundColor = .red.withAlphaComponent(0.7)
        }
    }
    
    @objc func backAction() {
        self.dismiss(animated: true)
    }
    
    private func next() {
        if currentQuestionIndex + 1 < fixedElementList.count {
            currentQuestionIndex += 1
            state = .question
        } else {
            state = .score
        }

        refreshUI()
    }
    
    func answerBtnShouldReturn(answer: String) {
        checkAnswer(answer)
        
        state = .answer
        refreshUI()
    }
    
    private func specialChangesForElementIcon() {
        switch typeOfGame {
        case .atomicMassQuestion:
            elementIcon.atomicMassLabel.isHidden = true
        case .orderNumberQuestion:
            elementIcon.elementNumberLabel.isHidden = true
        case .categoryQuestion:
            elementIcon.backgroundColor = .white
        default :
            elementIcon.atomicMassLabel.isHidden = false
            elementIcon.elementNumberLabel.isHidden = false
        }
    }
}

// MARK: UI methods
private extension BigGameViewController {
    private func setUp() {
        view.backgroundColor = .white
        view.addSubview(elementIcon)
        view.addSubview(questionLabel)
        view.addSubview(verticalStack)
        verticalStack.addSubview(smallButton1)
        verticalStack.addSubview(smallButton2)
        verticalStack.addSubview(smallButton3)
        verticalStack.addSubview(smallButton4)
        layout()
        refreshUI()
    }
    
    private func layout() {
        elementIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.centerX.equalToSuperview()
            make.height.equalTo(150)
            make.width.equalTo(150)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(elementIcon.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(40)
        }
        
        verticalStack.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(questionLabel.snp.bottom).offset(70)
            make.leading.equalTo(questionLabel.snp_leadingMargin).offset(20)
            make.trailing.equalTo(questionLabel.snp_trailingMargin).offset(-20)
            make.bottom.equalToSuperview().offset(20)
        }
        
        smallButton1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.greaterThanOrEqualTo(75)
            make.centerX.equalToSuperview()
        }
        
        smallButton2.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(smallButton1.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.width.greaterThanOrEqualTo(75)
            make.centerX.equalToSuperview()
        }
        
        smallButton3.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(smallButton2.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.width.greaterThanOrEqualTo(75)
            make.centerX.equalToSuperview()
        }
        
        smallButton4.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(smallButton3.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.width.greaterThanOrEqualTo(75)
            make.centerX.equalToSuperview()
        }
    }
}

//MARK: - GameProtocol
extension BigGameViewController: GameProtocol {
    func getVariantsOfAnswers() -> Set<String> {
        QuestionFactory.getVariantsOfAnswers(currentQuestionType: sequenceOfQuestions[currentQuestionIndex],
                                             currentElement: currentElement,
                                             allElements: fixedElementList)
    }
    
    func getVariantsOfQuestion() -> String {
        QuestionFactory.getVariantsOfQuestion(currentQuestionType: sequenceOfQuestions[currentQuestionIndex])
    }
    
    func getCorrectAnswer() -> String {
        QuestionFactory.getCorrectAnswer(currentQuestionType: sequenceOfQuestions[currentQuestionIndex],
                                         currentElement: currentElement)
    }
    
    func checkAnswer(_ answer: String) {
        let correctAnswer = getCorrectAnswer()
        
        func success() {
            answerIsCorrect = true
            correctAnswerCount += 1
        }
        
        func failure() {
            answerIsCorrect = false
        }
        
        if answer == correctAnswer {
            success()
        } else {
            failure()
        }
    }
}

// MARK: - ShowCongratulationProtocol
extension BigGameViewController: ShowCongratulationProtocol {
    func showCongratulationViewController(totalQuestions: Int, correctAnswers: Int, fromViewControllerDelegate: ShowCongratulationProtocol, describeOfSense: String) {
        let vc = CongratulationViewController(totalQuestions: totalQuestions, correctAnswers: correctAnswers, delegate: fromViewControllerDelegate, describeOfSense: describeOfSense)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func selfDismiss() {
        self.dismiss(animated: false)
    }
}
