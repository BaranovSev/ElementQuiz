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
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var bigButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.setTitle("Lets start!", for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.isHidden = true
        return button
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
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        setupQuestionSequens()
        setUp()
    }
    
    // MARK: - Private Methods
    private func updateQuizUI(_ element: ChemicalElementModel) {
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
            questionLabel.textAlignment = .center
            questionLabel.text = getVariantsOfQuestion()
        case .answer:
            if answerIsCorrect == true {
                questionLabel.textAlignment = .center
            }
        case .score:
            //TODO: new controller with result
            questionLabel.textAlignment = .center
            questionLabel.text = "Game result: \(correctAnswerCount) from \(sequenceOfQuestions.count)"
        }
        
        // BIG Button
        switch state {
        case .question:
            bigButton.isHidden = true
            bigButton.isEnabled = false
        case .answer:
            let delayInSeconds = 3.8
            let delay = DispatchTime.now() + delayInSeconds

            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.next()
            }
        case .score:
        // TODO: show score controller
            bigButton.isHidden = false
            bigButton.isEnabled = true
            bigButton.setTitle("Show result", for: .normal)
            bigButton.removeTarget(self, action: #selector(Self.newGame), for: .touchUpInside)
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
    
    @objc func newGame() {
        setupQuiz()
        refreshUI()
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
    
    @objc func backToMainViewController() {
        print("BACK TO MAIN")
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
        view.addSubview(bigButton)
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
        
        bigButton.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(questionLabel.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(200)
        }
        
        verticalStack.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(bigButton.snp.bottom).offset(70)
            make.leading.equalTo(bigButton.snp_leadingMargin).offset(-50)
            make.trailing.equalTo(bigButton.snp_trailingMargin).offset(50)
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
        switch sequenceOfQuestions[currentQuestionIndex] {
        case .latinNameQuestion:
            var variants: Set<String> = [currentElement.latinName]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.latinName)
            }
            return variants
        case .commonNameQuestion:
            var variants: Set<String> = [currentElement.name]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.name)
            }
            return variants
        case .atomicMassQuestion:
            var variants: Set<String> = [String(format: "%.3f", currentElement.atomicMass)]
            while (variants.count < 4) {
                variants.insert(String(format: "%.3f", fixedElementList.randomElement()!.atomicMass))
            }
            return variants
        case .orderNumberQuestion:
            var variants: Set<String> = [String(currentElement.number)]
            while (variants.count < 4) {
                variants.insert(String(fixedElementList.randomElement()!.number))
            }
            return variants
        case .categoryQuestion:
            var variants: Set<String> = [currentElement.category]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.category)
            }
            return variants
        case .densityQuestion:
            var variants: Set<String> = []
            if let densityText = currentElement.density {
                variants.insert("\(densityText)")
            } else {
                variants.insert("unknown")
            }
            
            while (variants.count < 4) {
                if let densityText = fixedElementList.randomElement()!.density {
                    variants.insert("\(densityText)")
                } else {
                    variants.insert("unknown")
                }
            }
            return variants
        case .periodQuestion:
            var variants: Set<String> = [String(currentElement.period)]
            while (variants.count < 4) {
                variants.insert(String(fixedElementList.randomElement()!.period))
            }
            return variants
        case .groupQuestion:
            var variants: Set<String> = [String(currentElement.group)]
            while (variants.count < 4) {
                variants.insert(String(fixedElementList.randomElement()!.group))
            }
            return variants
        case .phaseQuestion:
            var variants: Set<String> = [currentElement.phase, "Plasma"]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.phase)
            }
            return variants
        case .boilingPointQuestion:
            var variants: Set<String> = []
            if let boilText = currentElement.boil {
                let boil = Float(boilText) != nil ? Float(boilText) : nil
                if let boil = boil {
                    variants.insert("\(boilText) K / " + String(format: "%.2f", boil - 273.15) + " C")
                } else {
                    fatalError("can't change string to float from boil of the element when getVariantsOfAnswers() run (for correct answer)")
                }
            } else {
                variants.insert("none")
            }
            
            while (variants.count < 4) {
                if let boilRandomElementText = fixedElementList.randomElement()!.boil {
                    let boil = Float(boilRandomElementText) != nil ? Float(boilRandomElementText) : nil
                    if let boil = boil {
                        variants.insert("\(boilRandomElementText) K / " + String(format: "%.2f", boil - 273.15) + " C")
                    } else {
                        fatalError("can't change string to float from boil of the element when getVariantsOfAnswers() run")
                    }
                } else {
                    variants.insert("none")
                }
            }
            return variants
        case .meltQuestion:
            var variants: Set<String> = []
            if let meltText = currentElement.melt {
                let melt = Float(meltText) != nil ? Float(meltText) : nil
                if let melt = melt {
                    variants.insert("\(meltText) K / " + String(format: "%.2f", melt - 273.15) + " C")
                } else {
                    fatalError("can't change string to float from melt of the element when getVariantsOfAnswers() run (for correct answer)")
                }
            } else {
                variants.insert("none")
            }
            
            while (variants.count < 4) {
                if let meltRandomElementText = fixedElementList.randomElement()!.melt {
                    let melt = Float(meltRandomElementText) != nil ? Float(meltRandomElementText) : nil
                    if let melt = melt {
                        variants.insert("\(meltRandomElementText) K / " + String(format: "%.2f", melt - 273.15) + " C")
                    } else {
                        fatalError("can't change string to float from melt of the element when getVariantsOfAnswers() run")
                    }
                } else {
                    variants.insert("none")
                }
            }
            return variants
        }
    }
    
    func getVariantsOfQuestion() -> String {
        switch sequenceOfQuestions[currentQuestionIndex] {
        case .latinNameQuestion:
            return "Latin name of this element is"
        case .commonNameQuestion:
            return "The common name for this element is"
        case .atomicMassQuestion:
            return "The atomic mass of this element is equal to"
        case .orderNumberQuestion:
            return "Order number of this element in the periodic table is"
        case .categoryQuestion:
            return "This element categorized as"
        case .densityQuestion:
            return "The density of this element in \ng/cm3 is equal to"
        case .periodQuestion:
            return "The period number of an element is"
        case .groupQuestion:
            return "The group number of the element is"
        case .phaseQuestion:
            return "Phase of this element is"
        case .boilingPointQuestion:
            return "Boiling point of this element is equal to"
        case .meltQuestion:
            return "Melting point of this element is equal to"
        }
    }
    
    func getCorrectAnswer() -> String {
        switch sequenceOfQuestions[currentQuestionIndex] {
        case .latinNameQuestion:
            return currentElement.latinName
        case .commonNameQuestion:
            return currentElement.name
        case .atomicMassQuestion:
            return String(format: "%.3f", currentElement.atomicMass)
        case .orderNumberQuestion:
            return String(currentElement.number)
        case .categoryQuestion:
            return currentElement.category
        case .densityQuestion:
            return currentElement.density ?? "unknown"
        case .periodQuestion:
            return String(currentElement.period)
        case .groupQuestion:
            return String(currentElement.group)
        case .phaseQuestion:
            return currentElement.phase
        case .boilingPointQuestion:
            var resultString = ""
            if let boilText = currentElement.boil {
                let boil = Float(boilText) != nil ? Float(boilText) : nil
                if let boil = boil {
                    resultString = "\(boilText) K / " + String(format: "%.2f", boil - 273.15) + " C"
                } else {
                    fatalError("can't change string to float from boil of the element when getCorrectAnswer() run")
                }
            } else {
                resultString = "none"
            }
            return resultString
        case .meltQuestion:
            var resultString = ""
            if let meltText = currentElement.melt {
                let melt = Float(meltText) != nil ? Float(meltText) : nil
                if let melt = melt {
                    resultString = "\(meltText) K / " + String(format: "%.2f", melt - 273.15) + " C"
                } else {
                    fatalError("can't change string to float from melt of the element when getCorrectAnswer() run")
                }
            } else {
                resultString = "none"
            }
            return resultString
        }
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

