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
    @NSManaged public var learnedChemicalElements: [String:Date]
    @NSManaged public var learnedLessons: Set<Int>
    @NSManaged public var learnedReactions: Set<Int>
    @NSManaged public var preferedTheme: String
    @NSManaged public var preferedSelectorTheme: String
    @NSManaged public var wideTableOptionalParameter: String
    @NSManaged public var shortTableOptionalParameter: String
    @NSManaged public var classicTableOptionalParameter: String
    @NSManaged public var standardTableOptionalParameter: String
    @NSManaged public var searchTableOptionalParameter: String
    @NSManaged public var wideTableScaleParameter: Double
    @NSManaged public var wideOffsetX: Float
    @NSManaged public var wideOffsetY: Float
    @NSManaged public var shortTableScaleParameter: Double
    @NSManaged public var shortOffsetX: Float
    @NSManaged public var shortOffsetY: Float
    @NSManaged public var classicTableScaleParameter: Double
    @NSManaged public var classicOffsetX: Float
    @NSManaged public var classicOffsetY: Float
    @NSManaged public var standardTableScaleParameter: Double
    @NSManaged public var standardOffsetX: Float
    @NSManaged public var standardOffsetY: Float
    @NSManaged public var searchTableSelectedElements: Set<String>
    @NSManaged public var searchTableSearchedText: String
    @NSManaged public var countMemorizings: Int
    @NSManaged public var countMemorizingQuestions: Int
    @NSManaged public var countBigGames: Int
    @NSManaged public var countBigGamesQuestions: Int
}



extension User : Identifiable {

}
