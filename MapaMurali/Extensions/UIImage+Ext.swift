//
//  UIImage+Ext.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 21/09/2022.
//

import UIKit

extension UIImage {
    
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func cropImageToCircle() -> UIImage {
        let sourceImage = self
        
        let sideLenght = min(sourceImage.size.width, sourceImage.size.height)
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLenght) / 2.0
        let yOffset = (sourceSize.height - sideLenght) / 2.0
        
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLenght, height: sideLenght).integral

        let imageRendererFormat = sourceImage.imageRendererFormat
        imageRendererFormat.opaque = false
        
        let circleCroppedImage = UIGraphicsImageRenderer(
            size: cropRect.size,
            format: imageRendererFormat).image { context in
                let drawRect = CGRect(origin: .zero, size: cropRect.size)
                UIBezierPath(ovalIn: drawRect).addClip()
                let drawImageRect = CGRect(
                    origin: CGPoint(x: -xOffset, y: -yOffset),
                    size: sourceImage.size)
                sourceImage.draw(in: drawImageRect)
            }
        
        return circleCroppedImage
    }
    
    func cropImageToSquare() -> UIImage {
        let sourceImage = self
        
        let sideLenght = min(sourceImage.size.width, sourceImage.size.height)
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLenght) / 2.0
        let yOffset = (sourceSize.height - sideLenght) / 2.0
        
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLenght, height: sideLenght).integral
        
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
        
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        
        return croppedImage
    }
    
    func cropImageToVerticalRectangle() -> UIImage {
        let sourceImage = self
        
        let sideLenght = min(sourceImage.size.width, sourceImage.size.height)
        
        let sourceSize = sourceImage.size
        
        let widthLenght = (sourceSize.height / 4) * 3
        let xOffset = (sourceSize.width - sideLenght) / 2.0
        let yOffset = (sourceSize.height - sideLenght) / 2.0
        
        let cropRect = CGRect(x: xOffset, y: yOffset, width: widthLenght, height: sourceImage.size.height).integral
        
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
        
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        
        return croppedImage
    }
    
    
}
