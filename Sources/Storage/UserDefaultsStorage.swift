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

/// User Defaults Storage utilizes `UserDefaults`  to cache  and retrive data to and from
/// UserDefaluts it gives a  convenient  and easy to use way  to cache  any `Codable`  and `Identifiable`
///  object.  **WARNING**:  **Don't use it for  heavy and large   number of objects**
/// Consider using `DiskStorage` for heavy and long term persistence.
public class UserDefaultsStorage<T: Identifiable & Codable> {
    
    /// Default Store.
    private var defaultsStore: UserDefaults
    
    /// Object's expiry date.
    public let expiryDate: SorageDateDescriptor
    
    /// Uniuqe store name.
    public var storeName: String
    
    /// JSON encoder to be used for encoding objects to be stored.
    public let encoder: JSONEncoder

    /// JSON decoder to be used to decode stored objects.
    public let decoder: JSONDecoder
    
    /// Key tracker used to keep track ob uniqe keys of objects stored in the store
    private var keyTracker: KeyTracker
   
    /// injectable `Date` object.
    private let dateProvider: () -> Date
    
    /// Initialize DefalutStorage with the given name and expiry date.
    ///
    /// - Parameters:
    ///     - storeName: Defalut storage unique identifier.
    ///     - dateProvider: injectable date object
    ///     - encoder: JSON encoder to be used for encoding objects to be stored.
    ///     - decoder: SON decoder to be used to decode stored objects.
    ///     - expiryDate: The expiry date of each object being stored.
    required public init?(
        storeName: String,
        dateProvider: @escaping () -> Date = Date.init,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init(),
        expiryDate: SorageDateDescriptor = .never) {
        
        self.storeName = storeName
        self.dateProvider = dateProvider
        self.encoder = encoder
        self.decoder = decoder
        self.expiryDate = expiryDate
        self.keyTracker = KeyTracker(keysStoreName: storeName + "-keys")
        
        keyTracker.listAllKeys()
        guard let defaultsStore = UserDefaults(suiteName: storeName) else { return nil }
        self.defaultsStore = defaultsStore
    }
    
}

// MARK: - CacheStorable

extension UserDefaultsStorage: CacheStorable {
    
    public func save(_ object: T) throws {
        let entry = ObjectDescriptor<T>(object: object, expiryDate: expiryDate.expireDate, creationDate: dateProvider())
        let data = try encoder.encode(entry)
        let key = extractKey(from: object)
        defaultsStore.set(data, forKey: key )
        keyTracker.keys.insert(key)
        keyTracker.updateKeysStore()
    }
      
    public func save(_ objects: [T]) throws {
          
        for object in objects {
            try save(object)
        }
    }
    
    public func fetchObject(for key: T.ID) throws -> T? {
        
        guard let data = defaultsStore.data(forKey: reverseKey(from: key)) else { return nil }
        let entry = try decoder.decode(ObjectDescriptor<T>.self, from: data)
        
        if !entry.isExpired {
            return entry.object
        }
        return nil
    }
    
    public func fetchObjects(for keys: [T.ID]) throws -> [T]? {
        
        return try keys.compactMap { try fetchObject(for: $0) }
    }
    
    public func fetchAllObjects(descending: Bool = true) throws -> [T]? {
        
        return try listAllObjects().sorted { (en1, en2) -> Bool in
            if descending {
                return en1.creationDate.compare(en2.creationDate) == .orderedDescending
            } else {
                return en1.creationDate.compare(en2.creationDate) == .orderedAscending
            }
        }.map { $0.object }
    }
    
    public func fetchObjectsStored(inLast interval: SorageDateDescriptor) throws -> [T] {
        
        return try listAllObjects().filter { $0.creationDate >= interval.toDate }.map { $0.object }
    }
    
    public func fetchObjectsStored(before interval: SorageDateDescriptor) throws -> [T] {
        
        return try listAllObjects().filter { $0.creationDate <= interval.toDate }.map { $0.object }
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
        // Remove expired objects first
        // then calculate the objects countn from keys.
        deleteExpired()
        return keyTracker.keys.count
    }
    
    public subscript(key: T.ID) -> T? {
        get {
             return try? fetchObject(for: key)
        }
        set {
            guard let value = newValue else {
            // If nil was assigned using subscript,
            // then we remove any value for that key:
            try? deleteObject(forKey: key)
            return
        }
         try? save(value)
        }
    }
    
    public func deleteObject(forKey key: T.ID) throws {
        let objectKey = reverseKey(from: key)
        defaultsStore.removeObject(forKey: objectKey)
        keyTracker.keys.remove(objectKey)
        keyTracker.updateKeysStore()
    }
    
    public func deleteObjects(forKeys keys: [T.ID]) throws {
        for key in keys {
            try deleteObject(forKey: key)
        }
    }
    
    public func deleteAll() throws {
        
        for key in keyTracker.keys {
            defaultsStore.removeObject(forKey: key)
        }
        
        keyTracker.keys.removeAll()
        keyTracker.updateKeysStore()
    }
    
    public func deleteExpired() {
        _ = try? listAllObjects()
    }
    
}

// MARK: - Helpers

private extension UserDefaultsStorage {
    
    /// List all objects in the store and filter the expired ones
    ///
    /// - Throws: JSON decoding error.
    /// - Returns: array of `StorableObject`.
    @discardableResult
    func listAllObjects() throws-> [ObjectDescriptor<T>] {
        
        return try keyTracker.keys.compactMap { key  in
            guard let data = defaultsStore.data(forKey: key) else { return nil }
            let entry = try decoder.decode(ObjectDescriptor<T>.self, from: data)
            if !entry.isExpired {
                return entry
            } else {
                // If the object has aleady expired
                // delete it and return nil
                try deleteObject(forKey: entry.key)
                return nil
            }
        }
    }
    
    /// ectract and convert the key asscoated with the object to string.
    ///
    ///  - Parameters:
    ///     - object: object.
    /// - Returns: unique key represented by a string.
    func extractKey(from object: T) -> String {
        return "\(storeName)-\(object[keyPath: T.idKey])"
    }
    
    /// ectract and convert the key asscoated with the object to string.
    ///
    ///  - Parameters:
    ///     - id: object's unique id.
    /// - Returns: unique key represented by a string.
    func reverseKey(from id: T.ID) -> String {
        return "\(storeName)-\(id)"
    }
}

// MARK: - KeyTracker
private extension UserDefaultsStorage {
    
    /// Helper struct to keep trackk of the keys in the store
    struct KeyTracker {
        /// store keys
        var keys = Set<String>()
        
        /// A seperate store to hold the keys values.
        let keysStore: UserDefaults?
        
        /// Unique name for keys store
        let keysStoreName: String
        
        init(keysStoreName: String) {
            self.keysStoreName = keysStoreName
            self.keysStore = UserDefaults(suiteName: keysStoreName)
        }
        
        /// list all keys in the store
        mutating func listAllKeys() {
            let keys = keysStore?.array(forKey: keysPath) as? [String] ?? []
            self.keys = Set(keys)
        }
        
        /// update store with the new keys after each addition or deletion happens
        func updateKeysStore() {
            let keysArray = Array(keys)
            keysStore?.set(keysArray, forKey: keysPath)
        }
        
        /// Path to store the keys in the keysStore.
        var keysPath: String {
            return keysStoreName + "-keys"
        }
    }
}
