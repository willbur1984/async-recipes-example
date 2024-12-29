//
//  ImageManager.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Combine
import Foundation
import os.log
import UIKit

/**
 Manages requesting images from remote urls and caching them on disk and memory (using `NSCache`)
 */
final class ImageManager {
    // MARK: - Public Types
    /**
     Represents caching options.
     */
    struct Options: OptionSet {
        // MARK: - Public Properties
        let rawValue: Int
        
        /**
         Cache images in memory using `NSCache`.
         */
        static let cacheInMemory = Options(1 << 0)
        /**
         Cache images on disk.
         */
        static let cacheOnDisk = Options(1 << 1)
        /**
         Convenience for all options.
         */
        static let all: Options = [.cacheInMemory, .cacheOnDisk]
        
        // MARK: - Initializers
        init(_ rawValue: Int) {
            self.init(rawValue: rawValue)
        }
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /**
     Holds a returned image and the caching options that were used to retrieve the image.
     */
    struct ImageResult {
        // MARK: - Public Properties
        /**
         The image.
         */
        let image: UIImage?
        /**
         The caching options used to retrieve the image.
         */
        let options: Options
        
        // MARK: - Public Functions
        /**
         Returns the nil result instance.
         */
        static func nilResult() -> ImageResult {
            .init(image: nil, options: [])
        }
    }
    
    // MARK: - Public Properties
    /**
     Returns the shared singleton instance.
     */
    static let shared = ImageManager()
    static let defaultDirectoryName = "Images"
    
    // MARK: - Private Properties
    // NSCache is already thread safe
    private let cache = NSCache<NSString, UIImage>()
    private var cancellables = Set<AnyCancellable>()
    @ThreadSafe
    private var diskCacheDirectoryName = ImageManager.defaultDirectoryName
    
    // MARK: - Public Functions
    /**
     Clear the memory cache.
     */
    func clearMemoryCache() {
        self.cache.removeAllObjects()
    }
    
    /**
     Clear the disk cache by deleting any cached files within the disk cache directory (e.g. Caches/Images).
     */
    func clearDiskCache() {
        guard let directoryURL = self.directoryURL(), let enumerator = FileManager.default.enumerator(at: directoryURL, includingPropertiesForKeys: nil) else {
            return
        }
        for case let fileURL as URL in enumerator {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    /**
     Sets the disk cache directory name to `value`.
     
     - Parameter value: The disk cache directory name, defaults to `ImageManager.defaultDirectoryName`
     */
    func setDiskCacheDirectoryName(_ value: String = ImageManager.defaultDirectoryName) {
        guard value.isEmpty.not() else {
            os_log("Cannot set disk cache directory name to an empty string", type: .error)
            return
        }
        self.diskCacheDirectoryName = value
    }
    
    /**
     Asynchronously returns an image for the provided remote `url`.
     
     - Parameter url: The image url
     - Parameter options: The caching options to apply
     - Returns: The image
     */
    func image(
        forURL url: URL,
        options: Options = .all
    ) async -> ImageResult {
        do {
            // check the url scheme
            switch url.scheme?.lowercased() {
            case "http", "https":
                break
            default:
                os_log("Unsuported url scheme %@", type: .error, String(describing: url.scheme))
                return .nilResult()
            }
            // create the key used to cache images on disk and in memory
            guard let key = url.toSHA1String() else {
                return .nilResult()
            }
            // attempt to fetch a cached image from memory and return it immediately if it exists
            if options.contains(.cacheInMemory), let cachedImage = self.cache.object(forKey: key as NSString) {
                os_log("cache hit in memory for key %@", key)
                return .init(image: cachedImage, options: .cacheInMemory)
            }
            // create the directory url where images will be cached on disk
            guard let directoryURL = self.directoryURL() else {
                return .nilResult()
            }
            // if the directory url for caching images on disk does not exist, attempt to create it
            if options.contains(.cacheOnDisk), directoryURL.isFileURLReachable.not() {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
            let fileURL = directoryURL.appending(path: key)
            
            // if the file url is reachable, the image has been cached to disk
            guard fileURL.isFileURLReachable else {
                // attempt to download the image data
                os_log("downloading image with url %@", url.absoluteString)
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // cache the downloaded image data on disk
                if options.contains(.cacheOnDisk) {
                    os_log("caching image on disk for key %@", key)
                    try data.write(to: fileURL)
                }
                
                // return the image created from the downloaded data
                return .init(image: UIImage(data: data)?.also {
                    // cache the image in memory
                    self.cacheImage($0, forKey: key, options: options)
                }, options: [])
            }
            os_log("cache hit on disk for key %@", key)
            
            // create data from the file url, return the image created from the data
            return .init(image: UIImage(data: try Data(contentsOf: fileURL))?.also {
                // cache the image in memory
                self.cacheImage($0, forKey: key, options: options)
            }, options: .cacheOnDisk)
        }
        catch {
            os_log("%@", type: .error, String(describing: error))
            return .nilResult()
        }
    }
    
    // MARK: - Private Functions
    private func directoryURL() -> URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: self.diskCacheDirectoryName, directoryHint: .isDirectory)
    }
    
    private func cacheImage(_ image: UIImage, forKey key: String, options: Options) {
        guard options.contains(.cacheInMemory) else {
            return
        }
        os_log("caching image in memory for key %@", key)
        self.cache.setObject(image, forKey: key as NSString)
    }
    
    // MARK: - Initializers
    init() {
        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                // clear memory cache in response to memory pressure
                self?.clearMemoryCache()
            }
            .store(in: &self.cancellables)
    }
}
