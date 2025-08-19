//
//  CongratulationViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 11.04.2024.
//

import UIKit
import SnapKit

enum TypeOfGame {
    case elementMemorizing
    case categoryTest
    case bigGame
}

protocol ShowCongratulationProtocol {
    func showCongratulationViewController()
    func selfDismiss()
}

final class CongratulationViewController: UIViewController {
    private let totalQuestions, correctAnswers: Int?
    private let delegate: ShowCongratulationProtocol
    private let describeOfSense: String
    private let imageName: String?
    

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            congratulationLabel,
            youLearnedLabel,
            imageView,
            countOfLearnedElementsLabel,
            chemicalElementsLabel,
            bigButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.setCustomSpacing(35, after: chemicalElementsLabel)
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let congratulationLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 75)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        label.textColor = CustomColors.secondaryTextColor
        return label
    }()
    
    private let youLearnedLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 35)
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let countOfLearnedElementsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 75)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = CustomColors.secondaryTextColor
        return label
    }()
    
    private let chemicalElementsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 35)
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 3
        return label
    }()
    
    private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            return imageView
    }()
    
    private let bigButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        button.backgroundColor = CustomColors.bigButtonColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(Self.dismissCurrentAndDelegateController), for: .touchUpInside)
        return button
    }()
    
    init(totalQuestions: Int? = nil, correctAnswers: Int? = nil, delegate: ShowCongratulationProtocol, describeOfSense: String) {
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.delegate = delegate
        self.describeOfSense = describeOfSense
        self.imageName = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(delegate: ShowCongratulationProtocol, describeOfSense: String, imageName: String? = nil) {
        self.totalQuestions = nil
        self.correctAnswers = nil
        self.delegate = delegate
        self.describeOfSense = describeOfSense
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        addSubViews()
        layout()
    }
    
    private func setup() {
        view.backgroundColor = CustomColors.generalAppFont
        var goodResult: Bool = true
        var correctAnswersText = ""
        var totalQuestionsText = ""
        if let correctAnswers = correctAnswers, let totalQuestions = totalQuestions {
            goodResult = Double(correctAnswers) / Double(totalQuestions) >= 0.6
            correctAnswersText = String(correctAnswers)
            totalQuestionsText = String(totalQuestions)
        }
        
        if goodResult {
            showSalute()
        }
        
        if goodResult {
            congratulationLabel.text = [
                "Well done!",
                "Congratulations!",
                "Great job!",
                "Keep up the good work!",
                "Awesome achievement!",
                "Bravo!",
                "Fantastic progress!",
                "Outstanding performance!",
                "Superb effort!",
                "You nailed it!"
            ].shuffled().first
        } else {
            congratulationLabel.text = [
                "We believe in you",
                "Keep practicing",
                "Keep learning",
                "Give it another shot",
                "Keep improving"
            ].shuffled().first
        }
        
        if let imageName = imageName {
            guard let image = UIImage(named: imageName) else { return }
            imageView.image = image.withRoundedCorners(inPercentageFromSmallestSide: 5)
            mainStackView.removeArrangedSubview(countOfLearnedElementsLabel)
            mainStackView.removeArrangedSubview(chemicalElementsLabel)
        } else {
            mainStackView.removeArrangedSubview(imageView)
        }

        
        switch delegate {
        case _ as ElementMemorizingController:
            if goodResult {
                youLearnedLabel.text = "You learned all about\n\(describeOfSense)\nand correctly answered"
            } else {
                youLearnedLabel.text = "We recommend revisiting\nthe \(describeOfSense) study again\nYou correctly answered"
            }
            countOfLearnedElementsLabel.text = "\(correctAnswersText)"
            chemicalElementsLabel.text = "from \(totalQuestionsText) questions"
        case _ as CategoryTestViewController:
            youLearnedLabel.text = "In the \(describeOfSense) category knowledge test\n You gave"
            countOfLearnedElementsLabel.text = "\(correctAnswersText)"
            chemicalElementsLabel.text = "correct answers out of \(totalQuestionsText) questions"
        case _ as BigGameViewController:
            youLearnedLabel.text = "You heroically made it through the Big Game by responding"
            countOfLearnedElementsLabel.text = "\(correctAnswersText)"
            chemicalElementsLabel.text = "from \(totalQuestionsText) questions"
        case _ as LessonViewController:
            youLearnedLabel.text = "\(describeOfSense)"
        default:
            youLearnedLabel.text = "You answered"
            countOfLearnedElementsLabel.text = "\(correctAnswersText)"
            chemicalElementsLabel.text = "from \(totalQuestionsText)"
        }
    }
    
    private func addSubViews() {
        view.addSubview(mainStackView)
    }
    
    private func layout() {
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-25)
        }
        
        bigButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(200)
        }
    }
    
    private func createLayer(at point: CGPoint) {
        let layer = CAEmitterLayer()
        layer.emitterPosition = point
     
        let cell = CAEmitterCell()
        cell.scale = 0.1
        cell.emissionRange = .pi * 2
        cell.lifetime = 20
        cell.birthRate = 7
        cell.velocity = 10
        cell.contents = UIImage(named: "mystar")!.cgImage
        cell.color = CustomColors.salutteColor.cgColor
        layer.emitterCells = [cell]
        
        view.layer.addSublayer(layer)
    }
    
    private func showSalute() {
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        createLayer(at: CGPoint(x: 0, y: Int(screenHeight) + 10))
        createLayer(at: CGPoint(x: Int(screenWidth)/2, y: Int(screenHeight) + 10))
        createLayer(at: CGPoint(x: Int(screenWidth), y: Int(screenHeight) + 10))
    }
    
    @objc func dismissCurrentAndDelegateController() {
        self.dismiss(animated: false)
        delegate.selfDismiss()
    }
}
