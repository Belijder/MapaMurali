//
//  ReviewStatusLegendVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 11/02/2023.
//

import UIKit

class ReviewStatusLegendVC: UIViewController {
    
    // MARK: - Properties
    private let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 25)
    private let titlebodyLabel = MMBodyLabel(textAlignment: .left)
    private let waitingLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    private let acceptedLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    private let reportedLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    private let waitingDescription = MMBodyLabel(textAlignment: .left)
    private let acceptedDescription = MMBodyLabel(textAlignment: .left)
    private let reportedDescription = MMBodyLabel(textAlignment: .left)
    
    
    // MARK: - Live Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MMColors.orangeDark
        configureUIElements()
        layoutUI()
    }
    
    
    // MARK: - Set up
    private func configureUIElements() {
        titleLabel.text = "Status muralu - legenda"
        titleLabel.textColor = .white
        
        [titlebodyLabel, waitingDescription, acceptedDescription, reportedDescription].forEach { $0.textColor = MMColors.violetDark }
        
        [waitingLabel, acceptedLabel, reportedLabel].forEach { $0.textColor = .white }
        
        [titlebodyLabel, waitingDescription, acceptedDescription, reportedDescription].forEach { element in
            element.lineBreakMode = .byWordWrapping
            element.numberOfLines = 0
        }
        
        titlebodyLabel.text = "Mapa murali to aplikacja, w której użytkownicy mogą sami dodawać treści i dzięki temu pomagać nam rozbudowywać naszą bazę. Aby uniknąć publikowania niestosownych treści przez użytkowników, każdy dodany mural, przed opublikowaniem musi zostać zaakceptowany przez administratorów. Poniżej znajduje się legenda wyjaśniająca status Twojego muralu:"
        
        let waitingText = "W poczekalni"
        waitingLabel.createAttributedString(text: waitingText, imageSystemName: "eye", imagePointSize: 15, color: .systemYellow)
        
        waitingDescription.text = "Dodany przez Ciebie mural czeka na zaakceptowanie przez administratora. Do czasu zaakceptowania, jest on widoczny tylko dla Ciebie."
        
        let acceptedText = "Zaakceptowano"
        acceptedLabel.createAttributedString(text: acceptedText, imageSystemName: "checkmark", imagePointSize: 15, color: .systemGreen)
        
        acceptedDescription.text = "Dodany przez Ciebie mural został zaakceptowany przez administratora. Jest on widoczny dla wszystkich użytkowników aplikacji."
        
        let reportedText = "Zgłoszono"
        reportedLabel.createAttributedString(text: reportedText, imageSystemName: "exclamationmark.triangle", imagePointSize: 15, color: .systemRed)
        

        reportedDescription.text = "Twój mural został zgłoszony przez innych użytkowników jako zawierający kontrowersyjne treści. W tym momencie jest on widoczny tylko dla Ciebie. Jeśli administratorzy uznają, że zgłoszenie jest zasadne, mural zostanie usunięty z naszej bazy. W przeciwnym wypadku mural znów będzie widoczny dla wszystkich użytkowników, a zgłaszający dostanie ostrzeżenie o bezpodstawnym zgłoszeniu."
    }
    
    
    private func layoutUI() {
        view.addSubviews(titleLabel, titlebodyLabel, waitingLabel, acceptedLabel, reportedLabel, waitingDescription, acceptedDescription, reportedDescription)
        
        let horizontalPadding: CGFloat = 20

        let verticalPadding: CGFloat = 20
        let inSectionPadding: CGFloat = 10
        
        [titleLabel, titlebodyLabel, waitingLabel, acceptedLabel, reportedLabel, waitingDescription, acceptedDescription, reportedDescription].forEach { element in
            NSLayoutConstraint.activate([
                element.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
                element.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding)
            ])
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalPadding),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            titlebodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: inSectionPadding),
            titlebodyLabel.heightAnchor.constraint(equalToConstant: 144),
            
            waitingLabel.topAnchor.constraint(equalTo: titlebodyLabel.bottomAnchor, constant: verticalPadding),
            waitingLabel.heightAnchor.constraint(equalToConstant: 18),
            
            waitingDescription.topAnchor.constraint(equalTo: waitingLabel.bottomAnchor, constant: inSectionPadding),
            waitingDescription.heightAnchor.constraint(equalToConstant: 54),
            
            acceptedLabel.topAnchor.constraint(equalTo: waitingDescription.bottomAnchor, constant: verticalPadding),
            acceptedLabel.heightAnchor.constraint(equalToConstant: 18),
            
            acceptedDescription.topAnchor.constraint(equalTo: acceptedLabel.bottomAnchor, constant: inSectionPadding),
            acceptedDescription.heightAnchor.constraint(equalToConstant: 54),
            
            reportedLabel.topAnchor.constraint(equalTo: acceptedDescription.bottomAnchor, constant: verticalPadding),
            reportedLabel.heightAnchor.constraint(equalToConstant: 18),
            
            reportedDescription.topAnchor.constraint(equalTo: reportedLabel.bottomAnchor, constant: inSectionPadding),
            reportedDescription.heightAnchor.constraint(equalToConstant: 162)
        ])
    }
}
