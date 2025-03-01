//
//  FriendListViewModel.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import Combine
import Foundation

class FriendListViewModel {
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    // 全部好友
    @Published var friendsList: [Friend] = []
    @Published var inviteFriendsList: [Friend] = []
    @Published var filteredFriends: [Friend] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    init() {
        fetchFriends()
    }
    
    func fetchFriends() {
        isLoading = true
        Task {
            do {
                let allFriends = try await apiService.fetchFriends()
                await MainActor.run {
                    self.friendsList = allFriends.sorted { $0.isTop > $1.isTop }

                    self.inviteFriendsList = self.friendsList.filter { $0.status == 2 }
                    print("取得邀請列表：\(self.inviteFriendsList.count)")

                    self.filteredFriends = self.friendsList.filter { $0.status != 2 }

                    self.isLoading = false
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - 搜尋好友
    func filterFriends(with query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            filteredFriends = friendsList
        } else {
            filteredFriends = friendsList.filter { friend in
                friend.name.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }
    }
    
    // MARK: - APIService
    class APIService {
        enum APIError: Error {
            case invalidURL
            case networkError(Error)
            case decodingError(Error)
            case noData
        }
        
        func fetchFriends() async throws -> [Friend] {
            guard let url = URL(string: "https://dimanyen.github.io/friend4.json") else {
                throw APIError.invalidURL
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.noData
                }
                
                // 解析 JSON
                let friendModel = try JSONDecoder().decode(FriendModel.self, from: data)
                return friendModel.response
            } catch let error as URLError {
                throw APIError.networkError(error)
            } catch let error as DecodingError {
                throw APIError.decodingError(error)
            } catch {
                throw APIError.noData
            }
        }
    }
}
    

