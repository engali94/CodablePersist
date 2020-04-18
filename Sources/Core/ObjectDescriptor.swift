//
//  CodablePersist
//
//  Copyright (c) 2020 Ali A. Hilal - https://github.com/engali94
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/// Object Descriptor
///
/// Describe an object that need to be stored and retrieved.
/// - seealso: `MemoryStorage.Entry`
public struct ObjectDescriptor<T: Identifiable & Codable> {
    
    /// The original object needs to be stored or fetched.
    let object: T
    
    /// Adds expiry date to the object
    let expiryDate: Date
    
    /// Adds creation date to the object.
    let creationDate: Date
    
    /// Object's uniuqe ID.
    let key: T.ID 
    
    /// Checks wheather an object has expired or not.
    var isExpired: Bool {
        return Date() > expiryDate
    }
    
    init(object: T, expiryDate: Date, creationDate: Date ) {
        self.object = object
        self.creationDate = creationDate
        self.key = object[keyPath: T.idKey]
        self.expiryDate = expiryDate
    }
}

// MARK: Codable Conformation
extension ObjectDescriptor: Codable { }
