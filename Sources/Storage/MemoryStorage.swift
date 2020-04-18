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

/// Memory Storage utilizes `NSCache` to cache and retrive data to and from memory it gives a
/// convenient  and easy to use way  to cache  any `Codable`  and  `Identifiable` object.
/// **WARNING**:  **Don't use it for heavy objects as there will be potential lose of date if any
/// memory pressure happens**.
/// Consider using `DiskStorage` for heavy and long term persistence.
final public class MemoryStorage<T: Identifiable & Codable> {
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let expiryDate: SorageDateDescriptor
    private let keyTracker = KeyTracker()
    private let dateProvider: () -> Date
    
    required public init( dateProvider: @escaping () -> Date = Date.init,
                          expiryDate: SorageDateDescriptor,
                          maxObjectsCount: Int = 50) {
        
        self.expiryDate = expiryDate
        wrapped.delegate = keyTracker
        wrapped.countLimit = maxObjectsCount
        self.dateProvider = dateProvider
        
        deleteExpired()
    }
    
}

// MARK: - CacheStorable

extension MemoryStorage: CacheStorable {

    public func save(_ object: T) {
        
        let entry = Entry(object: object,
                          creationDate: dateProvider(),
                          expirationDate: expiryDate.expireDate)
        
        let key = object[keyPath: T.idKey]
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }
       
    public func save(_ objects: [T]) {
        
        for object in objects {
             save(object)
        }
    }
    
    public func fetchObject(for key: T.ID) throws -> T? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)), entry.isExpired == false else {
             throw StorageError.objectUnreadable
        }
        return entry.object
    }
    
    //Use compact map here
    public func fetchObjects(for keys: [T.ID]) throws -> [T]? {
        var objects: [T] = []
        for key in keys {
            guard let object = try fetchObject(for: key) else { continue }
            objects.append(object)
        }
        return objects
    }
    
    public func fetchAllObjects(descending: Bool = true) throws -> [T]? {
        
        let entries = listEntries()
        return entries.sorted { (en1, en2) -> Bool in
            
            if descending {
                return en1.creationDate.compare(en2.creationDate) == .orderedDescending
            } else {
                return en1.creationDate.compare(en2.creationDate) == .orderedAscending
            }
        }.map { $0.object }
    }
    
    public func fetchObjectsStored(inLast interval: SorageDateDescriptor) throws -> [T] {
        let entries = listEntries()
        return entries.filter { $0.creationDate >= interval.toDate }.map { $0.object }
    }
    
    public func fetchObjectsStored(before interval: SorageDateDescriptor) throws -> [T] {
       let entries = listEntries()
       return entries.filter { $0.creationDate <= interval.toDate }.map { $0.object }
    }
    
    private func listEntries() -> [Entry] {
        var entires: [Entry] = []
        for key in keyTracker.keys {
            if let entry = wrapped.object(forKey: WrappedKey(key)), entry.isExpired == false {
                entires.append(entry)
            }
        }
        return entires
    }
    
    public subscript(key: T.ID) -> T? {
        
        get { return try? fetchObject(for: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                try? deleteObject(forKey: key)
                return
            }
             save(value)
        }
    }
    
    public func contains(_ key: T.ID) -> Bool {
        do {
             return try fetchObject(for: key) != nil
        } catch {
            return false
        }
    }
    
    public func isExpired(for key: T.ID) -> Bool {
        return !contains(key)
    }
    
    public var objectsCount: Int {
        deleteExpired()
        return keyTracker.keys.count
    }
    
    public func deleteObject(forKey key: T.ID) throws {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    public func deleteObjects(forKeys keys: [T.ID]) throws {
        for key in keys {
            try deleteObject(forKey: key)
        }
    }
    
    public func deleteAll() throws {
        wrapped.removeAllObjects()
    }
    
    public func deleteExpired() {
        let keys = keyTracker.keys
        for key in keys {
            if let entry = wrapped.object(forKey: WrappedKey(key)), entry.isExpired {
                try? deleteObject(forKey: key)
            }
        }
    }
}

// MARK: - Key Wrapper

private extension MemoryStorage {
    
    /// Key wrapper helps  make `T.ID` compatblw with `NSCache` key
    /// Should sublcalss`NSObject` to be compatible with `NSCache` key
    final class WrappedKey: NSObject {
        
        /// Objects's key
        let key: T.ID
        
        init(_ key: T.ID) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

// MARK: - KeyTracker

private extension MemoryStorage {
    
    /// Helper class to keep tracking of the objects in the memory
    final class KeyTracker: NSObject, NSCacheDelegate {
        
        /// A set of the stored keys,
        var keys = Set<T.ID>()

        /// `NSCache` delegate method get called each time the object is being evicted from memory.
        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
}

// MARK: - Entry Setup

private extension MemoryStorage {
    
    /// An Entry descibing the stored objects
    /// - seeAlso: ObjectDescriptor
    final class Entry {
      
        // The original object needs to be stored or fetched.
        let object: T
        
        /// Adds expiry date to the object
        let expirationDate: Date
        
         /// Adds creation date to the object.
        let creationDate: Date
        
        /// Object's uniuqe ID.
        let key: T.ID
        
        /// Checks wheather an object has expired or not.
        var isExpired: Bool {
            return Date() > expirationDate
        }
        
        init(object: T, creationDate: Date, expirationDate: Date) {
            self.object = object
            self.expirationDate =   expirationDate
            self.creationDate   =   creationDate
            self.key = object[keyPath: T.idKey]
        }
    }
}
