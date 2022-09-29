//
//  MMError.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/09/2022.
//

import Foundation

enum MMError: String, Error {
    case locationRetrivalFaild = "Nie udało się pobrać Twojej lokalizacji. Sprawdź ustawienia lokalizacji i spróbuj ponownie."
    case failedToAddToDB = "Nie udało się dodać muralu do Bazy danych. Sprawdź czy wszystkie pola są wypełnione i spróbuj ponownie."
}
