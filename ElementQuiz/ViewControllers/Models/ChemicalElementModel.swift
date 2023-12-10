//
//  ElementModel.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.12.2023.
//

import Foundation

struct ChemicalElementModel: Codable {
    let name: String
    let latinName: String
    let nameRu: String
    let atomicMass: Double
    let boil: Double?
    let symbol: String
    let number: Int
    let period: Int
    let group: Int
    let category: String
    let discoveredBy: String?
    let namedBy: String?
    let summary: String
    
    static let items: [ChemicalElementModel] = Bundle.main.decode(file: "PeriodicTableJSON.json")
    
    enum CodingKeys: String, CodingKey {
        case name
        case latinName = "latin_name"
        case nameRu = "name_ru"
        case atomicMass = "atomic_mass"
        case symbol
        case boil
        case number
        case period
        case group
        case category
        case discoveredBy = "discovered_by"
        case namedBy = "named_by"
        case summary
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.latinName = try container.decode(String.self, forKey: .latinName)
        self.nameRu = try container.decode(String.self, forKey: .nameRu)
        self.atomicMass = try container.decode(Double.self, forKey: .atomicMass)
        self.boil = try container.decode(Double?.self, forKey: .boil)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.number = try container.decode(Int.self, forKey: .number)
        self.period = try container.decode(Int.self, forKey: .period)
        self.group = try container.decode(Int.self, forKey: .group)
        self.category = try container.decode(String.self, forKey: .category)
        self.discoveredBy = try container.decode(String?.self, forKey: .discoveredBy)
        self.namedBy = try container.decode(String?.self, forKey: .namedBy)
        self.summary = try container.decode(String.self, forKey: .summary)
    }
}


