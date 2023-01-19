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
    
    init() {
        createFolderIfNeeded()
    }
    
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
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
                print("🟢 Success creating folder: \(folderName) in caches directory.")
            } catch let error {
                print("🔴 Error creating folder in caches directory. \(error)")
            }
        } else {
            print("🟡 Folder \(folderName) exists.")
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
        
        do {
            try FileManager.default.removeItem(atPath: path)
            print("🟢 Success deleting Folder \(folderName) from caches directory.")
        } catch let error {
            print("🔴 Error deleting Folder: \(folderName) from caches directory. ERROR: \(error)")
        }
    }
    
    func saveImage(image: UIImage, imageType: ImageType, name: String) {
        
        guard let data = image.jpegData(compressionQuality: 1.0),
              let path = getPathForImage(imageType: imageType, name: name) else {
            print("🔴 Error getting data.")
            return
        }
        
        
        do {
            try data.write(to: path)
            print("🟢 Success saveing image: \(String(imageType.rawValue.dropLast())+name).jpg to cachesDirectory.")
        } catch {
            print("🔴 Error saveing image: \(String(imageType.rawValue.dropLast())+name).jpg to cachesDirectory.")
        }
    }
    
    func getImage(imageType: ImageType, name: String) -> UIImage? {
        guard let path = getPathForImage(imageType: imageType, name: name)?.path,
              FileManager.default.fileExists(atPath: path) else {
            print("🔴 Error getting Path ")
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
    
    func deleteImage(imageType: ImageType, name: String) {
        
        guard let path = getPathForImage(imageType: imageType, name: name)?.path,
              FileManager.default.fileExists(atPath: path) else {
            print("🔴 Error getting Path ")
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: path)
            print("🟢 Successfully deleted.")
        } catch let error {
            print("Error deleting image. \(error)")
        }
    }
    
    private func getPathForImage(imageType: ImageType, name: String) -> URL? {
        
        let imageTypeString = String(imageType.rawValue.dropLast())
        
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent("\(imageTypeString+name).jpg") else {
            print("🔴 Error getting path to File Manager for path component: \(imageTypeString+name).jpg")
            return nil
        }
        
        return path
    }
}
