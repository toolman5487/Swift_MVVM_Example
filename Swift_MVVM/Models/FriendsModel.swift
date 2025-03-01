//
//  FriendsModel.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import Foundation

struct FriendModel: Decodable {
    let response: [Friend]
    
    enum CodingKeys: String, CodingKey {
        case response
    }
}

struct Friend: Decodable {
    let name: String
    let status: Int
    let isTop: String
    let fid: String
    let updateDate: String
    
    var isInvite: Bool {
        return status == 2
    }
    
    var statusText: String {
        switch status {
        case 0: return "邀請中"
        case 1: return "聊天中"
        case 2: return "取消邀請"
        default: return "未知"
        }
    }
    
    var isTopBool: Bool {
        return isTop == "1"
    }
}
