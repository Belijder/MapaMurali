//
//  Animator.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 15/01/2023.
//

import UIKit

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    static let duration: TimeInterval = 1.25
    
    private let type: PresentationType
    private let firstViewController: MuralsCollectionViewController
    private let secondViewController: MuralDetailsViewController
    private let selectedCellImageSnapshot: UIView
    private let cellImageViewRect: CGRect
    
    init?(type: PresentationType, firstViewController: MuralsCollectionViewController, secondViewController: MuralDetailsViewController, selectedCellImageSnapshot: UIView) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageSnapshot = selectedCellImageSnapshot
        
        
        guard let window = firstViewController.view.window ?? secondViewController.view.window,
              let selectedCell = firstViewController.selectedCell
        else {
            return nil
        }
        
        self.cellImageViewRect = selectedCell.muralImageView.convert(selectedCell.muralImageView.bounds, to: window)
        
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toView = secondViewController.view else {
            transitionContext.completeTransition(false)
            return
        }
        
        containerView.addSubview(toView)
        
        transitionContext.completeTransition(true)
    }
    
    
}

enum PresentationType {
    case present
    case dismiss
    
    var isPresenting: Bool {
        return self == .present
    }
}
