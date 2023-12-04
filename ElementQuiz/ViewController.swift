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

class ViewController: UIViewController, UITextFieldDelegate {
    // MARK: - @IBOutlets
    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var modeSelector: UISegmentedControl!
    @IBOutlet var textField: UITextField!
    @IBOutlet var showAnswerButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    // MARK: - Variables
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    let allElements: [ChemicalElement] = Bundle.main.decode(file: "PeriodicTableJSON.json")
    var elementList: [String] = []
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
        print(allElements.count)
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
    func updateFlashCardUI(_ elementName: String) {
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
    
    func updateQuizUI(_ elementName: String) {
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
    
    func updateUI() {
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName)
        case .quiz:
            updateQuizUI(elementName)
        }
    }
    
    // Sets up a new flash card session.
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
     
    // Sets up a new quiz.
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        elementList = fixedElementList.shuffled()
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldContents = textField.text!
        
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
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
    func displayScoreAlert() {
        let alert = UIAlertController(title:"Quiz Score",
                                      message: "Your score is \(correctAnswerCount) out of \(elementList.count).",
                                      preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: scoreAlertDismissed(_:)
        )
        
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
}

