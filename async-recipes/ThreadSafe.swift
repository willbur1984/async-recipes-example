//
//  ThreadSafe.swift
//  async-recipes
//
//  Created by William Towe on 12/29/24.
//

import Foundation

/**
 Simple property wrapper to make a value thread safe.
 */
@propertyWrapper
struct ThreadSafe<Value> {
    // MARK: - Public Properties
    public var wrappedValue: Value {
        get {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            return self.value
        }
        set {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            self.value = newValue
        }
    }
    
    // MARK: - Private Properties
    private let lock = NSLock()
    private var value: Value
    
    // MARK: - Initializers
    init(wrappedValue value: Value) {
        self.value = value
    }
}
