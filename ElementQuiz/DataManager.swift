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
            if user.id == nil {
                user.id = UUID()
                user.learnedChemicalElements = [:]
                user.searchTableSelectedElements = []
            }
            
            return user
        } catch {
            fatalError("Current user is missing")
        }
    }
    
    func saveUserData(from user: User) {
        let data = User(context: self.context)
        data.id = user.id
        data.learnedChemicalElements = user.learnedChemicalElements
        data.wideTableOptionalParameter = user.wideTableOptionalParameter
        data.shortTableOptionalParameter = user.shortTableOptionalParameter
        data.classicTableOptionalParameter = user.classicTableOptionalParameter
        data.standardTableOptionalParameter = user.standardTableOptionalParameter
        data.searchTableOptionalParameter = user.searchTableOptionalParameter
        data.wideTableScaleParameter = user.wideTableScaleParameter
        data.shortTableScaleParameter = user.shortTableScaleParameter
        data.classicTableScaleParameter = user.classicTableScaleParameter
        data.standardTableScaleParameter = user.standardTableScaleParameter
        data.searchTableSelectedElements = user.searchTableSelectedElements
        data.searchTableSearchedText = user.searchTableSearchedText
        data.countMemorizings = user.countMemorizings
        data.countBigGames = user.countBigGames
        data.countMemorizingQuestions = user.countMemorizingQuestions
        data.countBigGamesQuestions = user.countBigGamesQuestions
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
        
        var data: [ChemicalElementModel] = []
        
        context.performAndWait {
            do {
                data = try context.fetch(request)
                if data.isEmpty {
                    let elementsJSON: [ChemicalElementModelJSON] = Bundle.main.decode(file: "PeriodicTableJSON.json")
                    saveElements(from: elementsJSON)
                    data = try context.fetch(request)
                }
            } catch {
                fatalError("failure to get data from storage: \(error)")
            }
        }
        return data
    }
    
    func fetchLearnedElements(orderedBy value: OrderedCases? = nil) -> [ChemicalElementModel] {
        let learnedChemicalElements = fetchUser().learnedChemicalElements
        let attribute = value ?? .number
        let sort = NSSortDescriptor(key: attribute.rawValue, ascending: true)
        let request = ChemicalElementModel.fetchRequest()
        request.sortDescriptors = [sort]
        
        var data: [ChemicalElementModel] = []
        
        context.performAndWait {
            do {
                data = try context.fetch(request)
                if data.isEmpty {
                    let elementsJSON: [ChemicalElementModelJSON] = Bundle.main.decode(file: "PeriodicTableJSON.json")
                    saveElements(from: elementsJSON)
                    data = try context.fetch(request)
                }
                
                data = data.filter {
                    learnedChemicalElements.keys.contains($0.symbol)
                }
            } catch {
                fatalError("failure to get data from storage: \(error)")
            }
        }
        return data
    }
    
    func fetchElementsToLearn(orderedBy value: OrderedCases? = nil) -> [ChemicalElementModel] {
        let learnedChemicalElements = fetchUser().learnedChemicalElements
        let attribute = value ?? .number
        let sort = NSSortDescriptor(key: attribute.rawValue, ascending: true)
        let request = ChemicalElementModel.fetchRequest()
        request.sortDescriptors = [sort]
        
        var data: [ChemicalElementModel] = []
        
        context.performAndWait {
            do {
                data = try context.fetch(request)
                if data.isEmpty {
                    let elementsJSON: [ChemicalElementModelJSON] = Bundle.main.decode(file: "PeriodicTableJSON.json")
                    saveElements(from: elementsJSON)
                    data = try context.fetch(request)
                }
                
                data = data.filter {
                    !learnedChemicalElements.keys.contains($0.symbol)
                }
            } catch {
                fatalError("failure to get data from storage: \(error)")
            }
        }
        return data
    }
    
    func fetchElementToRepeat() -> ChemicalElementModel {
        let oldChemicalElements = fetchUser().learnedChemicalElements.min(by:{$0.value < $1.value})
        let request = ChemicalElementModel.fetchRequest()
        var data: [ChemicalElementModel] = []
        
        context.performAndWait {
            do {
                data = try context.fetch(request)
                if data.isEmpty {
                    let elementsJSON: [ChemicalElementModelJSON] = Bundle.main.decode(file: "PeriodicTableJSON.json")
                    saveElements(from: elementsJSON)
                    data = try context.fetch(request)
                }
                
                data = data.filter {
                    oldChemicalElements!.key.contains($0.symbol)
                }
            } catch {
                fatalError("failure to get data from storage: \(error)")
            }
        }
        return data.first!
    }
    
    func fetchSortedAndFilteredElements(defaultlyOrderedBy value: ElementParameters = .atomicMass,
                                        userAttribute: ElementParameters,
                                        isAscending: Bool? = nil,
                                        searchText: String? = nil,
                                        togglePosition: Bool,
                                        taggedElements: Set<String>
    ) -> [ChemicalElementModel] {
        let attribute = isAscending == nil ? value : userAttribute
        
        var selector: Selector {
            switch userAttribute {
            case .boil, .melt, .molarHeat, .elecrtonAffinity, .electronegativityPauling:
                return #selector(NSString.localizedStandardCompare(_:))
            default:
                return #selector(NSNumber.compare(_:))
            }
        }
        
        let sort = NSSortDescriptor(key: attribute.rawValue, ascending: isAscending ?? true, selector: selector)

        let request = ChemicalElementModel.fetchRequest()
        request.sortDescriptors = [sort]
        
        var predicates: [NSPredicate] = []
        
        if togglePosition == true {
            if !taggedElements.isEmpty {
                let taggedPredicate = NSPredicate(format: "symbol IN %@", taggedElements)
                predicates.append(taggedPredicate)
            }
        }
        
        if let searchText = searchText, !searchText.isEmpty, searchText.trimmingCharacters(in: .whitespaces) != "" {
            var searchTextPredicate: NSPredicate {
                switch userAttribute {
                case .atomicMass:
                    return NSPredicate(format: "\(userAttribute.rawValue) == %@", searchText)
                case .density:
                    let searchTextDouble = Double(searchText) ?? 0.0
                    return NSPredicate(format: "\(userAttribute.rawValue) >= %lf AND \(userAttribute.rawValue) <= %lf", searchTextDouble - 0.5, searchTextDouble + 0.5)
                case .period, .group:
                    return NSPredicate(format: "\(userAttribute.rawValue) IN %@", [Int16(searchText)])
                case .shells, .valency, .oxidationDegree:
                    return NSPredicate(format: "ANY \(userAttribute.rawValue) IN %@", [Int16(searchText)])
                case .ionizationEnergies:
                    return NSPredicate(format: "ANY \(userAttribute.rawValue) IN %@", [Double(searchText)])
                default:
                    return NSPredicate(format: "\(userAttribute.rawValue) CONTAINS[cd] %@", searchText)
                }
            }
            
            predicates.append(searchTextPredicate)
        }
        
        var data: [ChemicalElementModel] {
                var data: [ChemicalElementModel] = []
                context.performAndWait {
                    do {
                        data = try context.fetch(request)
                    } catch {
                        fatalError("failure to get data from storage: \(error)")
                    }
                }
                return data
            }

        
        var filteredResults: [ChemicalElementModel] {
            var filteredResults: [ChemicalElementModel] = []
            if !predicates.isEmpty {
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                filteredResults = data.filter { compoundPredicate.evaluate(with: $0) }
            }
            return filteredResults
        }
        
        let result = !predicates.isEmpty ? filteredResults : data

        return result
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
            
            newElement.density = element.density
            
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
            newElement.cxpos = Int16(element.cxpos)
            newElement.cypos = Int16(element.cypos)
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
            
            context.perform {
                do {
                    try self.context.save()
                } catch {
                    fatalError("failure to save context \(error)")
                }
            }
        }
    }
    
    private init() {
        
    }

}
