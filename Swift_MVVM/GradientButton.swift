//
//  GradientButton.swift
//  Swift_MVVM
//
//  Created by Willy Hsu on 2025/3/1.
//

import UIKit

class GradientButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }
    
    private func applyGradient() {
        layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 86/255,  green: 179/255, blue: 11/255, alpha: 1).cgColor, // #56B30B
            UIColor(red: 166/255, green: 204/255, blue: 66/255, alpha: 1).cgColor  // #A6CC42
        ]
        gradientLayer.startPoint = CGPoint(x: 0,   y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.frame        = bounds
        gradientLayer.cornerRadius = bounds.height / 2 
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
