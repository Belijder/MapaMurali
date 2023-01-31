//
//  NetworkManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import Foundation
import UIKit

class ImagesManager {
    
    static let shared = ImagesManager()
    let persistanceManager = PersistenceManager.instance

    
    func fetchDownsampledImageFromDirectory(from urlString: String, imageType: ImageType, name: String, uiImageSize: CGSize, completed: @escaping (UIImage?) -> Void) throws {
        if let path = persistanceManager.getPathForImage(imageType: imageType, name: name) {
            do {
                let image = try downsample(imageAt: path, to: uiImageSize)
                print("🟢 Success to downsample image from persistance Manager.")
                
                completed(image)
            } catch let error {
                throw error
            }
        }
    }
    
    
    func saveDownsampledImageInDirectory(image: UIImage, imageType: ImageType, name: String) {
        self.persistanceManager.saveImage(image: image, imageType: imageType, name: name)
    }
    

    func downsample(imageAt imageURL: URL,
                    to pointSize: CGSize,
                    scale: CGFloat = UIScreen.main.scale) throws -> UIImage? {
        
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            print("Error imageSource is nil")
            throw MMError.defaultError
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            print("Error downsample image is nil")
            throw MMError.defaultError
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    
    func downloadImage(from urlString: String, imageType: ImageType, name: String, completed: @escaping (UIImage?) -> Void) {
        if let image = persistanceManager.getImage(imageType: imageType, name: name) {
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            if imageType == .fullSize {
                do {
                    let downSampledimage = try self.downsample(imageAt: url, to: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 3 * 4))
                    self.saveDownsampledImageInDirectory(image: downSampledimage!, imageType: imageType, name: name)
                    print("Image downsamled saved.")
                } catch  {
                    self.persistanceManager.saveImage(image: image, imageType: imageType, name: name)
                }
            } else {
                self.persistanceManager.saveImage(image: image, imageType: imageType, name: name)
            }

            completed(image)
        }
        
        dataTask.resume()
    }
}
