//
//  ChemicalElementModel+CoreDataProperties.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 10.12.2023.
//
//

import Foundation
import CoreData


extension ChemicalElementModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChemicalElementModel> {
        return NSFetchRequest<ChemicalElementModel>(entityName: "ChemicalElementModel")
    }

    @NSManaged public var name: String
    @NSManaged public var latinName: String
    @NSManaged public var atomicMass: Double
    @NSManaged public var boil: String?
    @NSManaged public var melt: String?
    @NSManaged public var density: String?
    @NSManaged public var symbol: String
    @NSManaged public var number: Int16
    @NSManaged public var period: Int16
    @NSManaged public var group: Int16
    @NSManaged public var category: String
    @NSManaged public var discoveredBy: String?
    @NSManaged public var namedBy: String?
    @NSManaged public var summary: String
    @NSManaged public var phase: String

}

extension ChemicalElementModel : Identifiable {

}
