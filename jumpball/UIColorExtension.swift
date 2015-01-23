//
//  UIColorExtension.swift
//  jumpball
//
//  Created by wangbo on 1/16/15.
//  Copyright (c) 2015 wangbo. All rights reserved.
//

import UIKit

// take the class UIColor and extend it by adding new function
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0){
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF00) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}