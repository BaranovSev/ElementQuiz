//
//  Answer.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.02.2025.
//

import Foundation

final class Answer {
    var response: String   // Сам вариант ответа
    var description: String // Описание к варианту ответа
    var isCorrect: Bool     // Указывает, является ли ответ правильным
    
    init(response: String, description: String, isCorrect: Bool) {
        self.response = response
        self.description = description
        self.isCorrect = isCorrect
    }
}
