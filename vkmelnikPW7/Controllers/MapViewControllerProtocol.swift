//
//  MapViewControllerProtocol.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 25.01.2022.
//

import UIKit

protocol MapViewControllerProtocol {
    func enableButtons();
    func disableButtons();
    func canGo() -> Bool;
    func tryGo(_ textField: UITextField);
}
