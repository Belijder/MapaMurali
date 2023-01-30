//
//  MMUsersTableViewInTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 05/11/2022.
//

import UIKit

protocol MMUsersTableViewInTableViewDelegate: AnyObject {
    func didSelectRowWith(user: User)
}

class MMUsersTableViewInTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    static let identifier = "MMUsersTableViewInTableViewCell"
    var users = [User]()
    weak var delegate: MMUsersTableViewInTableViewDelegate?
    
    private let usersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MMMostActivUsersCell.self, forCellReuseIdentifier: MMMostActivUsersCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Live cicle
    override func layoutSubviews() {
        super.layoutSubviews()
        usersTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            usersTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            usersTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            usersTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            usersTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        usersTableView.backgroundColor = .secondarySystemBackground
        usersTableView.layer.cornerRadius = 20
    }
    
    
    //MARK: - Set up
    private func setupUI() {
        contentView.addSubview(usersTableView)
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.separatorColor = .clear
    }
    
    
    func set(users: [User]) {
        self.users = users
    }
}

//MARK: - Extensions
extension MMUsersTableViewInTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: MMMostActivUsersCell.identifier) as! MMMostActivUsersCell
        cell.set(user: users[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectRowWith(user: users[indexPath.row])
    }
}
