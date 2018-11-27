//
//  InformationPlayerViewController.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 6/23/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class InformationPlayerViewController: UIViewController {

    @IBOutlet weak var avatarImageView: AnimatedCircleImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    
    var store: PlayerStore!
    var action: PlayerAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.configure()
        
        bindStore()
        bindAction()
//        customScrollView()
//        setupPageView()
    }
    
    func setupPageView() {
        let pageVC = UIStoryboard.player.controller(of: BasePageViewController.self)
        pageVC.orderedViewControllers = (0...20).map({ (_) -> UIViewController in
            let controller = UIViewController()
            controller.view.shadowed()
            controller.view.backgroundColor = UIColor(hue: .random(in: 0...1), saturation: .random(in: 0...1), brightness: .random(in: 0.4 ... 0.7), alpha: 1)
            return controller
        })
        
        let size = UIScreen.main.bounds.width - 40
        let containerPageView = UIView(frame: CGRect(x: 20, y: avatarImageView.frame.minY, width: size, height: size))
        view.addSubview(containerPageView)
        addController(pageVC, in: containerPageView)
    }
    
    fileprivate func customScrollView() {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        let scrollSize = view.bounds
        let customHeight = scrollSize.width + 80
        scrollView.frame = CGRect(x: 0,
                                  y: (view.frame.height - customHeight) / 2 - 80,
                                  width: scrollSize.width,
                                  height: customHeight)
        scrollView.contentInset = UIEdgeInsets.zero
        
        let views = (1...10).map { (_) -> UIView in
            let view = UIView()
            view.backgroundColor = UIColor(hue: .random(in: 0...1), saturation: .random(in: 0...1), brightness: .random(in: 0.4...0.7), alpha: 1)
            view.shadowed()
            return view
        }
        
        for (index, view) in views.enumerated() {
            view.frame = CGRect(x: CGFloat(index) * scrollSize.width,
                                y: 0,
                                width: scrollSize.width,
                                height: customHeight)
            scrollView.addSubview(view)
        }
        
        scrollView.contentSize = CGSize(width: scrollSize.width * CGFloat(views.count), height: customHeight)
        view.addSubview(scrollView)
    }
    
    var currentPage: Int?
    var pendingIndex: Int = 0
}

extension InformationPlayerViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pendingIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if pendingIndex >= 0, let page = currentPage, pendingIndex != page {
            print("change page from \(pendingIndex) to \(page)")
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(floor(targetContentOffset.pointee.x / scrollView.frame.width))
        if pendingIndex != page {
            currentPage = page
        }
    }
}

// MARK: Store

extension InformationPlayerViewController {
    
    func bindStore() {
        store.track.asObservable()
            .map { track in track.avatar }
            .bind(to: avatarImageView.rx.image)
            .addDisposableTo(rx_disposeBag)
        
        store.track.asObservable()
            .subscribe(onNext: { [weak self] track in
                self?.songLabel.text = track.name
                self?.singerLabel.text = track.singer
            })
            .addDisposableTo(rx_disposeBag)
        
        store.playButtonState.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .playing:  self?.avatarImageView.startAnimating()
                case .paused:   self?.avatarImageView.stopAnimating()
                }
            })
            .addDisposableTo(rx_disposeBag)
    }
    
}

// MARK: Action

extension InformationPlayerViewController {
    
    func bindAction() {
        
    }
    
}
