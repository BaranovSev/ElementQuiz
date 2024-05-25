//
//  gameProtocol.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 28.03.2024.
//

import Foundation

protocol GameProtocol {
    func getVariantsOfAnswers() -> Set<String>
    func getVariantsOfQuestion() -> String
    func getCorrectAnswer() -> String
    func checkAnswer(_ answer: String)
}

