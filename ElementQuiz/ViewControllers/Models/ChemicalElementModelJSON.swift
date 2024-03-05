//
//  ElementModel.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.12.2023.
//

import Foundation

struct ChemicalElementModelJSON: Codable {
    let name: String
    let latinName: String
//    let nameRu: String
    let atomicMass: Double
    let boil: Double?
    let melt: Double?
    let molarHeat: Double?
    let density: Double?
    let appearance: String?
    let symbol: String
    let number: Int
    let period: Int
    let group: Int
    let category: String
    let discoveredBy: String?
    let namedBy: String?
    let summary: String
    let phase: String
    let block: String
    let xpos, ypos, wxpos, wypos: Int
    let shells: [Int]
    let electronConfiguration, electronConfigurationSemantic: String
    let electronAffinity, electronegativityPauling: Double?
    let ionizationEnergies: [Double]

    static let items: [ChemicalElementModelJSON] = Bundle.main.decode(file: "PeriodicTableJSON.json")

    enum CodingKeys: String, CodingKey {
        case name
        case latinName = "latin_name"
//        case nameRu = "name_ru"
        case atomicMass = "atomic_mass"
        case symbol
        case boil
        case melt
        case number
        case period
        case group
        case category
        case discoveredBy = "discovered_by"
        case namedBy = "named_by"
        case summary
        case phase
        case density
        case molarHeat = "molar_heat"
        case xpos, ypos, wxpos, wypos, shells
        case electronConfiguration = "electron_configuration"
        case electronConfigurationSemantic = "electron_configuration_semantic"
        case electronAffinity = "electron_affinity"
        case electronegativityPauling = "electronegativity_pauling"
        case ionizationEnergies = "ionization_energies"
        case block
        case appearance
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.latinName = try container.decode(String.self, forKey: .latinName)
//        self.nameRu = try container.decode(String.self, forKey: .nameRu)
        self.atomicMass = try container.decode(Double.self, forKey: .atomicMass)
        self.boil = try container.decode(Double?.self, forKey: .boil)
        self.melt = try container.decode(Double?.self, forKey: .melt)
        self.molarHeat = try container.decode(Double?.self, forKey: .molarHeat)
        self.density = try container.decode(Double?.self, forKey: .density)
        self.appearance = try container.decode(String?.self, forKey: .appearance)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.number = try container.decode(Int.self, forKey: .number)
        self.period = try container.decode(Int.self, forKey: .period)
        self.group = try container.decode(Int.self, forKey: .group)
        self.category = try container.decode(String.self, forKey: .category)
        self.discoveredBy = try container.decode(String?.self, forKey: .discoveredBy)
        self.namedBy = try container.decode(String?.self, forKey: .namedBy)
        self.summary = try container.decode(String.self, forKey: .summary)
        self.phase = try container.decode(String.self, forKey: .phase)
        self.block = try container.decode(String.self, forKey: .block)
        self.xpos = try container.decode(Int.self, forKey: .xpos)
        self.ypos = try container.decode(Int.self, forKey: .ypos)
        self.wxpos = try container.decode(Int.self, forKey: .wxpos)
        self.wypos = try container.decode(Int.self, forKey: .wypos)
        self.shells = try container.decode([Int].self, forKey: .shells)
        self.electronConfiguration = try container.decode(String.self, forKey: .electronConfiguration)
        self.electronConfigurationSemantic = try container.decode(String.self, forKey: .electronConfigurationSemantic)
        self.electronAffinity = try container.decode(Double?.self, forKey: .electronAffinity)
        self.electronegativityPauling = try container.decode(Double?.self, forKey: .electronegativityPauling)
        self.ionizationEnergies = try container.decode([Double].self, forKey: .ionizationEnergies)
    }
}


