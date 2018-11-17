//
//  MainBorderView.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 6/10/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import UIKit

class MainBorderView: UIView {

    func configure(store: MainStore, action: MainAction, center: CGPoint) {
//        layer.cornerRadius = bounds.size.height / 2
//        layer.borderColor = UIColor.toolbarBorder.cgColor
//        layer.borderWidth = 1
        isHidden = true
        self.center = center
    }
    
}
