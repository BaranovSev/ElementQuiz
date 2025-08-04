//
//  Answer+CoreDataProperties.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 26.02.2025.
//
//

import Foundation
import CoreData


extension Answer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Answer> {
        return NSFetchRequest<Answer>(entityName: "Answer")
    }

    @NSManaged public var response: String?
    @NSManaged public var itDescription: String?
    @NSManaged public var isCorrect: Bool

}

extension Answer : Identifiable {

}
