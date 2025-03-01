//
//  FriendPageViewController.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import UIKit
import Combine

class FriendPageViewController: UIViewController {
    
    // MARK: - ViewModels
    private let userViewModel = UserViewModel()             // 用戶資訊
    private let friendListViewModel = FriendListViewModel()   // 好友列表
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 好友/聊天切換的兩條約束
    private var selectionIndicatorLeadingToFriends: NSLayoutConstraint!
    private var selectionIndicatorLeadingToChat: NSLayoutConstraint!
    
    // MARK: - 邀請區折疊與 userInfoView 動態高度
    private var inviteContainerHeightConstraint: NSLayoutConstraint!
    private var userInfoViewHeightConstraint: NSLayoutConstraint!
    private var bottomContainerTopConstraint: NSLayoutConstraint!
    private var isInviteExpanded = false
    private let baseUserInfoHeight: CGFloat = 120
    
    // MARK: - UI Components
    
    // userInfoView
    private let userInfoView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    // 頭像
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25
        iv.image = UIImage(named: "imgFriendsFemaleDefault")
        return iv
    }()
    
    // 用戶名稱
    private let userNameLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 18, weight: .bold)
        return lb
    }()
    
    // 用戶 ID
    private let kokoIdLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 14)
        lb.textColor = .gray
        return lb
    }()
    
    // 邀請容器
    private let inviteContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 4
        return v
    }()
    
    // 用來堆疊邀請卡
    private let inviteStack: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 8
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    // 好友聊天按鈕
    private let friendsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("好友", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return btn
    }()
    
    private let chatButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("聊天", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return btn
    }()
    
    // 粉紅底線
    private let selectionIndicator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemPink
        return v
    }()
    
    // 分隔線
    private let bottomBorderView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .lightGray
        return v
    }()
    
    // UISearchBar
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "想轉一筆給誰呢？"
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        return bar
    }()
    
    private let addFriendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "icBtnAddFriends"), for: .normal)
        btn.tintColor = .systemPink
        return btn
    }()
    
    // 搜尋容器（包含 UISearchBar 與加好友按鈕）
    private let searchContainer: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.spacing = 8
        st.distribution = .fill
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    // 底部容器（包含搜尋容器與 TableView）
    private let bottomContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // 無資料時的畫面
    private let noDataView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(named: "imgFriendsEmpty"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let mainLabel = UILabel()
        mainLabel.text = "就從加好友開始吧 : )"
        mainLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        mainLabel.textColor = .black
        mainLabel.textAlignment = .center
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subLabel = UILabel()
        subLabel.text = "與好友們一起用 KOKO 聊起來！\n還能互相收款、發紅包喔！"
        subLabel.font = .systemFont(ofSize: 14)
        subLabel.textColor = .gray
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 0
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let addButton = GradientButton(type: .system)
        addButton.setTitle("加好友", for: .normal)
        addButton.setImage(UIImage(named: "icAddFriendWhite"), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.tintColor = .white
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        addButton.semanticContentAttribute = .forceRightToLeft
        addButton.contentHorizontalAlignment = .center
        addButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(mainLabel)
        stackView.addArrangedSubview(subLabel)
        stackView.addArrangedSubview(addButton)
        
        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }()
    
    // TableView
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(FriendTableViewCell.self, forCellReuseIdentifier: "FriendCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // Loading 指示器
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchBar.delegate = self
        
        setupUI()
        setupActions()
        setupBindings()
        
        userViewModel.fetchUserInfo()
        friendListViewModel.fetchFriends()
        collapseInviteContainer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 註冊鍵盤通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 5) 在畫面即將消失時，移除鍵盤通知
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    // MARK: - 鍵盤通知事件
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        // 取得鍵盤高度 - safeArea 的底部距
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        
        // 只要更新 tableView 的 contentInset 和 scrollIndicatorInsets
        // 就能讓鍵盤出現時，tableView 往上頂，避免被擋住
        tableView.contentInset.bottom = keyboardHeight
        tableView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // 鍵盤收起時，還原 tableView 的 contentInset
        tableView.contentInset.bottom = 0
        tableView.scrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // ActivityIndicator
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // userInfoView 及其子視圖
        userInfoView.addSubview(profileImageView)
        userInfoView.addSubview(userNameLabel)
        userInfoView.addSubview(kokoIdLabel)
        userInfoView.addSubview(inviteContainer)
        inviteContainer.addSubview(inviteStack)
        view.addSubview(userInfoView)
        
        // 搜尋容器
        searchContainer.addArrangedSubview(searchBar)
        searchContainer.addArrangedSubview(addFriendButton)
        
        // 底部容器
        bottomContainerView.addSubview(searchContainer)
        bottomContainerView.addSubview(tableView)
        bottomContainerView.addSubview(noDataView)
        view.addSubview(bottomContainerView)
        
        bottomContainerTopConstraint = bottomContainerView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 8)
        bottomContainerTopConstraint.isActive = true
        
        inviteContainerHeightConstraint = inviteContainer.heightAnchor.constraint(equalToConstant: 0)
        inviteContainerHeightConstraint.isActive = true
        
        userInfoViewHeightConstraint = userInfoView.heightAnchor.constraint(equalToConstant: baseUserInfoHeight)
        userInfoViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // userInfoView
            userInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // profileImageView
            profileImageView.topAnchor.constraint(equalTo: userInfoView.topAnchor, constant: 16),
            profileImageView.trailingAnchor.constraint(equalTo: userInfoView.trailingAnchor, constant: -16),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // userNameLabel & kokoIdLabel
            userNameLabel.topAnchor.constraint(equalTo: userInfoView.topAnchor, constant: 16),
            userNameLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 16),
            kokoIdLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            kokoIdLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            
            // inviteContainer
            inviteContainer.topAnchor.constraint(equalTo: kokoIdLabel.bottomAnchor, constant: 8),
            inviteContainer.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 16),
            inviteContainer.trailingAnchor.constraint(equalTo: userInfoView.trailingAnchor, constant: -16),
            
            // bottomContainerView
            bottomContainerView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 8),
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // searchContainer
            searchContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            searchContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // tableView
            tableView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor)
        ])
        
        // 好友／聊天切換區
        let tabStackView = UIStackView(arrangedSubviews: [friendsButton, chatButton])
        tabStackView.axis = .horizontal
        tabStackView.distribution = .equalSpacing
        tabStackView.alignment = .center
        tabStackView.spacing = 24
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        
        userInfoView.addSubview(tabStackView)
        userInfoView.addSubview(selectionIndicator)
        userInfoView.addSubview(bottomBorderView)
        
        NSLayoutConstraint.activate([
            tabStackView.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 24),
            tabStackView.bottomAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: -8),
            tabStackView.heightAnchor.constraint(equalToConstant: 40),
            
            bottomBorderView.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: userInfoView.trailingAnchor),
            bottomBorderView.bottomAnchor.constraint(equalTo: userInfoView.bottomAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 1),
            
            selectionIndicator.topAnchor.constraint(equalTo: tabStackView.bottomAnchor),
            selectionIndicator.widthAnchor.constraint(equalTo: friendsButton.widthAnchor),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        selectionIndicatorLeadingToFriends = selectionIndicator.leadingAnchor.constraint(equalTo: friendsButton.leadingAnchor, constant: 4)
        selectionIndicatorLeadingToChat = selectionIndicator.leadingAnchor.constraint(equalTo: chatButton.leadingAnchor, constant: 4)
        selectionIndicatorLeadingToFriends.isActive = true
        selectionIndicatorLeadingToChat.isActive = false
        
        view.addSubview(noDataView)
        NSLayoutConstraint.activate([
            noDataView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            noDataView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            noDataView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor)
        ])
        noDataView.isHidden = true
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        friendsButton.addTarget(self, action: #selector(didTapFriends), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(didTapChat), for: .touchUpInside)
        
        let inviteTap = UITapGestureRecognizer(target: self, action: #selector(toggleInviteContainer))
        inviteContainer.addGestureRecognizer(inviteTap)
        inviteContainer.isUserInteractionEnabled = true
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        userViewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self, let user = user else { return }
                self.userNameLabel.text = user.name
                self.kokoIdLabel.text = "KOKO ID: \(user.kokoid ?? "無")"
            }
            .store(in: &cancellables)
        
        friendListViewModel.$filteredFriends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        friendListViewModel.$inviteFriendsList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] invites in
                guard let self = self else { return }
                self.updateInviteContainer()
                if invites.isEmpty {
                    self.collapseInviteContainer()
                }
            }
            .store(in: &cancellables)
        
        friendListViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        friendListViewModel.$friendsList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] friends in
                guard let self = self else { return }
                if friends.isEmpty {
                    self.noDataView.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.noDataView.isHidden = true
                    self.tableView.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        friendListViewModel.$filteredFriends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 邀請區折疊／展開
    @objc private func toggleInviteContainer() {
        let count = friendListViewModel.inviteFriendsList.count
        if count == 0 { return }
        
        isInviteExpanded.toggle()
        
        let expandedHeight: CGFloat = CGFloat(count) * 88
        let collapsedHeight: CGFloat = 0
        let moveDownOffset = isInviteExpanded ? expandedHeight : collapsedHeight
        
        inviteContainerHeightConstraint.constant = moveDownOffset
        userInfoViewHeightConstraint.constant = baseUserInfoHeight + moveDownOffset
        bottomContainerTopConstraint.constant = baseUserInfoHeight + moveDownOffset + 8
        
        updateInviteContainer()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func expandInviteContainer(for count: Int) {
        let expandedHeight: CGFloat = CGFloat(count) * 88
        inviteContainerHeightConstraint.constant = expandedHeight
        userInfoViewHeightConstraint.constant = baseUserInfoHeight + expandedHeight
        isInviteExpanded = true
        
        print("展開 inviteContainer，高度：\(expandedHeight)")
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func collapseInviteContainer() {
        inviteContainerHeightConstraint.constant = 0
        userInfoViewHeightConstraint.constant = baseUserInfoHeight
        bottomContainerTopConstraint.constant = baseUserInfoHeight + 8
        
        isInviteExpanded = false
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 堆疊邀請卡
    private func layoutStackedCards(_ cards: [UIView]) {
        let cardHeight: CGFloat = 70
        let spacing: CGFloat = isInviteExpanded ? 5 : 10

        // 清除 inviteContainer 裡除 inviteStack 之外的子視圖
        for subview in inviteContainer.subviews {
            if subview !== inviteStack {
                subview.removeFromSuperview()
            }
        }
        
        // 依序加入卡片，並設定間距
        for (index, card) in cards.enumerated() {
            inviteContainer.addSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: inviteContainer.leadingAnchor),
                card.trailingAnchor.constraint(equalTo: inviteContainer.trailingAnchor),
                card.heightAnchor.constraint(equalToConstant: cardHeight)
            ])
            
            if index == 0 {
                // 第一張卡貼著容器頂部
                card.topAnchor.constraint(equalTo: inviteContainer.topAnchor).isActive = true
            } else {
                // 後續卡片相對前一張卡片，上方間距設定為 spacing
                let prevCard = cards[index - 1]
                card.topAnchor.constraint(equalTo: prevCard.bottomAnchor, constant: spacing).isActive = true
            }
        }
    }
    
    // MARK: - 更新邀請區
    private func updateInviteContainer() {
        for subview in inviteContainer.subviews {
            if subview !== inviteStack {
                subview.removeFromSuperview()
            }
        }
        
        let invites = friendListViewModel.inviteFriendsList
        print("邀請名單共有 \(invites.count) 人")
        
        if invites.isEmpty {
            collapseInviteContainer()
            return
        }
        
        var cards = [UIView]()
        for friend in invites {
            let card = createInviteCard(for: friend)
            cards.append(card)
        }
        
        layoutStackedCards(cards)
        expandInviteContainer(for: cards.count)
    }
    
    // MARK: - 建立邀請卡
    private func createInviteCard(for friend: Friend) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = false
        
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.image = UIImage(named: "imgFriendsList")
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.text = friend.name
        
        let invitLabel = UILabel()
        invitLabel.translatesAutoresizingMaskIntoConstraints = false
        invitLabel.font = .systemFont(ofSize: 14)
        invitLabel.textColor = .gray
        invitLabel.text = "邀請你成為好友 : )"
        
        let acceptButton = UIButton(type: .system)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.setImage(UIImage(named: "btnFriendsAgree"), for: .normal)
        acceptButton.tintColor = UIColor(named: "tabSelectedColor")
        acceptButton.addTarget(self, action: #selector(didAcceptInvite(_:)), for: .touchUpInside)
        acceptButton.tag = friend.fid.hashValue
        
        let rejectButton = UIButton(type: .system)
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.setImage(UIImage(named: "btnFriendsDelet"), for: .normal)
        rejectButton.tintColor = .gray
        rejectButton.addTarget(self, action: #selector(didRejectInvite(_:)), for: .touchUpInside)
        rejectButton.tag = friend.fid.hashValue
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, invitLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStack = UIStackView(arrangedSubviews: [acceptButton, rejectButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainHStack = UIStackView(arrangedSubviews: [avatarImageView, textStack, buttonStack])
        mainHStack.axis = .horizontal
        mainHStack.alignment = .center
        mainHStack.spacing = 12
        mainHStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(mainHStack)
        
        NSLayoutConstraint.activate([
            mainHStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            mainHStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            mainHStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            mainHStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            acceptButton.widthAnchor.constraint(equalToConstant: 32),
            acceptButton.heightAnchor.constraint(equalToConstant: 32),
            rejectButton.widthAnchor.constraint(equalToConstant: 32),
            rejectButton.heightAnchor.constraint(equalToConstant: 32),
            
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
        
        return cardView
    }
    
    // MARK: - 按鈕事件
    @objc private func didAcceptInvite(_ sender: UIButton) {
        guard let index = friendListViewModel.inviteFriendsList.firstIndex(where: { $0.fid.hashValue == sender.tag }) else { return }
        friendListViewModel.inviteFriendsList.remove(at: index)
        updateInviteContainer()
        print("接受邀請, tag: \(sender.tag)")
    }
    
    @objc private func didRejectInvite(_ sender: UIButton) {
        guard let index = friendListViewModel.inviteFriendsList.firstIndex(where: { $0.fid.hashValue == sender.tag }) else { return }
        friendListViewModel.inviteFriendsList.remove(at: index)
        updateInviteContainer()
        print("拒絕邀請, tag: \(sender.tag)")
    }
    
    // MARK: - 好友／聊天切換
    @objc private func didTapFriends() {
        friendsButton.setTitleColor(.black, for: .normal)
        chatButton.setTitleColor(.lightGray, for: .normal)
        selectionIndicatorLeadingToChat.isActive = false
        selectionIndicatorLeadingToFriends.isActive = true
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didTapChat() {
        friendsButton.setTitleColor(.lightGray, for: .normal)
        chatButton.setTitleColor(.black, for: .normal)
        selectionIndicatorLeadingToFriends.isActive = false
        selectionIndicatorLeadingToChat.isActive = true
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - UITableViewDataSource
extension FriendPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendListViewModel.filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as? FriendTableViewCell else {
            return UITableViewCell()
        }
        let friend = friendListViewModel.filteredFriends[indexPath.row]
        cell.configure(with: friend)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FriendPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension FriendPageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if containsBopomofo(trimmedText) {
            // 如果輸入中有注音符號，暫時顯示全部資料（避免 noData 畫面）
            friendListViewModel.filteredFriends = friendListViewModel.friendsList
            tableView.reloadData()
            noDataView.isHidden = true
        } else {
            friendListViewModel.filterFriends(with: trimmedText)
        }
    }
    
    // 檢查是否包含注音符號
    private func containsBopomofo(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            if (0x3100...0x312F).contains(scalar.value) {
                return true
            }
        }
        return false
    }
}
