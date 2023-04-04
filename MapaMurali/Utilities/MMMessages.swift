//
//  MMMessages.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 04/04/2023.
//

import Foundation

typealias MessageTuple = (title: String, message: String)

enum MMMessages {
    
    static let customErrorTitle = "Ups! Coś poszło nie tak."
    static let defaultMessage = (title: "Ups!", message: "Coś poszło nie tak. Sprawdź połączenie z internetem i spróbuj ponownie.")
    
    
    // MARK: - Validation messages
    
    static let signIncompleteTheFields = (title: "Uzupełnij pola", message: "Aby się zalogować musisz wypełnić pola z adresem email i hasłem.")
    
    static let signUpcompleteTheFields = (title: "Uzupełnij wymagane pola", message: "Aby założyć konto musisz uzupełnić wszystkie wymagane pola")
    
    static let invalidEmail = (title: "Nieprawidłowy email", message: "Ten email nie wygląda na prawidłowy. Popraw adres i spróbuj ponownie.")
    
    static let passwordToWeek = (title: "Hasło zbyt słabe", message: "Upewnij się, że hasło ma minimum 8 znaków oraz zawiera co najmniej jeden znak specjalny i cyfrę.")
    
    static let tickConsents = (title: "Zaznacz zgody", message: "Aby aktywować konto musisz potwierdzić, że zapoznałeś się i akceptujesz warunki użytkowania oraz politykę prywatności naszej aplikacji.")
    
    static let usernameToShort = (title: "Zbyt krótko!", message: "Nazwa użytkownika musi posiadać minimum trzy znaki.")
    
    static let wrongPassword = (title: "Nieprawidłowe hasło", message: "Upewnij się, że wpisałeś dobre hasło. Jeśli nie pamiętasz swojego hasła, może je zresetować.")
    
    static let incompatiblePasswords = (title: "Niezgodne hasła", message: "Wprowadzone przez Ciebie hasła nie są takie same. Upewnij się, że dobrze wpisałeś hasła i spróbuj ponownie.")
    
    
    // MARK: - Permission messages
    
    static let noLocalizationPermission = (title: "Brak uprawnień", message: "Aby wyświetlić swoją lokalizację na mapie musisz wyrazić zgodę na używanie Twojej lokalizacji. Przejdź do Ustawienia > MapaMurali i wyraź zgodę.")
    
    static let noPermissionToAccessCamera = (title: "Brak dostępu", message: "Aby zrobić zdjęcie musisz wyrazić zgodę na używanie aparatu. Przejdź do Ustawienia > Mapa Murali i wyraź zgodę na używanie aparatu.")
    
    static let noInternetConnection = (title: "Brak połączenia", message: "Wygląda na to, że nie masz aktualnie połączenia z internetem. Aby w pełni korzystać z aplikacji musisz mieć aktywne połączenie.")
    
    static let noPermissionToGetCurrentLocation = (title: "Brak uprawnień", message: "Aby pobrać lokalizację musisz wyrazić zgodę na używanie Twojej lokalizacji. Przejdź do Ustawienia > MapaMurali i wyraź zgodę.")
    
    static let couldNotOpenMail = (title: "Nie można otworzyć poczty", message: "Sprawdź czy masz poprawnie skonfigurowanego klienta pocztowego i spóbuj ponownie, lub sprawdź pocztę ręcznie.")
    
    
    // MARK: - Account related messages
    
    static let resetPassword = (title: "Zresetuj hasło", message: "Aby zresetować hasło podaj adres mailowy, którego został użyto podczas zakładania konta.")
    
    static let passwordHasBeenReset = (title: "Gotowe", message: "Na podany adres mailowy został wysłany link pozwalający na zmianę hasła. Sprawdź pocztę.")
    
    static let accountAlreadyExists = (title: "Konto już istnieje", message: "Ten mail jest już zarejestrowany w naszej bazie. Spróbuj się zalogować.")
    
    static let unableToCreateAccount = (title: "Ups", message: "Coś poszło nie tak. Nie udało się utworzyć konta. Spróbuj ponownie za chwilę.")
    
    static let unableToEditAccountInfo = (title: "Ups", message: "Coś poszło nie tak. Nie udało się edytować informacji. Spróbuj ponownie za chwilę.")
    
    static let deletingAccount = (title: "Usuń konto!", message: "Aby potwierdzić usunięcie konta oraz wszystkich związanych z nim danych, podaj hasło używane do zalogowania się do aplikacji. Pamiętej, że tej operacji nie będzie można cofnąć.")
    
    static let accountNotExist = (title: "Konto nie istnieje", message: "Ten adres email nie jest przypisany do żadnego konta w naszej bazie. Musisz się zarejestrować.")
    
    static let accountTemporarilyBlocked = (title: "Konto tymczasowo zablokowane", message: "Dostęp do tego konta został tymczasowo zablokowany z powodu wielu nieudanych prób logowania. Możesz je natychmiast przywrócić, resetując hasło lub spróbować ponownie później.")
    

    // MARK: - Database related messages
    
    static let muralAddedToDatabase = (title: "Udało się!", message: "Twój mural został wysłany do akceptacji! Dzięki za pomoc w tworzeniu naszej mapy!")
    
    static let userHasBeenUnblocked = (title: "Udało się!", message: "Użytkownik został odblokowany. Znów możesz przeglądać treści dodane przez tego użytkownika.")
    
    static let userHasBeenBlocked = (title: "Gotowe!", message: "Użytkownik został zablokowany. Od teraz nie będziesz widział treści dodawanych przez tego użytkownika.")
    
    static let unableToSentReport = (title: "Coś poszło nie tak!", message: "Nie udało się wysłać zgłoszenia. Sprawdź połączenie z internetem i spróbuj ponownie.")
    
    static let reportAccepted = (title: "Zgłoszenie przyjęte!", message: "Mural został tymczasowo ukryty do czasu przeanalizowania Twojego zgłoszenia przez administratorów. Dokładamy wszelkich starań, aby nasza aplikacja była wolna od kontrowersyjnych treści. Czy chciałbyś dodać więcej szczegółów odnośnie zgłoszenia?")
   
    
    // MARK: - App related messages
    
    static let cannotSendMail = (title: "Nie można wysłać maila", message: "Sprawdź czy masz skonfugurowanego klienta pocztowego i spróbuj ponownie.")
    
    static let noPhotoSelected = (title: "Brak zdjęcia", message: "Wybierz lub zrób inne zdjęcie i spróbuj ponownie.")
    
    static let addAvatar = (title: "Dodaj avatar", message: "Dodaj avatar do swojego konta.")
}
