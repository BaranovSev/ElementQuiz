//
//  Question.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.02.2025.
//

import Foundation

final class Question: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case text
        case answers
        case userAnswered
        case userAnswer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.answers = try container.decode([Answer].self, forKey: .answers)
        self.userAnswered = try container.decode(Bool.self, forKey: .userAnswered)
        self.userAnswer = try container.decode([Answer].self, forKey: .userAnswer)
    }
}
