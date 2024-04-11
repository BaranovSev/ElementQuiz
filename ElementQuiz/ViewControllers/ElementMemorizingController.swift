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
    private var state: State = .question
    private var answerIsCorrect: Bool? = nil
    private var correctAnswerCount = 0
    private var currentQuestionIndex = 0
    private var additionalQuestionPoints = 5

//TODO: implement different visualisation for same question, used buttons pressed, buttons drags & other UI elements
    private let fixedSequenceOfQuestions: [QuestionAbout] = [
//        .atomicMassQuestion,
        .latinNameQuestion,
//        .commonNameQuestion,
//        .orderNumberQuestion,
//        .densityQuestion,
//        .categoryQuestion,
//        .meltQuestion,
//        .periodQuestion,
//        .groupQuestion,
//        .phaseQuestion,
//        .boilingPointQuestion
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
        label.layer.masksToBounds = true
        label.layer.borderWidth = 4
        label.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.layer.cornerRadius = 15.0
        label.text = currentElement.symbol
        return label
    }()
    
    private lazy var questionLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 24)
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
    
    // MARK: - Private Methods
    private func updateQuizUI(_ element: ChemicalElementModel) {
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
            //TODO: save result in DB
            showCongratulationViewController(totalQuestions: sequenceOfQuestions.count, correctAnswers: correctAnswerCount, fromViewControllerDelegate: self, describeOfSense: element.name)
        }
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
            sender.backgroundColor = .green.withAlphaComponent(0.7)
        } else if answerIsCorrect == false {
            sender.backgroundColor = .red.withAlphaComponent(0.7)
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
    func showCongratulationViewController(totalQuestions: Int, correctAnswers: Int, fromViewControllerDelegate: ShowCongratulationProtocol, describeOfSense: String) {
        let vc = CongratulationViewController(totalQuestions: totalQuestions, correctAnswers: correctAnswers, delegate: fromViewControllerDelegate, describeOfSense: describeOfSense)
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
        view.backgroundColor = .white
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
