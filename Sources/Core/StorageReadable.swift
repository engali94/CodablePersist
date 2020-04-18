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

/// A protocol conformed by objects that can be read from the storage.
public protocol StorageReadable {
    associatedtype T: Identifiable
    
    /// Retrives single object from the storage.
    ///
    /// - Parameters:
    ///   - key: Key that uniqly identifies that object.
    /// - Returns: The object fetched from the specified key.
    /// - Throws: Error encountered during the reading process (e.g. Missing object, or Decoding falied).
    func fetchObject(for key: T.ID) throws -> T?
    
    /// Retrives multiple objects from the storage.
    ///
    /// - Parameters:
    ///   - keys: An array of keys that uniqly identifies the stored objects.
    /// - Returns: Array of objects fetched from the specified keys.
    /// - Throws: Error encountered during the reading process (e.g. Missing object, or Decoding falied).
    func fetchObjects(for keys: [T.ID]) throws -> [T]?
    
    /// Retrives all valid (not expired) objects from the storage.
    ///
    /// - Parameters:
    ///   - descending: The order of the fetched results, deafults to `true`.
    /// - Returns: Array of all valid (not expired) objects fetched from the storage.
    /// - Throws: Error encountered during the reading process (e.g. Missing object, or Decoding falied).
    func fetchAllObjects(descending: Bool) throws -> [T]?
    
    /// Retrives a chunk of objects stored _after_ a specific date. i.e in the last ten minutes.
    ///
    ///- Parameters:
    ///   - interval: An interval of time.
    /// - Returns: Array of objects fetched from the storage stored after the specified period.
    /// - Throws: Error encountered during the reading process (e.g. Missing object, or Decoding falied).
    func fetchObjectsStored(inLast interval: SorageDateDescriptor) throws -> [T]
    
    /// Retrives a chunk of objects stored _before_ a specific date. i.e before the last ten minutes.
    ///
    /// - Parameters:
    ///   - interval: An interval of time.
    /// - Returns: Array of objects fetched from the storage stored after the specified period.
    /// - Throws: Error encountered during the reading process (e.g. Missing object, or Decoding falied).
    func fetchObjectsStored(before interval: SorageDateDescriptor) throws -> [T]
    
    /// Checks if the storage contains an object with the specifed key.
    ///
    /// - Parameters:
    ///   - key: object's uniuqe identifer.
    /// - Returns: Boolean value.
    /// - Throws: Error encountered during the reading process (e.g. Missing object, or Decoding falied).
    func contains(_ key: T.ID) -> Bool
    
    /// Checks object associated with that key has expired or not.
    ///
    /// - Parameters:
    ///   - key: object's uniuqe identifer.
    /// - Returns: Boolean value.
    func isExpired(for key: T.ID) -> Bool
 
    /// Gives the count of all the objects in that store.
    ///
    /// - Returns: Objects count in the store.
    var objectsCount: Int { get }
    
    /// Retrives a single value from th store throw subscript ([])
    ///
    /// - Returns: optinal single object.
    subscript(key: T.ID) -> T? { get set } 
}
