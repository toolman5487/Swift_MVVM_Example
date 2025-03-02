以下是一份完整的中文 README 範例，內含專案說明以及如何修改 FriendListViewModel 中的 fetchFriends() 函式以使用測試用的 URL：

Swift_MVVM
本專案示範了一個採用 Swift 與 MVVM 架構開發的 iOS App，並運用 Combine 框架進行資料綁定。專案中展示了如何實現網路請求、動態更新 UI、以及自訂 UI 元件（例如漸層按鈕與可展開/收合的邀請卡）。

主要功能
	•	MVVM 架構： 將 View、ViewModel 與 Model 分離，便於維護與測試。
	•	Combine 框架： 使用 Combine 實現反應式資料綁定，確保 UI 及時更新。
	•	自訂 UI 元件： 包括 GradientButton 及可展開／收合的邀請卡功能。
	•	動態版面： 根據邀請卡數量自動展開／收合邀請區，並處理鍵盤遮擋問題。
	•	網路請求： 從遠端 API 抓取好友資料，並可使用測試用的 URL 進行開發驗證。

系統需求
	•	iOS 14.0 或以上版本
	•	Xcode 13 或以上版本
	•	Swift 5

安裝與執行
1.	從 GitHub 上克隆本專案：
git clone https://github.com/toolman5487/Swift_MVVM_Example


2.	使用 Xcode 開啟專案：
open Swift_MVVM.xcodeproj


3.	選擇模擬器或連接實體裝置，然後執行專案。
專案結構
	•	Model： 定義用戶與好友的資料模型。
	•	ViewModel： 使用 Combine 處理資料抓取、狀態管理及邏輯處理。
	•	View： 包含各個 ViewController 與自訂 UI 元件（如 GradientButton 與 FriendPageViewController）。

API 測試

在 FriendListViewModel.swift 中的 fetchFriends() 函式，預設使用以下測試用 URL：
	•	https://dimanyen.github.io/friend1.json
	•	https://dimanyen.github.io/friend2.json
	•	https://dimanyen.github.io/friend3.json
	•	https://dimanyen.github.io/friend4.json

你可以根據需要修改此函式中的 URL，以便測試不同的資料來源。

使用說明
	•	邀請卡功能： 點擊邀請區可展開／收合邀請卡，並根據邀請數量自動調整邀請區高度。預設狀態下邀請區為折疊狀態（高度為 0），展開後間距會調整為正值（例如 10）。
	•	搜尋功能： 利用 UISearchBar 過濾好友資料，鍵盤出現時 TableView 會自動上移以避免被遮擋，離開搜尋後畫面會恢復原狀。
	•	模式切換： 點擊上方的「好友」或「聊天」按鈕切換模式，底部的粉紅底線將指示目前的選中狀態。

貢獻
歡迎任何形式的建議、回饋或提交 Pull Request。如果發現錯誤或有改進意見，請先在 Issue 中說明，再提交 PR。

授權條款
本專案採用 MIT 授權，詳情請參閱 LICENSE 文件。

以上就是本專案的 README 範例，你可以根據實際需求進行修改調整。
