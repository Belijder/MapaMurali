//
//  StatisticsViewModel.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 03/11/2022.
//

import Foundation

class StatisticsViewModel {
    
    let databaseManager: DatabaseManager
    
    var mostPopularMurals = [Mural]()
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    func createMostPopularMuralsArray() {
        mostPopularMurals = databaseManager.murals.sorted(by: { $0.favoritesCount > $1.favoritesCount })
        print("🔵 Most activ user have \(databaseManager.users[0].muralsAdded) murals added.")
    }
}
