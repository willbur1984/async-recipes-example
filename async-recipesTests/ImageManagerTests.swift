//
//  ImageManagerTests.swift
//  async-recipesTests
//
//  Created by William Towe on 12/29/24.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import os.log
import XCTest
@testable import async_recipes

final class ImageManagerTests: XCTestCase {
    func testImageManagerSuccess() {
        let manager = ImageManager().also {
            $0.setDiskCacheDirectoryName(UUID().uuidString)
            $0.clearDiskCache()
        }
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
        let manager = ImageManager().also {
            $0.setDiskCacheDirectoryName(UUID().uuidString)
            $0.clearDiskCache()
        }
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
        let manager = ImageManager().also {
            $0.setDiskCacheDirectoryName(UUID().uuidString)
            $0.clearDiskCache()
        }
        let expectation = XCTestExpectation()
        var result = ImageManager.ImageResult.nilResult()
        
        Task {
            let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg")!
            let options = ImageManager.Options.cacheInMemory
            
            result = await manager.image(forURL: url, options: options)
            result = await manager.image(forURL: url, options: options)
            
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
