//
//  Lesson.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.02.2025.
//

import Foundation
final class Lesson {
    enum LessonContent {
        case headerText(String)
        case text(String)
        case image(String)
        case question(Question)
    }
    
    let number: Int
    let name: String
    let structure: [LessonContent] // Массив, содержащий элементы урока
    private var currentIndex: Int // Индекс текущего элемента, с которого был начат урок
    private var isCompleted: Bool // Флаг завершенности урока
    private let textOfLesson: [String]
    private let imagesName: [String]
    private let questions: [Question]
    var questionsCount: Int {
        return questions.count
    }
    
    init(number: Int, name: String, structure: [LessonContent], currentIndex: Int, isCompleted: Bool, textOfLesson: [String], imagesName: [String], questions: [Question]) {
        self.number = number
        self.name = name
        self.structure = structure
        self.currentIndex = currentIndex
        self.isCompleted = isCompleted
        self.textOfLesson = textOfLesson
        self.imagesName = imagesName
        self.questions = questions
    }
    
    func nextElement() -> LessonContent? {
        if currentIndex < structure.count {
            let element = structure[currentIndex]
            currentIndex += 1
            return element
        } else {
            //TODO: true after clicking big button? in another func?
            isCompleted = true
            currentIndex = 0
            return nil
        }
    }
    
    func reset() {
        currentIndex = 0
        isCompleted = false
    }
}

extension Lesson {
    static func getMockLesson() -> Lesson {
        let answer1 = Answer(response: "Ответ 1", description: "Это первый вариант ответа. Не правильный.", isCorrect: false)
        let answer2 = Answer(response: "Ответ 2", description: "Это второй вариант ответа и он правильный.", isCorrect: true)
        let answer3 = Answer(response: "Ответ 3", description: "Это третий вариант ответа и он правильный.", isCorrect: true)
        let answer4 = Answer(response: "Ответ 4, длинный, Ответ 4, длинный, Ответ 4, длинный, Ответ 4, длинный, Ответ 4, длинный, Ответ 4, длинный, Ответ 4, длинный, Ответ 4, длинный, Ответ 4", description: "Это четвертый вариант ответа и он правильный... а еще он ОЧЕНЬ оооооооо ооооооооооооо ооооочень длинный, ну прям очень.", isCorrect: true)
        let question1 = Question(text: "1Какой ответ правильный?", answers: [answer1, answer2])
        let question2 = Question(text: "2Какой ответ правильный?", answers: [answer1, answer2])
        let question3 = Question(text: "3Какой ответ правильный? Eще он ОЧЕНЬ оооооооооооооооооооооооооочень длинный, ну прям очень.", answers: [answer1, answer2, answer3, answer4])
        let questions = [question1, question2, question3]
        let textArray = ["textlong1 te xtlong1textlong1text long1textlong 1te xtlong1tex tlong1textl ong1textlong1te xtlong1 textlon g1textlon g1textlon g1textlong1 textlong1textl ong1textlong1tex tlong1textl ong1te xtlong1te xtlong1te xtlong1textlon g1textlong1textlo ng1textlong1text long1textlong1text long1textlong1 textlong1textlong 1textlong1textlong 1textlong1 textlong1te xtlong1textl ong1tex tlong1te xtlong1te xtlong1t extlon g1text long1t extlong 1textlon g1textl ong1text long1tex tlong1","textlong2","textlong3"]
        let imageNamesArray = ["coin","caesar_games","coin"]
        let lessonMockName = "MockName Name Name Name Name"
        let mockStructure: [LessonContent] = [.headerText(lessonMockName), .text(textArray[0]), .image(imageNamesArray[0]), .text(textArray[1]), .image(imageNamesArray[1]), .text(textArray[2]), .image(imageNamesArray[2]), .question(questions[0]), .question(questions[1]), .question(questions[2])]
        
        return Lesson(number: 1,
                      name: lessonMockName,
                      structure: mockStructure,
                      currentIndex: 0,
                      isCompleted: false,
                      textOfLesson: textArray,
                      imagesName: imageNamesArray,
                      questions: questions
        )
    }
}
