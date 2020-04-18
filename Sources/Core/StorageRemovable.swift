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

/// A protocol conformed by objects that can be removed from the storage.
///
/// **Assumptions**:
///   - `CodablePersist` creates objects with the associated keys.
///   - The objects are stored in unique paths
///   - Each kay represents only one object on that path.
///   - Each object can be removed if its unique identifer is known or its life cycle ended (i.e. expired).
public protocol StorageRemovable {
    
    associatedtype T: Identifiable
    
    /// Delete an object related to the specified key.
    ///
    /// - Parameters:
    ///   - key: The unique key for that object.
    /// - Throws: Error encountered during the deleting process (e.g. Missing object).
    func deleteObject(forKey key: T.ID) throws
    
    /// Delete  objects related to the specified keys.
    ///
    /// - Parameters:
    ///   - keys: An array of unique keys for objects wanted to be deleted.
    /// - Throws: Error encountered during the deleting process (e.g. Missing object(s)).
    func deleteObjects(forKeys keys: [T.ID]) throws
    
    /// Delete  all objects stored in the storage.
    ///
    /// - Throws: Error encountered during the deleting process (e.g. Missing object(s)).
    func deleteAll() throws
    
    /// Delete  all objects that has expired.
    func deleteExpired()
}
