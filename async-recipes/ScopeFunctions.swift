//
//  ScopeFunctions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
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

import Foundation

/// I include this in every iOS project I create, one of the best features of Kotlin https://kotlinlang.org/docs/scope-functions.html
/// Normally, I would include the entire library (of which I am the primary author), but did not per the requirements. Instead I cherry picked what I needed from https://github.com/Kosoku/Feige/blob/main/Feige/ScopeFunctions.swift
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
