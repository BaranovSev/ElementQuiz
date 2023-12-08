//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 07.11.2023.
//

import UIKit

enum Mode {
    case flashCard
    case quiz
}

enum State {
    case question
    case answer
    case score
}

final class ViewController: UIViewController, UITextFieldDelegate {
    // MARK: - @IBOutlets
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var elementIcon: ElementIconView!
    
    // MARK: - Variables
    let fixedElementList: [ChemicalElement] = Bundle.main.decode(file: "PeriodicTableJSON.json")
    var elementList: [ChemicalElement] = []
    var currentElementIndex = 0
    var mode: Mode = .flashCard {
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            
            updateUI()
        }
    }
    var state: State = .question
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
    }
    
    // MARK: - @IBActions
    @IBAction func switchModes(_ sender: UISegmentedControl) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    @IBAction func showAnswer(_ sender: UIButton) {
        state = .answer
        
        updateUI()
    }
    
    @IBAction func next(_ sender: UIButton) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        
        updateUI()
    }
    
    // MARK: - Functions
    private func updateFlashCardUI(_ elementName: String) {
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        textField.isHidden = true
        textField.resignFirstResponder()
        modeSelector.selectedSegmentIndex = 0
        
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
    }
    
    private func updateQuizUI(_ elementName: String) {
        modeSelector.selectedSegmentIndex = 1
        // Keyboard and tehtfield
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        // Answer label
        switch state {
        case .question:
            answerLabel.text = "?"
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
        }
        
        // Show score alert
        if state == .score {
            displayScoreAlert()
        }
        
        // Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
    }
    
    
    private func updateUI() {
        let currentElenent = elementList[currentElementIndex]
        let elementName = currentElenent.name
        let color: UIColor = choseColorForIcon(elementCategory: currentElenent.category)
        
        elementIcon.displayItem = ElementIconView.DisplayItem(
            symbolTitle: currentElenent.symbol,
            elementNumberTitle: String(currentElenent.number),
            atomicMassTitle: String(format: "%.3f", currentElenent.atomicMass),
            color: color
        )
        
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName)
        case .quiz:
            updateQuizUI(elementName)
        }
    }
    
    // Sets up a new flash card session.
    private func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
     
    // Sets up a new quiz.
    private func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        elementList = fixedElementList.shuffled()
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldContents = textField.text!
        
        if textFieldContents.lowercased() == elementList[currentElementIndex].name.lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        state = .answer
        
        updateUI()
        
        return true
    }
    
    // MARK: - Alert
    private func displayScoreAlert() {
        let alert = UIAlertController(title:"Quiz Score",
                                      message: "Your score is \(correctAnswerCount) out of \(elementList.count).",
                                      preferredStyle: .alert
        )
        
        let dismissAction = UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: scoreAlertDismissed(_:)
        )
        
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    // MARK: - Helpers
    private func choseColorForIcon(elementCategory: String) -> UIColor {
        switch elementCategory {
        case "actinide":
            return CustomColors.actinide
        case "alkali metal":
            return CustomColors.alkaliMetal
        case "alkaline earth metal":
            return CustomColors.alkalineEarthMetal
        case "diatomic nonmetal":
            return CustomColors.diatomicNonmetal
        case "lanthanide":
            return CustomColors.lanthanide
        case "metalloid":
            return CustomColors.metalloid
        case "noble gas":
            return CustomColors.nobleGas
        case "polyatomic nonmetal":
            return CustomColors.polyatomicNonmetal
        case "post-transition metal":
            return CustomColors.postTransitionMetal
        case "transition metal":
            return CustomColors.transitionMetal
        case "unknown, but predicted to be an alkali metal":
            return CustomColors.unknownAlkaliMetal
        case "unknown, predicted to be noble gas":
            return CustomColors.unknownNobleGas
        case "unknown, probably metalloid":
            return CustomColors.unknownMetalloid
        case "unknown, probably post-transition metal":
            return CustomColors.unknownpPostTransitionMetal
        case "unknown, probably transition metal":
            return CustomColors.unknownTransitionMetal
        default:
            return UIColor.black
        }
    }
}

