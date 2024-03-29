//
//  StatisticsViewModel.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 03/11/2022.
//

import Foundation
import RxSwift

class StatisticsViewModel {
    
    //MARK: - Properties
    let databaseManager: DatabaseManager
    var disposeBag = DisposeBag()
    
    var mostPopularMurals = BehaviorSubject<[Mural]>(value: [])
    var mostActivUsers = BehaviorSubject<[User]>(value: [])
    var mostMuralCities = BehaviorSubject<[PopularCity]>(value: [])
    

    //MARK: - Initialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        addMuralObserver()
        addUsersObserver()
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    //MARK: - Logic
    private func createMostPopularMuralsArray(from murals: [Mural]) {
        let sortedMurals = murals.sorted(by: { $0.favoritesCount > $1.favoritesCount })
        var bestMurals = [Mural]()
        
        if murals.count > 10 {
            for index in 0...9 {
                bestMurals.append(sortedMurals[index])
                mostPopularMurals.onNext(bestMurals)
            }
        } else {
            mostPopularMurals.onNext(sortedMurals)
        }
    }
    
    
    private func createPopularCitiesArray(from murals: [Mural]) {
        var citiesNames = [String]()
        
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

        self.mostMuralCities.onNext(sortedPopularCities)
    }
    
    
    //MARK: - Binding
    private func addMuralObserver() {
        databaseManager.muralItems
            .subscribe(onNext: { [weak self] murals in
                guard let self = self else { return }
                
                self.createMostPopularMuralsArray(from: murals)
                self.createPopularCitiesArray(from: murals)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addUsersObserver() {
        databaseManager.observableUsersItem
            .subscribe(onNext: { [weak self] users in
                guard let self = self else { return }
                self.mostActivUsers.onNext(users)
            })
            .disposed(by: disposeBag)
    }
}
