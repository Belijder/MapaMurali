//
//  StatisticsViewModel.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 03/11/2022.
//

import Foundation
import RxSwift

class StatisticsViewModel {
    
    let databaseManager: DatabaseManager
    
    let disposeBag = DisposeBag()
    
    var mostPopularMurals = BehaviorSubject<[Mural]>(value: [])
    var popularCities = [PopularCity]()
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        addMuralObserver()
//        createMostPopularMuralsArray()
    }
    
//    func createMostPopularMuralsArray() {
//        mostPopularMurals = databaseManager.murals.sorted(by: { $0.favoritesCount > $1.favoritesCount })
//    }
    
    func createPopularCitiesArray() {
        var citiesNames = [String]()
        
        let murals = databaseManager.murals
        for mural in murals {
            if !citiesNames.contains(mural.city) {
                citiesNames.append(mural.city)
            }
        }
        
        var popularCities = [PopularCity]()
        
        for city in citiesNames {
            let muralsInCity = murals.filter { $0.city == city }
            let popularCity = PopularCity(name: city, muralsCount: muralsInCity.count)
            popularCities.append(popularCity)
        }
        
        let sortedPopularCities = popularCities.sorted { $0.muralsCount > $1.muralsCount }

        self.popularCities = sortedPopularCities
    }
    
    func addMuralObserver() {
        databaseManager.muralItems
            .subscribe(onNext: { murals in
                self.mostPopularMurals.onNext(murals)
            })
            .disposed(by: disposeBag)
    }
}
