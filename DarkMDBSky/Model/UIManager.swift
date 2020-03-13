//
//  UIManager.swift
//  DarkMDBSky
//
//  Created by Maggie Yi on 3/13/20.
//  Copyright © 2020 Mobile Developers at Berkeley. All rights reserved.
//

import Foundation
import UIKit

class UIManager {
    static func designButtons(_ btn: UIButton) {
        btn.backgroundColor = UIColor.systemBlue
        btn.layer.cornerRadius = 4
        btn.setTitleColor(UIColor.white, for: .normal)
    }
}
