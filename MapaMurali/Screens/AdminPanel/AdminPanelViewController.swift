//
//  AdminPanelViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 07/02/2023.
//

import UIKit

class AdminPanelViewController: MMDataLoadingVC {
    
    // MARK: - Properties
    private let databaseManager: DatabaseManager
    private let segmentedControl = UISegmentedControl(items: ["Poczekalnia", "Zgłoszenia"])
    private let unreviewedMuralsContainerView = UIView()
    private let reportsContainerView = UIView()

    
    // MARK: - Initialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = MMColors.primary
        
        configureSegmentedControl()
        layoutUI()
        configureTableViews()
        reportsContainerView.alpha = 0.0
    }
    
    
    // MARK: - Set up
    private func layoutUI() {
        [segmentedControl, unreviewedMuralsContainerView, reportsContainerView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        view.addSubviews(segmentedControl, unreviewedMuralsContainerView, reportsContainerView)
        
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        [unreviewedMuralsContainerView, reportsContainerView].forEach { container in
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
                container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
    
    
    private func configureSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = MMColors.orangeDark
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    
    private func configureTableViews() {
        add(childVC: UnreviewedMuralsVC(databaseManager: databaseManager), to: unreviewedMuralsContainerView)
        add(childVC: ReportsVC(databaseManager: databaseManager), to: reportsContainerView)
    }
    
    
    //MARK: -  Logic
    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    
    // MARK: - Actions
    @objc func segmentedControlValueChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            reportsContainerView.alpha = 0.0
            unreviewedMuralsContainerView.alpha = 1.0
        } else {
            reportsContainerView.alpha = 1.0
            unreviewedMuralsContainerView.alpha = 0.0
        }
    }
}
