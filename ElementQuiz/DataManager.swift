//
//  DataManager.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 13.12.2023.
//

import UIKit
import CoreData

final class DataManager {
    enum OrderedCases: String {
        case number
        case category
        case phase
        case symbol
        case atomicMass = "atomicMass"
        case period
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let shared = DataManager()
    
    func fetchUser() -> User {
        let request = User.fetchRequest()
        
        do {
            let data = try context.fetch(request)
            let user = data.first ?? User(context: context)
            return user
        } catch {
            fatalError("Current user is missing")
        }
    }
    
    func saveUserData(from user: User) {
        let data = User(context: self.context)
        data.id = user.id
        data.learnedChemicalElements = user.learnedChemicalElements
        do {
            try self.context.save()
        } catch {
            fatalError("failure to save context \(error)")
        }
    }
    
    func fetchElements(orderedBy value: OrderedCases? = nil) -> [ChemicalElementModel] {
        let attribute = value ?? .number
        let sort = NSSortDescriptor(key: attribute.rawValue, ascending: true)
        let request = ChemicalElementModel.fetchRequest()
        request.sortDescriptors = [sort]

        do {
            var data = try context.fetch(request)
            if data.isEmpty {
                let elementsJSON: [ChemicalElementModelJSON] = Bundle.main.decode(file: "PeriodicTableJSON.json")
                saveElements(from: elementsJSON)
                data = try context.fetch(request)
            }
            
            return data
        } catch {
            fatalError("failure to get data from storage: \(error)")
        }
    }
    
    private func saveElements(from elementsJSON: [ChemicalElementModelJSON]) {
        for element in elementsJSON {
            let newElement = ChemicalElementModel(context: self.context)
            newElement.name = element.name
            newElement.latinName = element.latinName
            newElement.atomicMass = element.atomicMass
            newElement.symbol = element.symbol
            if let boil = element.boil {
                newElement.boil = "\(boil)"
            } else {
                newElement.boil = nil
            }
            
            if let melt = element.melt {
                newElement.melt = "\(melt)"
            } else {
                newElement.melt = nil
            }
            
            if let molarHeat = element.molarHeat {
                newElement.molarHeat = "\(molarHeat)"
            } else {
                newElement.molarHeat = nil
            }
            
            if let density = element.density {
                newElement.density = "\(density)"
            } else {
                newElement.density = nil
            }
            
            if let appearance = element.appearance {
                newElement.appearance = appearance
            } else {
                newElement.appearance = nil
            }
            
            newElement.number = Int16(element.number)
            newElement.period = Int16(element.period)
            newElement.group = Int16(element.group)
            newElement.category = element.category
            newElement.discoveredBy = element.discoveredBy
            newElement.namedBy = element.namedBy
            newElement.summary = element.summary
            newElement.phase = element.phase
            newElement.block = element.block
            newElement.xpos = Int16(element.xpos)
            newElement.ypos = Int16(element.ypos)
            newElement.wxpos = Int16(element.wxpos)
            newElement.wypos = Int16(element.wypos)
            newElement.shells = element.shells
            newElement.electronConfiguration = element.electronConfiguration
            newElement.electronConfigurationSemantic = element.electronConfigurationSemantic
            if let electronAffinity = element.electronAffinity {
                newElement.electronAffinity = "\(electronAffinity)"
            } else {
                newElement.electronAffinity = nil
            }
            
            if let electronegativityPauling = element.electronegativityPauling {
                newElement.electronegativityPauling = "\(electronegativityPauling)"
            } else {
                newElement.electronegativityPauling = nil
            }
            
            newElement.ionizationEnergies = element.ionizationEnergies
            newElement.valency = element.valency
            newElement.oxidationDegree = element.oxidationDegree
            
            do {
                try self.context.save()
            } catch {
                fatalError("failure to save context \(error)")
            }
        }
    }
    
    private init() {
        
    }

}
