import Foundation

/// Disk Storage utilizes `FileManager` to cache and retrive data to and from the disk
/// it gives a convenient and easy to use way  to cache any `Codable` and `Identifiable` object.
public class DiskStorage<T: Codable & Identifiable> {
    
    private let fileManager: FileManager

    /// Storage's name.
    ///
    /// **Warning**: This name should be  unique per storage  if you want to make two or more different storages.
    public let storeName: String
    
    /// A  `URL` refers to preferted storage dorectory.
    public let directoryUrl: URL
    
    /// A `String `path  refers to preferted storage dorectory.
    public let path: String
    
    /// Expiry date of the stored objects.
    public let expiryDate: SorageDateDescriptor
    
    /// JSON encoder to be used for encoding objects to be stored.
    open var encoder: JSONEncoder

    /// JSON decoder to be used to decode stored objects.
    open var decoder: JSONDecoder
    
    /// injectable `Date` object.
    private let dateProvider: () -> Date
   
    /// Initialize disk storage with the given name and expiry date.
    ///
    /// - Parameters:
    ///     - storeName: Disk storage unique identifier.
    ///     - directoryUrl: A  `URL` refers to preferted storage dorectory. _if not given will use `cachesDirectory`
    ///     as storage directory.
    ///     - expiryDate: The expiry date of each object being stored.
    ///     - fileManager: system's default file manager.
    ///     - encoder: JSON encoder to be used for encoding objects to be stored.
    ///     - decoder: JSON decoder to be used to decode stored objects.
    
    required public init(
        dateProvider: @escaping () -> Date = Date.init,
        storeName: String,
        directoryUrl: URL? = nil,
        expiryDate: SorageDateDescriptor = .never,
        fileManager: FileManager = FileManager.default,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
        
    ) throws {
        self.storeName = storeName
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
        self.expiryDate = expiryDate
        self.dateProvider  = dateProvider
        
        if let url = directoryUrl {
             self.directoryUrl = url
        } else {
           self.directoryUrl = try fileManager.url(
           for: .cachesDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: true)
        }

        let url =  self.directoryUrl.appendingPathComponent(storeName, isDirectory: true)
        self.path = url.path
        try createFolder(at: url)
        
    }
    
}
// MARK: - CacheStorable

extension DiskStorage: CacheStorable {

    public func save(_ object: T) throws {
        
        let entry = ObjectDescriptor<T>(object: object, expiryDate: expiryDate.expireDate, creationDate: dateProvider())
        let data = try encoder.encode(entry)
        let filePath = makePath(for: object)
               
        fileManager.createFile(atPath: filePath, contents: data, attributes: [FileAttributeKey.creationDate: Date()])
    }
     
    public func save(_ objects: [T]) throws {
        
        for object in objects {
            try save(object)
        }
    }
    
    public func fetchObject(for key: T.ID) throws -> T? {
        
        let filePath = makePath(for: key)
        guard let data = fileManager.contents(atPath: filePath) else { return nil }

        let entry =  try decoder.decode(ObjectDescriptor<T>.self, from: data)
        if !entry.isExpired {
            return entry.object
        }
        return nil
    }
       
    public func fetchObjects(for keys: [T.ID]) throws -> [T]? {
        
        return try keys.compactMap { try fetchObject(for: $0) }
    }
    
    public func fetchObjectsStored(inLast interval: SorageDateDescriptor) throws -> [T] {
        
        return try listAllEntries().filter { $0.creationDate > interval.toDate }.map { $0.object }
    }
    
    public func fetchObjectsStored(before interval: SorageDateDescriptor) throws -> [T] {
      
        return try listAllEntries().filter { $0.creationDate < interval.toDate }.map { $0.object }
    }
        
    public func fetchAllObjects(descending: Bool = true) throws -> [T]? {
      
        return try listAllEntries().sorted { (en1, en2) -> Bool in
            if descending {
                return en1.creationDate.compare(en2.creationDate) == .orderedDescending
            } else {
                return en1.creationDate.compare(en2.creationDate) == .orderedAscending
            }
        }.map { $0.object }
    }
         
    public func contains(_ key: T.ID) -> Bool {
        do {
             return try fetchObject(for: key) != nil
        } catch {
            return false
        }
       
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
       
    public func isExpired(for key: T.ID) -> Bool {
        return !contains(key)
    }
    
    public var objectsCount: Int {
        do {
            let objects = try fileManager.contentsOfDirectory(atPath: path)
            return objects.count
        } catch {
            return 0
        }
    }
      
    public func deleteObject(forKey key: T.ID) throws {
          
        let objectPath = makePath(for: key)
        try fileManager.removeItem(atPath: objectPath)
    }
    
    public func deleteObjects(forKeys keys: [T.ID]) throws {
        
        for key in keys {
            try deleteObject(forKey: key)
        }
    }
    
    public func deleteAll() throws {
        
        let objects = try fileManager.contentsOfDirectory(atPath: path)
        
        for object in objects {
            let objectPath = pathFromFileName(object)
            try fileManager.removeItem(atPath: objectPath)
        }
    }
    
    public func deleteExpired() {
        _ = try? listAllEntries()
    }
}

// MARK: - Helpers

private extension DiskStorage {
    
    /// Create folder at the specifed url
    ///
    /// - Parameters:
    ///     - url: URL to crate the folder at.
    /// - Throws: FilerManager error.
    func createFolder(at url: URL) throws {
        
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
    /// List all objects in the store and filter the expired ones
    ///
    /// - Throws: JSON decoding error.
    /// - Returns: array of `StorableObject`
    @discardableResult
    private func listAllEntries() throws -> [ObjectDescriptor<T>] {
        
        let files = try fileManager.contentsOfDirectory(atPath: path)
        return try files.compactMap { file  -> ObjectDescriptor<T>? in
            guard let data = fileManager.contents(atPath: pathFromFileName(file)) else { return nil }
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
    
    /// Extract the key from object.
    ///
    /// - Parameters:
    ///     - object: `T` object  extract they key from.
    /// - Returns: unique path component of the passed object.
    func extractKey(from object: T) -> String {
        return "\(storeName)-\(object[keyPath: T.idKey])"
    }
    
    /// Reconstructs object's name  from the passed key.
    ///
    /// - Parameters:
    ///     - id: `T.ID` key to reconstruct path from it
    /// - Returns: unique path componen from the passed key.
    func reverseKey(for id: T.ID) -> String {
        return "\(storeName)-\(id)"
    }
    
    /// Construct a path to the passed object.
    ///
    /// - Parameters:
    ///     - object: `T` object  extract they key from.
    /// - Returns: a  complete path of the passed object.
    func makePath(for object: T) -> String {
        return "\(path)/\(extractKey(from: object))"
    }
    
    /// Construct a path from the passed key.
    ///
    /// - Parameters:
    ///     - key: a `T.ID` key to reconstruct path from it
    /// - Returns: a  complete path of the passed key.
    func makePath(for id: T.ID) -> String {
        return "\(path)/\(reverseKey(for: id))"
    }
    
    /// Construct a path from the passed file name.
    ///
    /// - Parameters:
    ///     - name: a `String` file name to reconstruct path from it
    /// - Returns: a  complete path of the passed file name.
    func pathFromFileName(_ name: String) -> String {
        return path + "/" + name
    }
}
