//
//  CategoryTestViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 25.03.2024.
//

import UIKit
import SnapKit

private enum QuestionAbout {
    case categoryQuestion
}

final class CategoryTestViewController: UIViewController {
    // MARK: - Properties
    private let fixedElementList: [ChemicalElementModel]
    private var correctElements: [ChemicalElementModel] {
        return fixedElementList.filter{ $0.category == currentCategory }
    }
    private var incorrectElements: [ChemicalElementModel] {
        fixedElementList.filter(){ !correctElements.contains($0) }
    }
    private let currentCategory: String
    private var state: State = .question
    private var answerIsCorrect: Bool? = nil
    private var correctAnswerCount = 0
    private var currentQuestionIndex = 0

    private var fixedSequenceOfQuestions: [QuestionAbout] {
        Array(repeating: .categoryQuestion, count: correctElements.count)
    }
    
    private var sequenceOfQuestions: [QuestionAbout] = []
    private var missmatchedQuestions: Set <QuestionAbout> = []
    
    init(fixedElementList: [ChemicalElementModel], currentCategory: String) {
        self.fixedElementList = fixedElementList
        self.currentCategory = currentCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    
    private lazy var questionLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 27)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var coloredView: UIView = {
        let view = UIView()
        view.backgroundColor = CustomColors.choseColor(currentCategory)
        return view
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
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backAction))
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
        updateQuizUI(correctElements[currentQuestionIndex])
    }

    private func setupQuiz() {
        state = .question
        currentQuestionIndex = 0
        answerIsCorrect = nil
        correctAnswerCount = 0
        sequenceOfQuestions = fixedSequenceOfQuestions
        missmatchedQuestions = []
    }
    
    private func setupQuestionSequens() {
        sequenceOfQuestions = fixedSequenceOfQuestions
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
        if currentQuestionIndex + 1 < correctElements.count {
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
}

private extension CategoryTestViewController {
    private func setUp() {
        view.backgroundColor = .white
        view.addSubview(questionLabel)
        view.addSubview(coloredView)
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
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(120)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(40)
        }
        
        coloredView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(5)
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

// MARK: - Helpers
private extension CategoryTestViewController {
    private func checkAnswer(_ answer: String) {
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
    
    private func getVariantsOfAnswers() -> Set<String> {
        switch sequenceOfQuestions[currentQuestionIndex] {
        
        case .categoryQuestion:
            var variants: Set<String> = [correctElements[currentQuestionIndex].name]
            while (variants.count < 4) {
                variants.insert(incorrectElements.randomElement()!.name)
            }
            return variants
        }
    }
    
    private func getVariantsOfQuestion() -> String {
        switch sequenceOfQuestions[currentQuestionIndex] {
        case .categoryQuestion:
            return "Chose element from \n\(self.currentCategory) category"
        }
    }
    
    private func getCorrectAnswer() -> String {
        switch sequenceOfQuestions[currentQuestionIndex] {
        case .categoryQuestion:
            return correctElements[currentQuestionIndex].name

        }
    }
}
