//
//  CategoryTestViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 25.03.2024.
//

import UIKit
import SnapKit

private enum State {
    case question
    case answer
    case score
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
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var coloredView: UIView = {
        let view = UIView()
        view.backgroundColor = CustomColors.choseColor(currentCategory)
        return view
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
        button.layer.borderColor = CustomColors.softAppColor.cgColor
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
        button.layer.borderColor = CustomColors.softAppColor.cgColor
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
        button.layer.borderColor = CustomColors.softAppColor.cgColor
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
        button.layer.borderColor = CustomColors.softAppColor.cgColor
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
            //TODO: save result to DB
            showCongratulationViewController(totalQuestions: sequenceOfQuestions.count, correctAnswers: correctAnswerCount, fromViewControllerDelegate: self, describeOfSense: currentCategory)
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
        setupQuestionSequens()
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
extension CategoryTestViewController: GameProtocol {
    func getVariantsOfAnswers() -> Set<String> {
        QuestionFactory.getVariantsOfAnswersForCategoryTest(currentCorrectElement: correctElements[currentQuestionIndex], incorrectElements: incorrectElements)
    }
    
    func getVariantsOfQuestion() -> String {
        QuestionFactory.getVariantsOfQuestionForCategoryTest(currentCategory: currentCategory)
    }
    
    func getCorrectAnswer() -> String {
        QuestionFactory.getCorrectAnswerForCategoryTest(currentCorrectElement: correctElements[currentQuestionIndex])
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
extension CategoryTestViewController: ShowCongratulationProtocol {
    func showCongratulationViewController(totalQuestions: Int, correctAnswers: Int, fromViewControllerDelegate: ShowCongratulationProtocol, describeOfSense: String) {
        let vc = CongratulationViewController(totalQuestions: totalQuestions, correctAnswers: correctAnswers, delegate: fromViewControllerDelegate, describeOfSense: describeOfSense)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func selfDismiss() {
        self.dismiss(animated: false)
    }
}
