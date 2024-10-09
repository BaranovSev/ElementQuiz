//
//  UITextView+extension.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 28.09.2024.
//
import UIKit

extension UITextView {
    
    // Функция для плавного появления текста
    func animateText(_ text: String, withDelay delay: TimeInterval) {
        self.text = ""  // Сначала очищаем текст
        var characterIndex = 0.0
        
        for letter in text {
            // Увеличиваем индекс для следующего символа
            Timer.scheduledTimer(withTimeInterval: delay * characterIndex, repeats: false) { timer in
                self.text.append(letter)
            }
            characterIndex += 1
        }
    }
}
