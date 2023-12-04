//
//  Bundle+Extension.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 04.12.2023.
//

import Foundation

extension Bundle {
    func decode<T: Decodable>(file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Could not find \(file) in project")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file) in project")
        }
        
        guard let loadedData = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Could not decode \(file) in the project")
        }
        
        return loadedData
    }
}
