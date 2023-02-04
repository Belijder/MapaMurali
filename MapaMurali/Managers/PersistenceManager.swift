//
//  PersistenceManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 16/01/2023.
//

import Foundation
import UIKit

class PersistenceManager {
    
    static let instance = PersistenceManager()
    private let folderName = "MapaMurali_Images"
    
    //MARK: - Initialization
    init() {
        createFolderIfNeeded()
    }
    
    //MARK: - Logic
    func createFolderIfNeeded() {
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .path else {
            return
        }
        
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
    }
    
    
    func deleteFolderWithMuralImages() {
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .path else {
            return
        }
        
        try? FileManager.default.removeItem(atPath: path)
    }
    
    
    func saveImage(image: UIImage, imageType: ImageType, name: String) {
        guard let data = image.jpegData(compressionQuality: 1.0),
              let path = getPathForImage(imageType: imageType, name: name) else {
            return
        }
        
        try? data.write(to: path)
    }
    
    
    func getImage(imageType: ImageType, name: String) -> UIImage? {
        guard let path = getPathForImage(imageType: imageType, name: name)?.path,
              FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
    
    
    func deleteImage(imageType: ImageType, name: String) {
        
        guard let path = getPathForImage(imageType: imageType, name: name)?.path,
              FileManager.default.fileExists(atPath: path) else {
            return
        }
        
        try? FileManager.default.removeItem(atPath: path)
    }
    
    
    func getPathForImage(imageType: ImageType, name: String) -> URL? {
        
        let imageTypeString = String(imageType.rawValue.dropLast())
        
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent("\(imageTypeString+name).jpg") else {
            return nil
        }
        
        return path
    }
}
