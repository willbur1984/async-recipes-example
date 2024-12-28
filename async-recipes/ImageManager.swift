//
//  ImageManager.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation
import os.log
import UIKit

final class ImageManager {
    // MARK: - Public Properties
    static let shared = ImageManager()
    
    // MARK: - Private Properties
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Public Functions
    func image(forURL url: URL) async -> UIImage? {
        do {
            guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: "Images", directoryHint: .isDirectory), let key = url.toSHA1String() else {
                return nil
            }
            if let cachedImage = self.cache.object(forKey: key as NSString) {
                os_log("retrieved cached image in memory for key %@", key)
                return cachedImage
            }
            if directoryURL.isFileURLReachable.not() {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
            let cacheURL = directoryURL.appending(path: key)
            
            guard cacheURL.isFileURLReachable else {
                os_log("downloading image with url %@", url.absoluteString)
                let (data, _) = try await URLSession.shared.data(from: url)
                
                os_log("writing image to disk at url %@", cacheURL.absoluteString)
                try data.write(to: cacheURL)
                
                return UIImage(data: data)?.also {
                    self.cacheImage($0, forKey: key)
                }
            }
            os_log("retrieved cached image on disk for key %@", key)
            
            return UIImage(data: try Data(contentsOf: cacheURL))?.also {
                self.cacheImage($0, forKey: key)
            }
        }
        catch {
            os_log("%@", type: .error, String(describing: error))
            return nil
        }
    }
    
    // MARK: - Private Functions
    private func cacheImage(_ image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key as NSString)
    }
    
    // MARK: - Initializers
    private init() {
        
    }
}
