//
//  UserModel.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import Foundation
struct UserResponse: Codable {
    let response: [User]
}

struct User: Codable {
    let name: String
    let kokoid: String?
}
