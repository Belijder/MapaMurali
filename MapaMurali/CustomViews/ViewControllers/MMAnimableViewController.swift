//
//  MMAnimableViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 18/01/2023.
//

import UIKit

class MMAnimableViewController: MMDataLoadingVC {
    
    //MARK: - Properties
    var selectedCell: AnimatorCellProtocol?
    var selectedCellImageViewSnapshot: UIView?
    var windowSnapshot: UIView?
    
    var animator: Animator?
    var cellShape: CellShape?
    
    
    //MARK: - Logic
    func setSnapshotsForAnimation() {
        self.selectedCellImageViewSnapshot = self.selectedCell?.muralImageView.snapshotView(afterScreenUpdates: false)
        self.windowSnapshot = self.view.window?.snapshotView(afterScreenUpdates: true)
    }
    
    
    func prepereAndPresentDetailVCWithAnimation(mural: Mural, databaseManager: DatabaseManager) {
        self.showLoadingView(message: nil)
        
        let destVC = MuralDetailsViewController(muralItem: mural, databaseManager: databaseManager, presentingVCTitle: self.title)
        destVC.modalPresentationStyle = .fullScreen
        destVC.transitioningDelegate = self
        
        do {
            try ImagesManager.shared.fetchDownsampledImageFromDirectory(from: mural.imageURL, imageType: .fullSize, name: mural.docRef, uiImageSize: destVC.imageView.bounds.size, completed: { image in
                destVC.imageView.image = image
                self.dismissLoadingView()
                self.present(destVC, animated: true)
                print("🔵 Zdjęcie downsamplowane")
            })
        } catch {
            ImagesManager.shared.downloadImage(from: mural.imageURL, imageType: .fullSize, name: mural.docRef) { image in
                DispatchQueue.main.async {
                    destVC.imageView.image = image
                    self.dismissLoadingView()
                    self.present(destVC, animated: true)
                }
                print("🔵 Zdjęcie pobrane")
            }
        }
    }
}

//MARK: - Extensions
extension MMAnimableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard let muralsCollectionVC = source as? MMAnimableViewController,
              let muralDetailsVC = presented as? MuralDetailsViewController,
              let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot,
              let windowSnapshot = windowSnapshot,
              let cellShape = cellShape
        else {
            return nil
        }

        animator = Animator(type: .present, firstViewController: muralsCollectionVC, secondViewController: muralDetailsVC, selectedCellImageSnapshot: selectedCellImageViewSnapshot, windowSnapshot: windowSnapshot, cellShape: cellShape)
        
        return animator
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let muralDetailsVC = dismissed as? MuralDetailsViewController,
              let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot,
              let windowSnapshot = windowSnapshot,
              let cellShape = cellShape
        else { return nil }

        animator = Animator(type: .dismiss, firstViewController: self, secondViewController: muralDetailsVC, selectedCellImageSnapshot: selectedCellImageViewSnapshot, windowSnapshot: windowSnapshot, cellShape: cellShape)

        return animator
    }
}
