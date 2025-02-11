//
//  QuestionView.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.02.2025.
//

import UIKit

final class QuestionView: UIView {
    
    private let question: Question
    private var selectedAnswers: [Answer] = []
    
    // MARK: - UI Elements
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = CustomColors.generalTextColor
        return label
    }()
    
    private let answersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    // MARK: - Init
    init(question: Question) {
        self.question = question
        super.init(frame: .zero)
        setup()
        addSubViews()
        layout()
        configureQuestion()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setup() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func addSubViews() {
        addSubview(questionLabel)
        addSubview(answersStackView)
    }
    
    private func layout() {
        questionLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        answersStackView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func configureQuestion() {
        questionLabel.text = question.text
        for answer in question.answers {
            let answerView = createAnswerView(for: answer)
            answersStackView.addArrangedSubview(answerView)
        }
    }
    
    @objc private func answerTapped(_ sender: UITapGestureRecognizer) {
        guard let answerView = sender.view,
              let stackView = answerView.superview as? UIStackView,
              let descriptionLabel = stackView.arrangedSubviews.last as? UILabel,
              let index = answersStackView.arrangedSubviews.firstIndex(of: stackView),
              let answerLabel = answerView.subviews.first(where: { $0 is UILabel }) as? UILabel else { return }

        let answer = question.answers[index]
        
        if selectedAnswers.contains(where: { $0.response == answer.response }) {
            return
        }

        selectedAnswers.append(answer)
        
        answerView.backgroundColor = answer.isCorrect ? CustomColors.greenCorrectAnswer : CustomColors.redIncorrectAnswer
        answerLabel.textColor = CustomColors.softAppColor
        descriptionLabel.isHidden = false
        
        checkIfCanContinue()
    }

    private func checkIfCanContinue() {
        let correctAnswers = question.answers.filter { $0.isCorrect }
        let allCorrectSelected = correctAnswers.allSatisfy { correct in
            selectedAnswers.contains { $0.response == correct.response }
        }
        
        if allCorrectSelected {
            disableUnselectedAnswers()
            showCorrectAnimation()
            saveProgress()
        }
    }
    
    private func disableUnselectedAnswers() {
        for subview in answersStackView.arrangedSubviews {
            if let answerView = subview.subviews.first {
                answerView.isUserInteractionEnabled = false
            }
        }
    }
    
    private func showCorrectAnimation() {
        self.showSalute(in: self)
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = CustomColors.backgroundForCell
        }) { _ in
            UIView.animate(withDuration: 2.5) {
                self.backgroundColor = .clear
                self.layer.borderColor = CustomColors.backgroundForCell.cgColor
            }
        }
    }
    
    private func saveProgress() {
        question.userAnswered = true
        question.userAnswer = selectedAnswers
        print("Прогресс сохранен. Ответы: \(selectedAnswers.map { $0.response })")
    }

    private func createAnswerView(for answer: Answer) -> UIStackView {
        let answerView = UIView()
        answerView.backgroundColor = CustomColors.backgroundForCell //.darkGray
        answerView.layer.cornerRadius = 10
        answerView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(answerTapped(_:)))
        answerView.addGestureRecognizer(tapGesture)
        
        let answerLabel = UILabel()
        answerLabel.text = answer.response
        answerLabel.font = UIFont(name: "Avenir", size: 18)
        answerLabel.textColor = CustomColors.generalTextColor
        answerLabel.numberOfLines = 0
        answerLabel.lineBreakMode = .byWordWrapping
        answerLabel.textAlignment = .center
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = answer.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = CustomColors.secondaryTextColor
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textAlignment = .center
        descriptionLabel.isHidden = true
        
        answerView.addSubview(answerLabel)
        
        answerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)  // ✅ Убираем фиксированную высоту
        }
        
        let stackView = UIStackView(arrangedSubviews: [answerView, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        return stackView
    }
}

extension QuestionView {
    private func createLayer(at point: CGPoint) {
        let layer = CAEmitterLayer()
        layer.emitterPosition = point
     
        let cell = CAEmitterCell()
        cell.scale = 0.09
        cell.emissionRange = .pi * 2
        cell.lifetime = 4
        cell.birthRate = 3
        cell.velocity = 75
        cell.contents = UIImage(named: "coin")!.cgImage
        cell.spin = CGFloat(Double.pi)
        cell.spinRange = CGFloat(Double.pi)
        layer.emitterCells = [cell]
        
        self.layer.addSublayer(layer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            layer.removeFromSuperlayer()
        }
    }
    
    private func showSalute(in screen: UIView) {
        let screenBounds = screen.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        createLayer(at: CGPoint(x: Int(screenWidth)/2, y: Int(screenHeight)/2))
    }
}
