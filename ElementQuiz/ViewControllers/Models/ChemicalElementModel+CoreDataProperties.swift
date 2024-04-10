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

enum ElementParameters: String {
    case atomicMass = "atomicMass"
    case density = "density"
    case category = "category"
    case latinName = "latinName"
    case phase = "phase"
    case block = "block"
    case valency = "valency"
    case boil = "boil"
    case melt = "melt"
    case molarHeat = "molarHeat"
    case group = "group"
    case period = "period"
    case elecrtonAffinity = "electronAffinity"
    case electronegativityPauling = "electronegativityPauling"
    case oxidationDegree = "oxidationDegre"
    case elecronConfiguration = "elecronConfiguration"
    case elecronConfigurationSemantic = "elecronConfigurationSemantic"
    case shells = "shells"
    case ionizationEnergies = "ionizationEnergies"
    case discovered = "discovered"
    case named = "named"
    case appearance = "appearance"
    
    static var allValues: [String] {
        return [
            self.atomicMass.rawValue,
            self.density.rawValue,
            self.category.rawValue,
            self.latinName.rawValue,
            self.phase.rawValue,
            self.block.rawValue,
            self.valency.rawValue,
            self.boil.rawValue,
            self.melt.rawValue,
            self.molarHeat.rawValue,
            self.group.rawValue,
            self.period.rawValue,
            self.elecrtonAffinity.rawValue,
            self.electronegativityPauling.rawValue,
            self.oxidationDegree.rawValue,
            self.elecronConfiguration.rawValue,
            self.elecronConfigurationSemantic.rawValue,
            self.shells.rawValue,
            self.ionizationEnergies.rawValue,
            self.discovered.rawValue,
            self.named.rawValue,
            self.appearance.rawValue
        ]
    }
    
    func descriptionHumanReadable() -> String {
        switch self {
        case .atomicMass:
            return "Atomic mass"
        case .density:
            return "Density"
        case .category:
            return "Category"
        case .latinName:
            return "Latin name"
        case .phase:
            return "Phase"
        case .valency:
            return "Valency"
        case .boil:
            return "Boil temperature"
        case .melt:
            return "Melt temperature"
        case .molarHeat:
            return "Molar heat"
        case .group:
            return "Group"
        case .period:
            return "Period"
        case .elecrtonAffinity:
            return "Electron affinity"
        case .electronegativityPauling:
            return "Elecronegativity by Pauling"
        case .oxidationDegree:
            return "Oxidation degree"
        case .elecronConfiguration:
            return "Electron configuration"
        case .elecronConfigurationSemantic:
            return "Electron configuration (semantic)"
        case .shells:
            return "Shells"
        case .ionizationEnergies:
            return "Ionization energies"
        case .discovered:
            return "Discovered"
        case .named:
            return "Named"
        case .appearance:
            return "Appearance"
        case .block:
            return "Block"
        }
    }
}
