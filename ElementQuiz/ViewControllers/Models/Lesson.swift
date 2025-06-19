//
//  Lesson.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.02.2025.
//

import Foundation
final class Lesson: Codable {
    let number: Double
    let name: String
    let lessonImageName: String
    let structure: [LessonContent]
    private var isCompleted: Bool
    
    init(number: Double, name: String, lessonImageName: String, structure: [LessonContent], isCompleted: Bool) {
        self.number = number
        self.name = name
        self.lessonImageName = lessonImageName
        self.structure = structure
        self.isCompleted = isCompleted
    }
    
    enum CodingKeys: String, CodingKey {
        case number
        case name
        case lessonImageName = "lesson_image_name"
        case structure
        case isCompleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.number = try container.decode(Double.self, forKey: .number)
        self.name = try container.decode(String.self, forKey: .name)
        self.lessonImageName = try container.decode(String.self, forKey: .lessonImageName)
        self.structure = try container.decode([LessonContent].self, forKey: .structure)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    }
      
    func reset() {
        isCompleted = false
    }
}

enum LessonContent: Codable {
    case headerText(String)
    case text(String)
    case image(String)
    case question(Question)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    private enum ContentType: String, Codable {
        case headerText
        case text
        case image
        case question
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        
        switch type {
        case .headerText:
            let value = try container.decode(String.self, forKey: .value)
            self = .headerText(value)
        case .text:
            let value = try container.decode(String.self, forKey: .value)
            self = .text(value)
        case .image:
            let value = try container.decode(String.self, forKey: .value)
            self = .image(value)
        case .question:
            let value = try container.decode(Question.self, forKey: .value)
            self = .question(value)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .headerText(let value):
            try container.encode(ContentType.headerText, forKey: .type)
            try container.encode(value, forKey: .value)
        case .text(let value):
            try container.encode(ContentType.text, forKey: .type)
            try container.encode(value, forKey: .value)
        case .image(let value):
            try container.encode(ContentType.image, forKey: .type)
            try container.encode(value, forKey: .value)
        case .question(let value):
            try container.encode(ContentType.question, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

extension Lesson {    
    static func getMockLessonsFromJSON() -> [Lesson] {
        guard let url = Bundle(for: self).url(forResource: "LessonsJSON", withExtension: "json") else {
            print("Couldn't find LessonsJSON.json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            var lessons = try decoder.decode([Lesson].self, from: data)
            lessons.sort { $0.number < $1.number }
            return lessons
        } catch {
            print("Error of loading or decoding data: \(error)")
            return []
        }
    }
    
    static func getMockReactionsFromJSON() -> [Lesson] {
        guard let url = Bundle(for: self).url(forResource: "ReactionsJSON", withExtension: "json") else {
            print("Couldn't find ReactionsJSON.json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            var lessons = try decoder.decode([Lesson].self, from: data)
            lessons.sort { $0.number < $1.number }
            return lessons
        } catch {
            print("Error of loading or decoding data: \(error)")
            return []
        }
    }
}
