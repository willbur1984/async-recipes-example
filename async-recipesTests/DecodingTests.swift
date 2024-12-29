//
//  DecodingTests.swift
//  async-recipesTests
//
//  Created by William Towe on 12/27/24.
//

import XCTest
@testable import async_recipes

enum DecodingTestError: Error {
    case dataWasNil
}

final class DecodingTests: XCTestCase {
    func testRecipeDecodeSuccess() throws {
        let json = """
{
    "uuid": "92eb96e5-4f02-469f-8a19-01900a36f7ce",
    "name": "Test",
    "cuisine": "Test"
}
"""
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingTestError.dataWasNil
        }
        XCTAssertNoThrow(try JSONDecoder().decode(Recipe.self, from: data))
    }
    
    func testRecipeDecodeFailure() throws {
        let json = """
{
    "uuid": "92eb96e5-4f02-469f-8a19-01900a36f7ce",
    "cuisine": "Test"
}
"""
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingTestError.dataWasNil
        }
        XCTAssertThrowsError(try JSONDecoder().decode(Recipe.self, from: data))
    }
    
    func testRecipesResponseSuccess() throws {
        let json = """
{
    "recipes": [
        {
            "uuid": "92eb96e5-4f02-469f-8a19-01900a36f7ce",
            "name": "Test",
            "cuisine": "Test"
        },
        {
            "uuid": "79639352-7bf0-4997-9c1a-654e44dbf506",
            "name": "Test",
            "cuisine": "Test"
        }
    ]
}
"""
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingTestError.dataWasNil
        }
        let response = try JSONDecoder().decode(RecipesResponse.self, from: data)
        
        XCTAssertFalse(response.recipes.isEmpty)
    }
    
    func testRecipesResponseEmpty() throws {
        let json = """
{
    "recipes": []
}
"""
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingTestError.dataWasNil
        }
        let response = try JSONDecoder().decode(RecipesResponse.self, from: data)
        
        XCTAssertTrue(response.recipes.isEmpty)
    }
    
    func testRecipesResponseFailure() throws {
        let json = """
{
    "recipes": [
        {
            "uuid": "92eb96e5-4f02-469f-8a19-01900a36f7ce",
            "name": "Test",
            "cuisine": "Test"
        },
        {
            "uuid": "79639352-7bf0-4997-9c1a-654e44dbf506",
            "cuisine": "Test"
        }
    ]
}
"""
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingTestError.dataWasNil
        }
        XCTAssertThrowsError(try JSONDecoder().decode(RecipesResponse.self, from: data))
    }
}
