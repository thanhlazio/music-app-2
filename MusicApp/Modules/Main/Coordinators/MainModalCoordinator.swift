//
//  MainModalCoordinator.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 6/10/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import RxSwift

protocol MainModalCoordinator: NSObjectProtocol {
    
    @discardableResult
    func presentPlayer() -> Observable<Void>
    @discardableResult
    func setPresentPlayerInteractively() -> Observable<Void>
    
}

class MAMainModalCoordinator: NSObject, MainModalCoordinator, UIViewControllerTransitioningDelegate {
    
    weak var mainViewController: MainViewController?
    var getPlayerViewController: (() -> PlayerViewController?)?
    
    private let presentInteractiveController = PlayerPresentInteractiveController()
    private let dismissInteractiveController = PlayerDismissInteractiveController()
    
    @discardableResult
    func presentPlayer() -> Observable<Void> {
        let subject = PublishSubject<Void>()
        
        guard let mainController = mainViewController,
            let playerController = getPlayerViewController?() else { return .empty() }
        
        configurePlayerController(playerController)
        
        dismissInteractiveController.interactiveFrame = CGRect(
            x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 4 * 3)
        mainController.present(playerController, animated: true) {
            self.dismissInteractiveController.configure(viewController: playerController, presentingController: mainController)
            subject.onCompleted()
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    @discardableResult
    func setPresentPlayerInteractively() -> Observable<Void> {
        let subject = PublishSubject<Void>()
        
        guard let mainController = mainViewController,
            let playerController = getPlayerViewController?() else { return .empty() }
        
        configurePlayerController(playerController)
        
        dismissInteractiveController.interactiveFrame = CGRect(
            x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 4 * 3)
        presentInteractiveController.configure(viewController: playerController, parentViewController: mainController) { [weak self] in
            self?.dismissInteractiveController.configure(
                viewController: playerController,
                presentingController: mainController
            )
        }
        
        subject.onCompleted()
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    private func configurePlayerController(_ controller: PlayerViewController) {
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PlayerPresentAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PlayerDismissAnimationController()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentInteractiveController.interactionInProgress ? presentInteractiveController : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractiveController.interactionInProgress ? dismissInteractiveController : nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PlayerPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
