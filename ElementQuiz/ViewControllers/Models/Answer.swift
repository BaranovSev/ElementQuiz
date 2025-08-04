//
//  Answer.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.02.2025.
//

import Foundation

final class Answer: Codable {
    var response: String   // Сам вариант ответа
    var description: String // Описание к варианту ответа
    var isCorrect: Bool     // Указывает, является ли ответ правильным
    
    init(response: String, description: String, isCorrect: Bool) {
        self.response = response
        self.description = description
        self.isCorrect = isCorrect
    }
    
    enum CodingKeys: String, CodingKey {
        case response
        case description
        case isCorrect
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.response = try container.decode(String.self, forKey: .response)
        self.description = try container.decode(String.self, forKey: .description)
        self.isCorrect = try container.decode(Bool.self, forKey: .isCorrect)
    }
}
