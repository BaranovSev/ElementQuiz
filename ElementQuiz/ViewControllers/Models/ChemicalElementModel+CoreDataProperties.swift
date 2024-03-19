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
    @NSManaged public var boil: String? // real Double?
    @NSManaged public var melt: String? // real Double?
    @NSManaged public var molarHeat: String? // real Double?
    @NSManaged public var density: String? // real Double?
    @NSManaged public var appearance: String?
    @NSManaged public var symbol: String
    @NSManaged public var number: Int16
    @NSManaged public var period: Int16
    @NSManaged public var group: Int16
    @NSManaged public var category: String
    @NSManaged public var discoveredBy: String?
    @NSManaged public var namedBy: String?
    @NSManaged public var summary: String
    @NSManaged public var phase: String
    @NSManaged public var block: String
    @NSManaged public var xpos, ypos, wxpos, wypos, cxpos, cypos: Int16
    @NSManaged public var shells: [Int]
    @NSManaged public var electronConfiguration, electronConfigurationSemantic: String
    @NSManaged public var electronAffinity, electronegativityPauling: String? // real Double?
    @NSManaged public var ionizationEnergies: [Double]
    @NSManaged public var valency: [Int]
    @NSManaged public var oxidationDegree: [Int]

}

extension ChemicalElementModel : Identifiable {

}
