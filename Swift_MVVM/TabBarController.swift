//
//  TabBarController.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDivider()
        setupTabBarParam()
        setupViewController()
        setupDivider()
        
        // Do any additional setup after loading the view.
    }
    
    
}
extension TabBarController{
    
    func setupTabBarParam() {
        tabBar.tintColor = UIColor(named: "tabSelectedColor")
    }
    
    func setupDivider() {
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        borderView.backgroundColor = UIColor(named: "tabDividerColor")
        borderView.autoresizingMask = .flexibleWidth
        tabBar.addSubview(borderView)
    }
    
    func setupViewController() {
        
        let moneyVC = MoneyPageViewController()
        moneyVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "icTabbarProductsOff"), tag: 0)
        
        let friendVC = FriendPageViewController()
        friendVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "icTabbarFriendsOn"), tag: 1)

        let kokoVC = KoKoViewController()
        kokoVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "icTabbarHomeOff"), tag: 2)
        
        let trackVC = SpendingPageViewController()
        trackVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "icTabbarManageOff"), tag: 3)
        
        let setting = SettingPageViewController()
        setting.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "icTabbarSettingOff"), tag: 4)

        friendVC.addNavigationItem()
        viewControllers = [
                UINavigationController(rootViewController: moneyVC),
                UINavigationController(rootViewController: friendVC),
                UINavigationController(rootViewController: kokoVC),
                UINavigationController(rootViewController: trackVC),
                UINavigationController(rootViewController: setting),
            ]

    }
    
}
