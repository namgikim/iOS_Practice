//
//  ImageFileManager.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/13.
//

import UIKit

class ImageFileManager {
    static let shared: ImageFileManager = ImageFileManager()
    
    // MARK: - Properties
    var imageDirectoryURL: URL? = {
        return try? FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false) as URL
    }()
    
    let imageDataDirectoryURL: URL? = {
        return try? FileManager.default.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true).appendingPathComponent("imageData.json")
    }()
}

extension ImageFileManager {

    // MARK: - Methods
    func saveImage(image: UIImage, name: String, success: @escaping ((Bool) -> Void)) {
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else { return }
        
        let imageURL: URL = imageDirectoryURL.appendingPathComponent(name)
        
        guard let data: Data = image.jpegData(compressionQuality: 1) else { return }
        
        do {
            try data.write(to: imageURL)
            self.saveImageData(imageData: ImageData(name: name,
                                                    date: Date()))
            success(true)
        } catch {
            print(error.localizedDescription)
            success(false)
        }
    }
    
    func loadImage() -> UIImage? {
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else { return nil }
        
        guard let name: String = self.loadImageData()?.name else { return nil }
        
        let imagePath: String = imageDirectoryURL.appendingPathComponent(name).path
        
        let image: UIImage? = UIImage(contentsOfFile: imagePath)
        
        return image
    }
    
    func removeImage(completion: @escaping ((Bool) -> Void)) {
        guard let name: String = self.loadImageData()?.name else { return }
        guard let imageDirectoryURL: URL = self.imageDirectoryURL else { return }
        
        let path: String = imageDirectoryURL.appendingPathComponent(name).path
        do {
            try FileManager.default.removeItem(atPath: path)
            self.saveImageData(imageData: ImageData(name: "none", date: Date()))
            completion(true)
            
        } catch {
            completion(false)
            print(error.localizedDescription)
        }
    }
    
}

extension ImageFileManager {
    
    struct ImageData: Codable{
        var name: String
        var date: Date
    }
    
    func saveImageData(imageData: ImageData) {
        guard let imageDataDirectoryURL: URL = self.imageDataDirectoryURL else { return }
        
        do {
            let data: Data = try JSONEncoder().encode(imageData)
            try data.write(to: imageDataDirectoryURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadImageData() -> ImageData? {
        guard let imageDataDirectoryURL: URL = self.imageDataDirectoryURL else { return nil }
        
        do {
            let data: Data = try Data(contentsOf: imageDataDirectoryURL)
            let imageData: ImageData = try JSONDecoder().decode(ImageData.self, from: data)
            return imageData
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
