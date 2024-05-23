//
//  QuestionFactory.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 23.05.2024.
//

import Foundation

final class QuestionFactory {
    //MARK: - Memorizing & Big Game
    static func getVariantsOfAnswers(currentQuestionType: QuestionAbout, currentElement: ChemicalElementModel, allElements fixedElementList: [ChemicalElementModel]) -> Set<String> {
        switch currentQuestionType {
        case .latinNameQuestion:
            var variants: Set<String> = [currentElement.latinName]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.latinName)
            }
            return variants
        case .commonNameQuestion:
            var variants: Set<String> = [currentElement.name]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.name)
            }
            return variants
        case .atomicMassQuestion:
            var variants: Set<String> = [String(format: "%.3f", currentElement.atomicMass)]
            while (variants.count < 4) {
                variants.insert(String(format: "%.3f", fixedElementList.randomElement()!.atomicMass))
            }
            return variants
        case .orderNumberQuestion:
            var variants: Set<String> = [String(currentElement.number)]
            while (variants.count < 4) {
                variants.insert(String(fixedElementList.randomElement()!.number))
            }
            return variants
        case .categoryQuestion:
            var variants: Set<String> = [currentElement.category]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.category)
            }
            return variants
        case .densityQuestion:
            var variants: Set<String> = []
            if currentElement.density != -1.0 {
                variants.insert(String(currentElement.density))
            } else {
                variants.insert("unknown")
            }
            
            while (variants.count < 4) {
                let randomElementDensity = fixedElementList.randomElement()!.density
                if randomElementDensity != -1.0 {
                    variants.insert(String(randomElementDensity))
                } else {
                    variants.insert("unknown")
                }
            }
            return variants
        case .periodQuestion:
            var variants: Set<String> = [String(currentElement.period)]
            while (variants.count < 4) {
                variants.insert(String(fixedElementList.randomElement()!.period))
            }
            return variants
        case .groupQuestion:
            var variants: Set<String> = [String(currentElement.group)]
            while (variants.count < 4) {
                variants.insert(String(fixedElementList.randomElement()!.group))
            }
            return variants
        case .phaseQuestion:
            var variants: Set<String> = [currentElement.phase, "Plasma"]
            while (variants.count < 4) {
                variants.insert(fixedElementList.randomElement()!.phase)
            }
            return variants
        case .boilingPointQuestion:
            var variants: Set<String> = []
            if let boilText = currentElement.boil {
                let boil = Float(boilText) != nil ? Float(boilText) : nil
                if let boil = boil {
                    variants.insert("\(boilText) K / " + String(format: "%.2f", boil - 273.15) + " C")
                } else {
                    fatalError("can't change string to float from boil of the element when getVariantsOfAnswers() run (for correct answer)")
                }
            } else {
                variants.insert("none")
            }
            
            while (variants.count < 4) {
                if let boilRandomElementText = fixedElementList.randomElement()!.boil {
                    let boil = Float(boilRandomElementText) != nil ? Float(boilRandomElementText) : nil
                    if let boil = boil {
                        variants.insert("\(boilRandomElementText) K / " + String(format: "%.2f", boil - 273.15) + " C")
                    } else {
                        fatalError("can't change string to float from boil of the element when getVariantsOfAnswers() run")
                    }
                } else {
                    variants.insert("none")
                }
            }
            return variants
        case .meltQuestion:
            var variants: Set<String> = []
            if let meltText = currentElement.melt {
                let melt = Float(meltText) != nil ? Float(meltText) : nil
                if let melt = melt {
                    variants.insert("\(meltText) K / " + String(format: "%.2f", melt - 273.15) + " C")
                } else {
                    fatalError("can't change string to float from melt of the element when getVariantsOfAnswers() run (for correct answer)")
                }
            } else {
                variants.insert("none")
            }
            
            while (variants.count < 4) {
                if let meltRandomElementText = fixedElementList.randomElement()!.melt {
                    let melt = Float(meltRandomElementText) != nil ? Float(meltRandomElementText) : nil
                    if let melt = melt {
                        variants.insert("\(meltRandomElementText) K / " + String(format: "%.2f", melt - 273.15) + " C")
                    } else {
                        fatalError("can't change string to float from melt of the element when getVariantsOfAnswers() run")
                    }
                } else {
                    variants.insert("none")
                }
            }
            return variants
        }
    }
    
    static func getVariantsOfQuestion(currentQuestionType: QuestionAbout) -> String {
        switch currentQuestionType {
        case .latinNameQuestion:
            return "Latin name of this element is"
        case .commonNameQuestion:
            return "The common name for this element is"
        case .atomicMassQuestion:
            return "The atomic mass of this element is equal to"
        case .orderNumberQuestion:
            return "Order number of this element in the periodic table is"
        case .categoryQuestion:
            return "This element categorized as"
        case .densityQuestion:
            return "The density of this element in \ng/cm3 is equal to"
        case .periodQuestion:
            return "The period number of an element is"
        case .groupQuestion:
            return "The group number of the element is"
        case .phaseQuestion:
            return "Phase of this element is"
        case .boilingPointQuestion:
            return "Boiling point of this element is equal to"
        case .meltQuestion:
            return "Melting point of this element is equal to"
        }
    }
    
    static func getCorrectAnswer(currentQuestionType: QuestionAbout, currentElement: ChemicalElementModel) -> String {
        switch currentQuestionType {
        case .latinNameQuestion:
            return currentElement.latinName
        case .commonNameQuestion:
            return currentElement.name
        case .atomicMassQuestion:
            return String(format: "%.3f", currentElement.atomicMass)
        case .orderNumberQuestion:
            return String(currentElement.number)
        case .categoryQuestion:
            return currentElement.category
        case .densityQuestion:
            return currentElement.density != -1.0 ? String(currentElement.density) : "unknown"
        case .periodQuestion:
            return String(currentElement.period)
        case .groupQuestion:
            return String(currentElement.group)
        case .phaseQuestion:
            return currentElement.phase
        case .boilingPointQuestion:
            var resultString = ""
            if let boilText = currentElement.boil {
                let boil = Float(boilText) != nil ? Float(boilText) : nil
                if let boil = boil {
                    resultString = "\(boilText) K / " + String(format: "%.2f", boil - 273.15) + " C"
                } else {
                    fatalError("can't change string to float from boil of the element when getCorrectAnswer() run")
                }
            } else {
                resultString = "none"
            }
            return resultString
        case .meltQuestion:
            var resultString = ""
            if let meltText = currentElement.melt {
                let melt = Float(meltText) != nil ? Float(meltText) : nil
                if let melt = melt {
                    resultString = "\(meltText) K / " + String(format: "%.2f", melt - 273.15) + " C"
                } else {
                    fatalError("can't change string to float from melt of the element when getCorrectAnswer() run")
                }
            } else {
                resultString = "none"
            }
            return resultString
        }
    }
    
    //MARK: - Category Test
    static func getVariantsOfAnswersForCategoryTest(currentCorrectElement: ChemicalElementModel, incorrectElements: [ChemicalElementModel]) -> Set<String> {
            var variants: Set<String> = [currentCorrectElement.name]
            while (variants.count < 4) {
                variants.insert(incorrectElements.randomElement()!.name)
            }
            return variants
    }
    
    static func getVariantsOfQuestionForCategoryTest(currentCategory: String) -> String {
        return "Chose element from \n\(currentCategory) category"
    }
    
    static func getCorrectAnswerForCategoryTest(currentCorrectElement: ChemicalElementModel) -> String {
        return currentCorrectElement.name
    }
}
