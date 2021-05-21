//
//  Colors.swift
//  whiteboard
//
//  Created by vicky Leu on 2021/5/20.
//

import Foundation

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    
    public convenience init?(rgbValue: Int){
        let r =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let b =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let a = CGFloat(1.0)
        self.init(red: r, green: g, blue: b, alpha: a)
        return
    }
    
    
}
