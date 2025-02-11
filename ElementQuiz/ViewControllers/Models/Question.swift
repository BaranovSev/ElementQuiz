//
//  Question.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.02.2025.
//

import Foundation

final class Question {
    var text: String
    var answers: [Answer]
    var userAnswered: Bool
    var userAnswer: [Answer]
    
    init(text: String, answers: [Answer]) {
        self.text = text
        self.answers = answers
        self.userAnswered = false
        self.userAnswer = []
    }
}
