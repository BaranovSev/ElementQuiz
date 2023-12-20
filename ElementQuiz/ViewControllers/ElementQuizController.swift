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

final class ElementQuizController: UIViewController, UITextFieldDelegate {
    // MARK: - @IBOutlets
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var elementIcon: ElementIconView!
    @IBOutlet var answerButtons: [UIButton]!
    
    // MARK: - Variables
    let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
//    let fixedElementList: [ChemicalElementModelJSON] = Bundle.main.decode(file: "PeriodicTableJSON.json")
    var dataElementList: [ChemicalElementModel]?
    var dataSource: ElementQuizDataSource?
    var elementList: [ChemicalElementModel] = []
    var currentElementIndex = 0
    var mode: Mode = .flashCard {
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            
            refreshUI()
        }
    }
    var state: State = .question
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
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
        
        refreshUI()
    }
    
    @IBAction func next(_ sender: UIButton) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                refreshUI()
                return
            }
        }
        state = .question
        
        refreshUI()
    }
    
    @IBAction func answerBtnPressed(_ sender: UIButton) {
        guard let userAnswer = sender.titleLabel?.text?.lowercased() else { return }
        answerBtnShouldReturn(answer: userAnswer)
    }
    
    // MARK: - Functions
    private func updateFlashCardUI(_ elementName: String) {
        for button in answerButtons {
            button.isHidden = true
        }

        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        modeSelector.selectedSegmentIndex = 0
        
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
    }
    
    private func updateQuizUI(_ elementName: String) {
        modeSelector.selectedSegmentIndex = 1
        
        // Answer buttons
        switch state {
        case .question:
            var names: Set<String> = [elementName]
            
            while (names.count < 4) {
                names.insert(fixedElementList.randomElement()!.name)
            }
            
            let randomNames: [String] = names.shuffled()
            var localIndex = 0
            for button in answerButtons {
                button.isHidden = false
                button.isEnabled = true
                button.setTitle(randomNames[localIndex], for: .normal)
                localIndex += 1
            }
            
        case .answer:
            for button in answerButtons {
                button.isEnabled = false
            }
        case .score:
            for button in answerButtons {
                button.isHidden = true
            }
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
    
    private func setUp() {
        dataSource = ElementQuizDataSource()
    }
    
    private func refreshUI() {
        let currentElement = elementList[currentElementIndex]
        let elementName = currentElement.name
        
        elementIcon.displayItem = dataSource?.elementToDisplayItem(currentElement)
        
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
    
    // MARK: - UITextFieldDelegate methods / Main logic when answer button pressed
    func answerBtnShouldReturn(answer: String){
        
        if answer == elementList[currentElementIndex].name.lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        state = .answer
        
        refreshUI()
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
}

