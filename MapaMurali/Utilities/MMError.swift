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
    case defaultError = "Coś poszło, nie tak. Spróbuj ponownie później!"
    case reauthenticateError = "Nie udało się uwierzytelnić konta. Sprawdź hasło i spróbuj ponownie."
    case unableToDeleteAccount = "Coś poszło nie tak podczas próby usunięcia konta. Sprawdź połączenie z internetem i spróbuj ponownie"
    case invalidAddress = "Nieprawidłowy adres. Upewnij się, że wpisałeś dobry adres i spróbuj ponownie."
    case failedToEditMuralData = "Nie udało się zaktualizować informacji w Bazie danych. Sprawdź czy wszystkie pola są prawidłowo wypełnione i spróbuj ponownie."
    case failedToGetLegalTerms = "Nie udało się pobrać regulaminu. Sprawdź połączenie z interentem i spróbuj ponownie. Jeśli problem będzie się dalej pojawiał, skontaktuj się z nami!"
    
    
    case failedToFetchSingInMethods = "Wystąpił błąd przy próbie weryfikacji maila. Sprawdź połączenie z internetem i spróbuj ponownie."
    case incompatiblePasswords = "Wprowadzone przez Ciebie hasła nie są takie same. Upewnij się, że dobrze wpisałeś hasła i spróbuj ponownie."
    
    case accountNotExist = "Konto o podanym mailu nie istnieje. Załóż konto."
    case failedToSendPasswordResset = "Nie udało się wysłać prośby o zresetowanie hasła. Sprawdź połączenie z internetem i spróbuj ponownie"
}
