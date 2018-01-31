//
//  Apptheme.swift
//  ios
//
//  Created by admin on 30.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation
import UIKit


struct Theme {
    static let palette = Palette()
}

struct Palette {
    //let lightgrey = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
    let lightgrey = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
    let darkblue  = UIColor(red:0.10, green:0.14, blue:0.49, alpha:1.0)
    let white = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    let orange = UIColor(red:0.90, green:0.32, blue:0.00, alpha:1.0)
    let fontColorGrey = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.0)
    let purple = UIColor(red:0.40, green:0.23, blue:0.72, alpha:1.0)
    
}

@IBDesignable class CardView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 10
    @IBInspectable var bgColor: CGColor = Theme.palette.white.cgColor
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = bgColor
    }
}

@IBDesignable class AppBackgroundView: UIView {
    //@IBInspectable var bgColor: CGColor = Theme.palette.lightgrey.cgColor
    @IBInspectable var bgColor: CGColor = Theme.palette.lightgrey.cgColor
    
    override func layoutSubviews() {
        layer.backgroundColor = bgColor
    }
}


@IBDesignable class PurpleButton: UIButton {
    @IBInspectable var bgColor: CGColor = Theme.palette.purple.cgColor
    @IBInspectable var fontColor: UIColor = Theme.palette.white
    @IBInspectable var fontColorDisabled: UIColor = Theme.palette.fontColorGrey
    @IBInspectable var cornerRadius: CGFloat = 15
    
    override func draw(_ rect: CGRect) {
        layer.backgroundColor = bgColor
        layer.cornerRadius = cornerRadius
        setTitleColor(fontColor, for: UIControlState.normal)
        setTitleColor(fontColorDisabled, for: UIControlState.disabled)
    }
}


@IBDesignable class OrangeButton: UIButton {
    @IBInspectable var bgColor: CGColor = Theme.palette.orange.cgColor
    @IBInspectable var fontColor: UIColor = Theme.palette.white
    @IBInspectable var fontColorDisabled: UIColor = Theme.palette.fontColorGrey
    @IBInspectable var cornerRadius: CGFloat = 15
    
    override func draw(_ rect: CGRect) {
        layer.backgroundColor = bgColor
        layer.cornerRadius = cornerRadius
        setTitleColor(fontColor, for: UIControlState.normal)
        setTitleColor(fontColorDisabled, for: UIControlState.disabled)
    }
}

@IBDesignable class NavBar: UINavigationBar {
    @IBInspectable var bgColor: CGColor = Theme.palette.white.cgColor
    @IBInspectable var tintColorCustom: UIColor = Theme.palette.purple
    
    override func draw(_ rect: CGRect) {
        layer.backgroundColor = bgColor
        self.tintColor = tintColorCustom
    }
}
