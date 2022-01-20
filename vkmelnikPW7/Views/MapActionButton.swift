//
//  MapActionButton.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import UIKit

/*
 Custom button for mapkit actions.
 */
class MapActionButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init(backgroundColor: UIColor, text: String) {
        self.init()
        super.backgroundColor = backgroundColor
        super.setTitle(text, for: .normal)
        super.layer.cornerRadius = 10
        super.layer.masksToBounds = true
        if (backgroundColor.isDark()) {
            super.setTitleColor(.white, for: .normal)
        } else {
            super.setTitleColor(.black, for: .normal)
        }
    }

}
