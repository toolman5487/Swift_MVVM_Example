//
//  Swift_MVVMTests.swift
//  Swift_MVVMTests
//
//  Created by Willy Hsu on 2025/3/2.
//

import XCTest
@testable import Swift_MVVM

class FriendPageViewControllerTests: XCTestCase {
    
    var viewController: FriendPageViewController!
    var friendListViewModel: FriendListViewModel!
    
    override func setUp() {
        super.setUp()
        viewController = FriendPageViewController()
        _ = viewController.view
        friendListViewModel = viewController.friendListViewModel
        
        // 假資料
        friendListViewModel.friendsList = [
            Friend(name: "洪靖僑", status: 0, isTop: "1", fid: "001", updateDate: "20220101"),
            Friend(name: "彭勳儀", status: 0, isTop: "0", fid: "002", updateDate: "20220102")
        ]
        // 預設 filteredFriends 為非邀請狀態資料
        friendListViewModel.filteredFriends = friendListViewModel.friendsList.filter { $0.status != 2 }
    }
    
    override func tearDown() {
        viewController = nil
        friendListViewModel = nil
        super.tearDown()
    }
    
    // 測試搜尋
    func testFilterFriends() {
        friendListViewModel.filterFriends(with: "洪靖僑")
        
        XCTAssertEqual(friendListViewModel.filteredFriends.count, 1)
        XCTAssertEqual(friendListViewModel.filteredFriends.first?.name, "洪靖僑")
    }
    
    // 測試邀請卡更新邏輯
    func testUpdateInviteContainer() {
        
        let inviteFriend = Friend(name: "彭勳儀", status: 2, isTop: "1", fid: "003", updateDate: "20220103")
        friendListViewModel.inviteFriendsList = [inviteFriend]
        
        viewController.toggleInviteContainer()
        
        let expectedHeight = CGFloat(friendListViewModel.inviteFriendsList.count) * 88
        XCTAssertEqual(viewController.inviteContainerHeightConstraint.constant, expectedHeight)
    }
}
