//
//  UINavigationItem+Extension.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 11/28/20.
//

import UIKit

extension UINavigationItem {
    func setBarAppearance(with color: UIColor, titleTextAttrs: [NSAttributedString.Key: NSObject]? = nil, title: String? = nil) {
        
        let barAppearance = UINavigationBarAppearance()
        
        barAppearance.shadowColor = .clear
    
        if let textAttrs = titleTextAttrs,
           let title = title {
            barAppearance.titleTextAttributes = textAttrs
            self.title = title
        }
        
        barAppearance.backgroundColor = color
        
        standardAppearance = barAppearance
    }
}
