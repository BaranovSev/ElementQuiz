//
//  ElementMemorizingController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 26.02.2024.
//


import UIKit
import SnapKit

private enum State {
    case question
    case answer
    case score
}

final class ElementMemorizingController: UIViewController {
    // MARK: - Properties
    private let fixedElementList: [ChemicalElementModel]
    private let currentElement: ChemicalElementModel
    private let user: User = DataManager.shared.fetchUser()
    private var state: State = .question
    private var answerIsCorrect: Bool? = nil
    private var correctAnswerCount = 0
    private var currentQuestionIndex = 0
    private var additionalQuestionPoints = 5
    private var delegate: StartViewController? = nil

//TODO: implement different visualisation for same question, used buttons pressed, buttons drags & other UI elements
    private let fixedSequenceOfQuestions: [QuestionAbout] = [
        .atomicMassQuestion,
        .latinNameQuestion,
        .commonNameQuestion,
        .orderNumberQuestion,
        .densityQuestion,
        .categoryQuestion,
        .meltQuestion,
        .periodQuestion,
        .groupQuestion,
        .phaseQuestion,
        .boilingPointQuestion
    ]
    
    private var sequenceOfQuestions: [QuestionAbout] = []
    private var missmatchedQuestions: Set <QuestionAbout> = []
    
    init(fixedElementList: [ChemicalElementModel], currentElement: ChemicalElementModel) {
        self.fixedElementList = fixedElementList
        self.currentElement = currentElement
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    
    private lazy var elementSymbolLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 50)
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        label.layer.masksToBounds = true
        label.layer.borderWidth = 4
        label.layer.borderColor = CustomColors.generalTextColor.cgColor
        label.layer.cornerRadius = 15.0
        label.text = currentElement.symbol
        return label
    }()
    
    private lazy var questionLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 24)
        label.textColor = CustomColors.generalTextColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
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
        button.setTitleColor(CustomColors.generalTextColor, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = CustomColors.backgroundForCell
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var smallButton2: UIButton = {
        var button = UIButton()
        button.setTitle("Button 2", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 30)
        button.setTitleColor(CustomColors.generalTextColor, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = CustomColors.backgroundForCell
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var smallButton3: UIButton = {
        var button = UIButton()
        button.setTitle("Button 3", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 30)
        button.setTitleColor(CustomColors.generalTextColor, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = CustomColors.backgroundForCell
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var smallButton4: UIButton = {
        var button = UIButton()
        button.setTitle("Button 4", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 30)
        button.setTitleColor(CustomColors.generalTextColor, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = CustomColors.backgroundForCell
        button.layer.cornerRadius = 10
        return button
    }()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppPhont
        backButton.tintColor = CustomColors.generalTextColor

        setupQuestionSequens()
        setUp()
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
            let variants: Set<String> = getVariantsOfAnswers()
            
            let randomVariants: [String] = variants.shuffled()
            var localIndex = 0
            for button in answerButtons {
                button.isHidden = false
                button.isEnabled = true
                button.backgroundColor = CustomColors.backgroundForCell
                button.setTitle(randomVariants[localIndex], for: .normal)
                button.setTitleColor(CustomColors.generalTextColor, for: .normal)
                button.addTarget(self, action: #selector(Self.answerBtnPressed(_:)), for: .touchUpInside)
                localIndex += 1
            }
        case .answer:
            let currentCorrectAnswer = getCorrectAnswer()
            for button in answerButtons {
                if button.titleLabel?.text == currentCorrectAnswer {
                    button.backgroundColor = CustomColors.greenCorrectAnswer
                    button.setTitleColor(CustomColors.softAppColor, for: .normal)
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
            saveResultOfGame()
            showCongratulationViewController()
        }
    }
    
    private func saveResultOfGame() {
        if Double(correctAnswerCount) / Double(sequenceOfQuestions.count) > 0.6 {
            user.learnedChemicalElements.updateValue(Date(), forKey: currentElement.symbol)
        }
        
        user.countMemorizings += 1
        user.countMemorizingQuestions += sequenceOfQuestions.count
        DataManager.shared.saveUserData(from: user)
    }
    
    private func refreshUI() {
        updateQuizUI(currentElement)
    }

    private func setupQuiz() {
        state = .question
        currentQuestionIndex = 0
        answerIsCorrect = nil
        correctAnswerCount = 0
        additionalQuestionPoints = 5
        sequenceOfQuestions = fixedSequenceOfQuestions
        missmatchedQuestions = []
    }
    
    private func setupQuestionSequens() {
        sequenceOfQuestions = fixedSequenceOfQuestions
    }
    
    @objc func answerBtnPressed(_ sender: UIButton) {
        guard let userAnswer = sender.titleLabel?.text else { return }
        answerBtnShouldReturn(answer: userAnswer)
        if answerIsCorrect == true {
            sender.backgroundColor = CustomColors.greenCorrectAnswer
        } else if answerIsCorrect == false {
            sender.backgroundColor = CustomColors.redIncorrectAnswer
        }
    }
    
    private func next() {
        if currentQuestionIndex + 1 < sequenceOfQuestions.count {
            currentQuestionIndex += 1
            state = .question
        } else {
            state = .score
        }

        refreshUI()
    }
    
    @objc func backAction() {
        self.dismiss(animated: true)
    }
    
    func answerBtnShouldReturn(answer: String) {
        checkAnswer(answer)
        
        state = .answer
        refreshUI()
    }
}

// MARK: - ShowCongratulationProtocol
extension ElementMemorizingController: ShowCongratulationProtocol {
    func showCongratulationViewController() {
        let vc = CongratulationViewController(totalQuestions: sequenceOfQuestions.count, correctAnswers: correctAnswerCount, delegate: self, describeOfSense: currentElement.name)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func selfDismiss() {
        self.dismiss(animated: false)
    }
}

// MARK: - UI setup layout functions
private extension ElementMemorizingController {
    private func setUp() {
        view.backgroundColor = CustomColors.generalAppPhont
        view.addSubview(elementSymbolLabel)
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
        elementSymbolLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.centerX.equalToSuperview()
            make.height.equalTo(150)
            make.width.equalTo(150)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(elementSymbolLabel.snp.bottom).offset(30)
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

// MARK: - Helpers
private extension ElementMemorizingController {
    private func addQuestionIfNeeded() {
        if (sequenceOfQuestions.count - currentQuestionIndex) == 1 && additionalQuestionPoints > 1 {
            additionalQuestionPoints = 1
        }
        
        if (sequenceOfQuestions.count - currentQuestionIndex) == 2 && additionalQuestionPoints > 2{
            additionalQuestionPoints = 2
        }
        
        if additionalQuestionPoints > 0 {
            additionalQuestionPoints -= 1
            sequenceOfQuestions.append(sequenceOfQuestions[currentQuestionIndex])
        }
    }
    
    private func saveToMissmathcedQuestions(_ question: QuestionAbout) {
        missmatchedQuestions.insert(question)
    }
    
    private func deleteFromMissmathcedQuestions(_ question: QuestionAbout) {
        missmatchedQuestions.remove(question)
    }
}

//MARK: - GameProtocol
extension ElementMemorizingController: GameProtocol {
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
            deleteFromMissmathcedQuestions(sequenceOfQuestions[currentQuestionIndex])
        }
        
        func failure() {
            answerIsCorrect = false
            addQuestionIfNeeded()
            saveToMissmathcedQuestions(sequenceOfQuestions[currentQuestionIndex])
        }
        
        if answer == correctAnswer {
            success()
        } else {
            failure()
        }
    }
}
