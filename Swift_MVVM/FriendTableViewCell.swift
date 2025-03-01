//
//  FriendTableViewCell.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "imgFriendsList")
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.isHidden = true
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()
    
    private let topIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icFriendsStar")
        imageView.isHidden = true
        return imageView
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icFriendsMore"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    var onActionTapped: ((Friend) -> Void)?
    private var friend: Friend!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(actionButton)
        contentView.addSubview(topIcon)
        contentView.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            
            topIcon.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -5),
            topIcon.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            topIcon.widthAnchor.constraint(equalToConstant: 20),
            topIcon.heightAnchor.constraint(equalToConstant: 20),
            
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -10),
            
            actionButton.leadingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -100),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 30),
            
            settingsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsButton.widthAnchor.constraint(equalToConstant: 30),
            settingsButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    func configure(with friend: Friend) {
        self.friend = friend
        nameLabel.text = friend.name
        switch friend.status {
        case 1:
            actionButton.setTitle("轉帳", for: .normal)
            actionButton.isHidden = false
            actionButton.setTitleColor(UIColor(named: "tabSelectedColor"), for: .normal)
            actionButton.layer.borderColor = UIColor(named: "tabSelectedColor")?.cgColor
        case 2:
            actionButton.setTitle("邀請中", for: .normal)
            actionButton.isHidden = false
            actionButton.setTitleColor(.gray, for: .normal)
            actionButton.layer.borderColor = UIColor.gray.cgColor
        default:
            actionButton.isHidden = true
        }
        
        // 是否顯示置頂星號
        topIcon.isHidden = !friend.isTopBool
        
        // 頭像保持預設圖片
        avatarImageView.image = UIImage(named: "imgFriendsList")
    }
    
    @objc private func actionButtonTapped() {
        if friend.status == 1 {
            print("\(friend.name) 進入轉帳流程")
            onActionTapped?(friend) // 觸發轉帳事件
        } else if friend.status == 2 {
            print("\(friend.name) 還在邀請中，無法轉帳")
        }
    }
}
