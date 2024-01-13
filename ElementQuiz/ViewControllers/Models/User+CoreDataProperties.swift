//
//  User+CoreDataProperties.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 26.12.2023.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var learnedChemicalElements: NSSet?

}

// MARK: Generated accessors for learnedChemicalElements
extension User {

    @objc(addLearnedChemicalElementsObject:)
    @NSManaged public func addToLearnedChemicalElements(_ value: ChemicalElementModel)

    @objc(removeLearnedChemicalElementsObject:)
    @NSManaged public func removeFromLearnedChemicalElements(_ value: ChemicalElementModel)

    @objc(addLearnedChemicalElements:)
    @NSManaged public func addToLearnedChemicalElements(_ values: NSSet)

    @objc(removeLearnedChemicalElements:)
    @NSManaged public func removeFromLearnedChemicalElements(_ values: NSSet)

}

extension User : Identifiable {

}
