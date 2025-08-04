//
//  Lesson+CoreDataProperties.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 26.02.2025.
//
//

import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var number: Double
    @NSManaged public var name: String
    @NSManaged public var structure: [NSObject]
    @NSManaged public var isCompleted: Bool

}

extension Lesson : Identifiable {

}
