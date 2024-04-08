//
//  Int+extensions.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 07.04.2024.
//

import Foundation
extension Int {
    func toRoman() -> String {
        var result = ""
        
        switch self {
        case 0:
            result = "O"
        case 1:
            result = "I"
        case 2:
            result = "II"
        case 3:
            result = "III"
        case 4:
            result = "IV"
        case 5:
            result = "V"
        case 6:
            result = "VI"
        case 7:
            result = "VII"
        case 8:
            result = "VIII"
        case 9:
            result = "IX"
        case 10:
            result = "X"
        default:
            break
        }
        
        return result
    }
}
