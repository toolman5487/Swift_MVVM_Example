//
//  UIViewControllerExtension.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import UIKit
extension UIViewController {
    
    func addNavigationItem() -> Void {
        let atmBarButtonItem = UIBarButtonItem(image: UIImage(named: "icNavPinkWithdraw"),
                                               style: .plain,
                                               target: self,
                                               action: nil)

        let transferBarButtonItem = UIBarButtonItem(image: UIImage(named: "icNavPinkTransfer"),
                                                    style: .plain,
                                                    target: self,
                                                    action: nil)
        
        navigationItem.leftBarButtonItems = [atmBarButtonItem, transferBarButtonItem]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icNavPinkScan"),
                                                               style: .plain,
                                                               target: self,
                                                               action: nil)
       
        
        
    }
    
}
