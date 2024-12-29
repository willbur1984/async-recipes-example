//
//  ImageManagerTests.swift
//  async-recipesTests
//
//  Created by William Towe on 12/29/24.
//

import os.log
import XCTest
@testable import async_recipes

final class ImageManagerTests: XCTestCase {
    func testImageManagerSuccess() {
        let manager = ImageManager()
        
        manager.setDiskCacheDirectoryName(UUID().uuidString)
        manager.clearDiskCache()
        
        let expectation = XCTestExpectation()
        var result = ImageManager.ImageResult.nilResult()
        Task {
            result = await manager.image(forURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg")!)
            expectation.fulfill()
        }
        wait(for: [expectation])
        XCTAssertNotNil(result.image)
        XCTAssertTrue(result.options.isEmpty)
    }
    
    func testImageManagerSuccessOnDisk() {
        let manager = ImageManager()
        
        manager.setDiskCacheDirectoryName(UUID().uuidString)
        manager.clearDiskCache()
        
        let expectation = XCTestExpectation()
        var result = ImageManager.ImageResult.nilResult()
        Task {
            let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg")!
            let options = ImageManager.Options.cacheOnDisk
            
            result = await manager.image(forURL: url, options: options)
            result = await manager.image(forURL: url, options: options)
            
            expectation.fulfill()
        }
        wait(for: [expectation])
        XCTAssertNotNil(result.image)
        XCTAssertTrue(result.options.contains(.cacheOnDisk))
    }
    
    func testImageManagerSuccessInMemory() {
        let manager = ImageManager()
        
        manager.setDiskCacheDirectoryName(UUID().uuidString)
        manager.clearDiskCache()
        
        let expectation = XCTestExpectation()
        var result = ImageManager.ImageResult.nilResult()
        Task {
            let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg")!
            let options = ImageManager.Options.cacheInMemory
            
            result = await manager.image(forURL: url, options: options)
            result = await manager.image(forURL: url, options: options)
            
            os_log("%@", String(describing: result))
            
            expectation.fulfill()
        }
        wait(for: [expectation])
        XCTAssertNotNil(result.image)
        XCTAssertTrue(result.options.contains(.cacheInMemory))
    }
    
    func testImageManagerFailure() {
        let manager = ImageManager()
        
        let expectation = XCTestExpectation()
        var result = ImageManager.ImageResult.nilResult()
        Task {
            result = await manager.image(forURL: URL(string: "file://test.jpg")!)
            
            expectation.fulfill()
        }
        wait(for: [expectation])
        XCTAssertNil(result.image)
    }
}
