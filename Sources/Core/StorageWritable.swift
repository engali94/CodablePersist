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

/// A protocol conformed by objects that can be stored in the storage.
///
/// **Assumptions**:
///   - `CodablePersist` creates objects with the associated keys.
///   - The objects are stored in unique paths
///   - Each key represents only one object on that path.
public protocol StorageWritable {
    associatedtype T: Identifiable

    /// Saves an objectto the storage, each type conforming to `Identifiable`, will have a uniuqe ID
    /// this  will be  extracted  from that object to to uniuqely identify it. If `DiskStorage` is usedit  will
    /// use that key to  generate a uniqe path to the object in the storage, also in the other storages will
    /// be used as amunique identifier
    ///
    /// - Parameters:
    ///   - object: The object wanted to be stored..
    /// - Throws: Error encountered during the saving process (e.g. Path incorrect, or Encoding falied).
    func save(_ object: T) throws
    
    /// Saves multiple object in the storage one time.
    ///
    /// - Parameters:
    ///   - objects: An array of objects wanted to be stored..
    /// - Throws: Error encountered during the saving process (e.g. Path incorrect, or Encoding falied).
    func save(_ objects: [T]) throws
    
}
