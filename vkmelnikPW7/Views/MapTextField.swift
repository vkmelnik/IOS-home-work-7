//
//  MapTextField.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import UIKit

class MapTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init(backgroundColor: UIColor, placeholder: String) {
        self.init()
        super.backgroundColor = backgroundColor
        super.placeholder = placeholder
        super.layer.cornerRadius = 10
        super.layer.masksToBounds = true
        if (backgroundColor.isDark()) {
            super.textColor = .white
        } else {
            super.textColor = .black
        }
        setPadding()
    }
    
    private func setPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

}
