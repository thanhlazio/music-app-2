//
//  LoadingActivityIndicatorView.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 6/19/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingActivityIndicatorView: UIView {
    
    // MARK: Configuration
    
    fileprivate var indicatorView: NVActivityIndicatorView!
    fileprivate var logoImageView: UIImageView!
    
    fileprivate(set) weak var sourceView: UIView?
    fileprivate var shadowView: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure() {
        self.layer.cornerRadius = 12
        self.backgroundColor = .clear
        
        logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "main_image")
        logoImageView.contentMode = .scaleToFill
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.shadowed()
        addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.62),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor)
            ])
        logoImageView.layer.cornerRadius = min(logoImageView.frame.width, logoImageView.frame.height) / 2
        logoImageView.layer.masksToBounds = false
        
        indicatorView = NVActivityIndicatorView(
            frame: .zero,
            type: .circleStrokeSpin,
            color: .background,
            padding: nil
        )
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            indicatorView.widthAnchor.constraint(equalTo: indicatorView.heightAnchor)
        ])
    }
    
    // MARK: Static Methods
    
    private static var rootLoadingView: LoadingActivityIndicatorView?
    
    static func startLoading() {
        rootLoadingView = LoadingActivityIndicatorView()
        rootLoadingView?.startAnimation()
    }
    
    static func stopLoading() {
        rootLoadingView?.stopAnimation()
    }
    
    // MARK: Animation Constants
    
    fileprivate let duration: TimeInterval = 0.25
    
    fileprivate let startTransform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    fileprivate let endTransform = CGAffineTransform.identity
    
    fileprivate let startAlpha: CGFloat = 0.2
    fileprivate let endAlpha: CGFloat = 1
    
    fileprivate func setProperties(alpha: CGFloat, transform: CGAffineTransform) {
        self.alpha = alpha
        self.transform = transform
    }

}

// MARK: Start/Stop Animation

extension LoadingActivityIndicatorView {
    
    func startAnimation(in view: UIView? = nil) {
        let sourceView = view ?? getWindow()
        self.sourceView = sourceView
        self.subviewFromView(sourceView)
        
        indicatorView.startAnimating()
        self.isHidden = false
        self.setProperties(alpha: startAlpha, transform: startTransform)
        
        UIView.animate(withDuration: duration) {
            self.setProperties(alpha: self.endAlpha, transform: self.endTransform)
        }
    }
    
    func stopAnimation(completion: (() -> Void)? = nil) {
        indicatorView.stopAnimating()
        self.isHidden = false
        self.setProperties(alpha: endAlpha, transform: endTransform)
        
        UIView.animate(withDuration: duration, animations: {
            self.setProperties(alpha: self.startAlpha, transform: self.startTransform)
        }, completion: { _ in
            self.isHidden = true
            
            self.shadowView?.removeFromSuperview()
            self.shadowView = nil
            self.removeFromSuperview()
            
            completion?()
        })
    }
    
    private func getWindow() -> UIWindow {
        let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
        return applicationDelegate.window!
    }
    
}

// MARK: Superview

extension LoadingActivityIndicatorView {
    
    fileprivate func subviewFromView(_ superview: UIView) {
        let shadowView = UIView()
        self.shadowView = shadowView
        
        self.translatesAutoresizingMaskIntoConstraints = false
        shadowView.addSubview(self)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: shadowView.centerXAnchor),
            centerYAnchor.constraint(equalTo: shadowView.centerYAnchor),
            widthAnchor.constraint(equalTo: shadowView.widthAnchor, multiplier: 0.25),
            widthAnchor.constraint(equalTo: heightAnchor)
        ])
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(shadowView)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: superview.topAnchor),
            shadowView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            shadowView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
        
        superview.layoutIfNeeded()
    }
    
}
