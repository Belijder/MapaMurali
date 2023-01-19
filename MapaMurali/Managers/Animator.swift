//
//  Animator.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 15/01/2023.
//

import UIKit

protocol AnimatorCellProtocol: AnyObject {
    var muralImageView: MMSquareImageView { get set }
}

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //MARK: - Properities
    static let duration: TimeInterval = 3.5
    
    private let type: PresentationType
    private let firstViewController: MMAnimableViewController
    private let secondViewController: MuralDetailsViewController
    private let cellShape: CellShape
    private var selectedCellImageViewSnapshot: UIView
    private let firstVCwindowSnapshot: UIView
    private let cellImageViewRect: CGRect
    
    
    //MARK: - Initialization
    init?(type: PresentationType, firstViewController: MMAnimableViewController, secondViewController: MuralDetailsViewController, selectedCellImageSnapshot: UIView, windowSnapshot: UIView, cellShape: CellShape) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.cellShape = cellShape
        self.selectedCellImageViewSnapshot = selectedCellImageSnapshot
        firstVCwindowSnapshot = windowSnapshot
        
        guard let window = firstViewController.view.window ?? secondViewController.view.window,
              let selectedCell = firstViewController.selectedCell
        else {
            return nil
        }
        
        self.cellImageViewRect = selectedCell.muralImageView.convert(selectedCell.muralImageView.bounds, to: window)
    }
    
    //MARK: - Logic
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
        
        guard let selectedCell = firstViewController.selectedCell,
              let window = firstViewController.view.window ?? secondViewController.view.window,
              let cellImageSnapshot = selectedCell.muralImageView.snapshotView(afterScreenUpdates: true),
              let controllerImageSnapshot = secondViewController.imageView.snapshotView(afterScreenUpdates: true),
              let closeButtonSnapshot = secondViewController.closeButton.snapshotView(afterScreenUpdates: true),
              let favoriteButtonSnapshot = secondViewController.favoriteButton.snapshotView(afterScreenUpdates: true),
              let mapPinButtonSnapshot = secondViewController.mapPinButton.snapshotView(afterScreenUpdates: true),
              let deleteButtonSnapshot = secondViewController.deleteMuralButton.snapshotView(afterScreenUpdates: true)
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        secondViewController.mapPinButton.alpha = 0
        guard let muralInfoSnapshot = secondViewController.containerView.snapshotView(afterScreenUpdates: true)
        else {
            transitionContext.completeTransition(true)
            return
        }
        secondViewController.mapPinButton.alpha = 1
        
        let isPresenting = type.isPresenting
        
        let backgroundView: UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor
        
        
        if isPresenting {
            selectedCellImageViewSnapshot = cellImageSnapshot
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = firstVCwindowSnapshot
            backgroundView.addSubview(fadeView)
        }
        
        toView.alpha = 0
        
        [backgroundView, selectedCellImageViewSnapshot, controllerImageSnapshot, muralInfoSnapshot, closeButtonSnapshot, favoriteButtonSnapshot, mapPinButtonSnapshot, deleteButtonSnapshot].forEach { containerView.addSubview($0) }
        
        let controllerImageViewRect = secondViewController.imageView.convert(secondViewController.imageView.bounds, to: window)
        let closeButtonRect = secondViewController.closeButton.convert(secondViewController.closeButton.bounds, to: window)
        let favoriteButtonRect = secondViewController.favoriteButton.convert(secondViewController.favoriteButton.bounds, to: window)
        let mapPinButtoneRect = secondViewController.mapPinButton.convert(secondViewController.mapPinButton.bounds, to: window)
        let muralInfoRect = secondViewController.containerView.convert(secondViewController.containerView.bounds, to: window)
        let deleteButtonRect = secondViewController.deleteMuralButton.convert(secondViewController.deleteMuralButton.bounds, to: window)
        
        let muralInfoHidedRect = muralInfoRect.offsetBy(dx: 0, dy: muralInfoRect.size.height)
        
        
        [selectedCellImageViewSnapshot, controllerImageSnapshot].forEach { snapShot in
            snapShot.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            
            switch cellShape {
            case .circle(let radius):
                snapShot.layer.cornerRadius = isPresenting ? radius : 0
                snapShot.layer.masksToBounds = true
            case .square:
                break
            case .roundedCorners(let radius):
                snapShot.layer.cornerRadius = isPresenting ? radius : 0
                snapShot.layer.masksToBounds = true
            }
        }
        
        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0
        [controllerImageSnapshot, closeButtonSnapshot, favoriteButtonSnapshot, mapPinButtonSnapshot, deleteButtonSnapshot].forEach { $0.alpha = isPresenting ? 0 : 1 }
        
        closeButtonSnapshot.frame = closeButtonRect
        favoriteButtonSnapshot.frame = favoriteButtonRect
        mapPinButtonSnapshot.frame = mapPinButtoneRect
        deleteButtonSnapshot.frame = deleteButtonRect
        
        muralInfoSnapshot.frame = isPresenting ? muralInfoHidedRect : muralInfoRect
        
        [mapPinButtonSnapshot, muralInfoSnapshot].forEach { snapshot in
            snapshot.layer.shadowColor = UIColor.systemBackground.cgColor
            snapshot.layer.shadowOffset = isPresenting ? CGSize(width: 0, height: 0) : CGSize(width: 0, height: -4)
            snapshot.layer.shadowRadius = 4
            snapshot.layer.shadowOpacity = 0.2
        }


        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                controllerImageSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                fadeView.alpha = isPresenting ? 1 : 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
                muralInfoSnapshot.layer.shadowOffset = isPresenting ? CGSize(width: 0, height: -4) : CGSize(width: 0, height: 0)
                
                
                [self.selectedCellImageViewSnapshot, controllerImageSnapshot].forEach { snapShot in
                    switch self.cellShape {
                    case .circle(let radius):
                        snapShot.layer.cornerRadius = isPresenting ? 0 : radius
                    case .square:
                        break
                    case .roundedCorners(let radius):
                        snapShot.layer.cornerRadius = isPresenting ? 0 : radius
                    }
                }
                
            }
            
            UIView.addKeyframe(withRelativeStartTime: isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
                [closeButtonSnapshot, favoriteButtonSnapshot, mapPinButtonSnapshot, deleteButtonSnapshot].forEach { $0.alpha = isPresenting ? 1 : 0}
                mapPinButtonSnapshot.layer.shadowOffset = isPresenting ? CGSize(width: 0, height: -4) : CGSize(width: 0, height: 0)
            }
            
            UIView.addKeyframe(withRelativeStartTime: isPresenting ? 0.4 : 0, relativeDuration: 0.6) {
                muralInfoSnapshot.frame = isPresenting ? muralInfoRect : muralInfoHidedRect
                muralInfoSnapshot.layer.shadowOffset = isPresenting ? CGSize(width: 0, height: -4) : CGSize(width: 0, height: 0)
            }
            
        } completion: { _ in
            [self.selectedCellImageViewSnapshot, controllerImageSnapshot, backgroundView, closeButtonSnapshot, favoriteButtonSnapshot, mapPinButtonSnapshot, mapPinButtonSnapshot, muralInfoSnapshot, deleteButtonSnapshot].forEach { $0.removeFromSuperview() }
            
            toView.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}

enum PresentationType {
    case present
    case dismiss
    
    var isPresenting: Bool {
        return self == .present
    }
}

enum CellShape {
    case circle(radius: CGFloat)
    case square
    case roundedCorners(radius: CGFloat)
}
