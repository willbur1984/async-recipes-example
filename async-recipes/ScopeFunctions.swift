//
//  ScopeFunctions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation

// https://kotlinlang.org/docs/scope-functions.html
protocol ScopeFunctions {}

extension ScopeFunctions {
    // MARK: - Public Functions
    func `let`<T>(_ block: (Self) throws -> T) rethrows -> T {
        try block(self)
    }
    
    func takeUnless(_ predicate: (Self) throws -> Bool) rethrows -> Self? {
        try predicate(self) ? nil : self
    }
}

extension ScopeFunctions where Self: Any {
    // MARK: - Public Functions
    func also(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var retval = self
        
        try block(&retval)
        
        return retval
    }
}

extension ScopeFunctions where Self: AnyObject {
    // MARK: - Public Functions
    func also(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        
        return self
    }
}

extension NSObject: ScopeFunctions {}
extension String: ScopeFunctions {}
extension Array: ScopeFunctions {}
