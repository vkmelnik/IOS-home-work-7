//
//  UIColorExtension.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import UIKit

extension UIColor {
    
    public func isDark() -> Bool {
        let components = self.cgColor.components
        if (components!.count > 3) {
            return components![0] + components![1] + components![2] < 1.5
        } else {
            return components![0] < 0.5
        }
    }
}
