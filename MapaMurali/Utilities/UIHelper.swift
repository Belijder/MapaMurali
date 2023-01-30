//
//  UIHelper.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit

enum UIHelper {
    static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 6
        let minimumItemSpacing: CGFloat = 4
        let availebleWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availebleWidth / 3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4
        
        return flowLayout
    }
}
