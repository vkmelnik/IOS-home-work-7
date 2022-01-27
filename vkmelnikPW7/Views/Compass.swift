//
//  Compass.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 27.01.2022.
//

import UIKit

class Compass: UIView {

    private var image: UIImageView!
    
    convenience init() {
        self.init(frame: CGRect.zero)
        configureImage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImage(){
        image = UIImageView(image: UIImage(named: "Compass"))
        addSubview(image)
        image.pin(to: self)
    }
    
    public func update(heading: Double) {
        image.transform = image.transform.rotated(by: CGFloat(heading) * .pi / 180)
    }

}
