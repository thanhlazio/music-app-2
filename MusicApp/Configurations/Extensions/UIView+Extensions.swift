//
//  UIView+OnLoad.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 5/26/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import UIKit

// MARK: On Load

extension UIView {
    
    func onLoad() { }
    
}

// MARK: Remove Subviews

extension UIView {
    
    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
}

// MARK: Frame

extension UIView {
    func frameEqual(with view: UIView) {
        self.frame = view.bounds
    }
    
    func frameEqual(with view: UIView, originX: CGFloat) {
        var frame = view.bounds
        frame.origin.x = originX
        self.frame = frame
    }
}

extension UIView {
    func shadowed(radius: CGFloat = 5.0, opacity: Float = 0.5, color: UIColor = .black, offset: CGSize = .zero) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
}


extension UITableView {
    func scrollToBottom(animated: Bool) {
        let y = contentSize.height - frame.size.height
        setContentOffset(CGPoint(x: 0, y: (y<0) ? 0 : y), animated: animated)
    }
    
}
