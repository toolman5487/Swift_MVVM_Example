//
//  UserViewModel.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import Combine
import Foundation

class UserViewModel {
    @Published var user: User?
    @Published var error: Error?

    private let apiService = UserAPIService() // ✅ 內部建立 API 服務
    private var cancellables = Set<AnyCancellable>()

    func fetchUserInfo() {
        Task {
            do {
                let userData = try await apiService.fetchUser()
                await MainActor.run {
                    self.user = userData
                    self.error = nil // 成功時清除錯誤
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.user = User(name: "未知", kokoid: "無資料") // ✅ 避免 UI 崩潰
                }
            }
        }
    }
}


class UserAPIService {
    enum APIError: Error {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case noData
    }
    
    func fetchUser() async throws -> User {
        guard let url = URL(string: "https://dimanyen.github.io/man.json") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.noData
            }
            
            let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
            return userResponse.response.first ?? User(name: "未知", kokoid: "無資料")
        } catch let error as URLError {
            throw APIError.networkError(error)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.noData
        }
    }
}

