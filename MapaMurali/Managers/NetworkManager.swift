//
//  NetworkManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import Foundation
import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    
    let persistanceManager = PersistenceManager.instance
    
    let cache = NSCache<NSString, UIImage>()
    let decoder = JSONDecoder()
    
    func downloadImage(from urlString: String, imageType: ImageType, name: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
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
            
            self.cache.setObject(image, forKey: cacheKey)
            self.persistanceManager.saveImage(image: image, imageType: imageType, name: name)
            completed(image)
        }
        
        dataTask.resume()
    }
}
