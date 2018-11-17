//
//  BasePageViewController.swift
//  MemeApp
//
//  Created by Thành Lã on 10/10/18.
//  Copyright © 2018 MonstarLab. All rights reserved.
//

import UIKit

protocol BasePageViewControllerDelegate: class {
    func didUpdatePageIndex(_ pageViewController: BasePageViewController, pageIndex index: Int)
}

class BasePageViewController: UIPageViewController {
    
    weak var pageViewDelegate: BasePageViewControllerDelegate?
    weak var pageControl: UIPageControl?
    
    var isLoop: Bool = false
    var pageControlHidden: Bool = true
    
    var orderedViewControllers: [UIViewController] = [] {
        didSet {
            DispatchQueue.main.async {
                self.dataSource = nil
                self.dataSource = self
            }
        }
    }
    
    var defaultPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        scrollView?.delegate = self
        
        if defaultPage < orderedViewControllers.count {
            changePageTo(orderedViewControllers[defaultPage], notify: false)
        }
        
        pageControl?.numberOfPages = orderedViewControllers.count
        pageControl?.isHidden = pageControlHidden
        pageControl?.addTarget(self, action: #selector(self.pageControlDidTouched), for: .touchUpInside)
    }
    
    @objc func pageControlDidTouched() {
        guard let pageControl = pageControl else { return }
        changePage(index: pageControl.currentPage, notify: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //scrollView?.isScrollEnabled = false
        scrollView?.contentOffset.y = 0
    }
    
    func nextPage() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            changePageTo(nextViewController, direction: .forward, notify: true)
        }
    }
    
    func previousPage() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerBefore: visibleViewController) {
            changePageTo(nextViewController, direction: .reverse, notify: true)
        }
    }
    
    func changePage(index newIndex: Int, notify: Bool = true, animated: Bool = false) {
        guard newIndex < orderedViewControllers.count else { return }
        
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = (newIndex >= currentIndex) ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            changePageTo(nextViewController, direction: direction, notify: notify, animated: animated)
        }
    }
    
    func setEmptyPage() {
        setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
    }
    
    var currentViewController: UIViewController? {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            return orderedViewControllers[currentIndex]
        }
        return nil
    }
    
    func viewController(atIndex index: Int) -> UIViewController? {
        guard index < orderedViewControllers.count else { return nil }
        return orderedViewControllers[index]
    }
    
    func changePageTo(_ viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward, notify: Bool = true, animated: Bool = false) {
        setViewControllers([viewController], direction: direction, animated: animated, completion: { _ -> Void in
            guard notify else { return }
            self.notifyPageViewDelegateOfNewIndex()
        })
    }
    
    fileprivate func notifyPageViewDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first, let index = orderedViewControllers.index(of: firstViewController) {
            pageControl?.currentPage = index
            pageViewDelegate?.didUpdatePageIndex(self, pageIndex: index)
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension BasePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return isLoop ? orderedViewControllers.last : nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return isLoop ? orderedViewControllers.first : nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

// MARK: UIPageViewControllerDelegate

extension BasePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyPageViewDelegateOfNewIndex()
    }
}

// MARK: UIScrollViewDelegate

extension BasePageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }
    }
}

extension UIPageViewController {
    var scrollView: UIScrollView? {
        return self.view.subviews.compactMap { $0 as? UIScrollView }.first
    }
}
