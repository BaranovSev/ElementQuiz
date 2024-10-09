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
    func showCongratulationViewController(totalQuestions: Int, correctAnswers: Int, fromViewControllerDelegate: ShowCongratulationProtocol, describeOfSense: String)
    func selfDismiss()
}

final class CongratulationViewController: UIViewController {
    private let totalQuestions, correctAnswers: Int
    private let delegate: ShowCongratulationProtocol
    private let describeOfSense: String
    

    
    private lazy var congratulationLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 75)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        label.textColor = CustomColors.secondaryTextColor
        return label
    }()
    
    private lazy var youLearnedLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 35)
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var countOfLearnedElementsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 75)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = CustomColors.secondaryTextColor
        return label
    }()
    
    private lazy var chemicalElementsLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Hoefler Text", size: 35)
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var bigButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        button.backgroundColor = CustomColors.purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(Self.dismissCurrentAndDelegateController), for: .touchUpInside)
        return button
    }()
    
    init(totalQuestions: Int, correctAnswers: Int, delegate: ShowCongratulationProtocol, describeOfSense: String) {
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.delegate = delegate
        self.describeOfSense = describeOfSense
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
        view.backgroundColor = CustomColors.generalAppPhont
        let goodResult: Bool = Double(correctAnswers) / Double(totalQuestions) >= 0.6
        
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

        
        switch delegate {
        case _ as ElementMemorizingController:
            if goodResult {
                youLearnedLabel.text = "You learned all about\n\(describeOfSense)\nand correctly answered"
            } else {
                youLearnedLabel.text = "We recommend revisiting\nthe \(describeOfSense) study again\nYou correctly answered"
            }
            countOfLearnedElementsLabel.text = "\(correctAnswers)"
            chemicalElementsLabel.text = "from \(totalQuestions) questions"
        case _ as CategoryTestViewController:
            youLearnedLabel.text = "In the \(describeOfSense) category knowledge test\n You gave"
            countOfLearnedElementsLabel.text = "\(correctAnswers)"
            chemicalElementsLabel.text = "correct answers out of \(totalQuestions) questions"
        case _ as BigGameViewController:
            youLearnedLabel.text = "You heroically made it through the Big Game by responding"
            countOfLearnedElementsLabel.text = "\(correctAnswers)"
            chemicalElementsLabel.text = "from \(totalQuestions) questions"
        default:
            youLearnedLabel.text = "You answered"
            countOfLearnedElementsLabel.text = "\(correctAnswers)"
            chemicalElementsLabel.text = "from \(totalQuestions)"
        }
    }
    
    private func addSubViews() {
        view.addSubview(congratulationLabel)
        view.addSubview(youLearnedLabel)
        view.addSubview(countOfLearnedElementsLabel)
        view.addSubview(chemicalElementsLabel)
        view.addSubview(bigButton)
    }
    
    private func layout() {
        congratulationLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-15)
            make.centerX.equalToSuperview()
        }
        
        youLearnedLabel.snp.makeConstraints { make in
            make.top.equalTo(congratulationLabel.snp.bottom).offset(25)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-15)
            make.centerX.equalToSuperview()
        }
        
        countOfLearnedElementsLabel.snp.makeConstraints { make in
            make.top.equalTo(youLearnedLabel.snp.bottom).offset(5)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-15)
            make.centerX.equalToSuperview()
        }
        
        chemicalElementsLabel.snp.makeConstraints { make in
            make.top.equalTo(countOfLearnedElementsLabel.snp.bottom).offset(5)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-15)
            make.centerX.equalToSuperview()
        }
        
        bigButton.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.top.greaterThanOrEqualTo(chemicalElementsLabel.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
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
        cell.color = CustomColors.gold.cgColor
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
