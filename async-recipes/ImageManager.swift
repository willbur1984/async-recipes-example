//
//  ImageManager.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation
import os.log
import UIKit

/**
 Manages requesting images from remote urls and caching them on disk and memory (using `NSCache`)
 */
final class ImageManager {
    // MARK: - Public Properties
    /**
     Returns the shared singleton instance.
     */
    static let shared = ImageManager()
    
    // MARK: - Private Properties
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Public Functions
    /**
     Asynchronously returns an image for the provided remote `url`.
     
     - Parameter url: The remote image url
     - Returns: The image
     */
    func image(forURL url: URL) async -> UIImage? {
        do {
            // create the directory url where images will be cached on disk, create the key used to cache images on disk and in memory, return nil if either fails
            guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: "Images", directoryHint: .isDirectory), let key = url.toSHA1String() else {
                return nil
            }
            // attempt to fetch a cached image from memory and return it immediately if it exists
            if let cachedImage = self.cache.object(forKey: key as NSString) {
                os_log("retrieved cached image in memory for key %@", key)
                return cachedImage
            }
            // if the directory url for caching images on disk does not exist, attempt to create it
            if directoryURL.isFileURLReachable.not() {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
            // create the image file cache url
            let fileURL = directoryURL.appending(path: key)
            
            // if the file url is reachable, the image has been cached to disk
            guard fileURL.isFileURLReachable else {
                // attempt to download the image data
                os_log("downloading image with url %@", url.absoluteString)
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // cache the downloaded image data on disk
                try data.write(to: fileURL)
                
                // return the image created from the downloaded data
                return UIImage(data: data)?.also {
                    // cache the image in memory
                    self.cacheImage($0, forKey: key)
                }
            }
            os_log("retrieved cached image on disk for key %@", key)
            
            // create data from the file url, return the image created from the data
            return UIImage(data: try Data(contentsOf: fileURL))?.also {
                // cache the image in memory
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
