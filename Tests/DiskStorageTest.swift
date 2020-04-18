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


import XCTest
@testable import CodablePersist

class DiskStorageTest: XCTestCase {
    
    var storage: DiskStorage<Post>!
    let storageName = "storageTest"
    
    override func setUp() {
        super.setUp()
        storage = try! initStorageWith(expiry: .minutes(interval: 3))
        
    }
    
    override func tearDown() {
        
        try? storage.deleteAll()
        storage = nil
        super.tearDown()
    }
    
    func testInitStorage() {
        
        XCTAssertNoThrow(try initStorageWith(expiry: .minutes(interval: 10)))
    }
    
    func testSaveSingleObject() {
       
        XCTAssertNoThrow(try storage.save(Post.singlePost))
        XCTAssertEqual(storage.objectsCount, 1)
        
    }
    
    func testSaveMultiObjects() {
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertEqual(10, storage.objectsCount)
    }
    
    func testFetchSingleObject() {
        
        XCTAssertNoThrow(try storage.save(Post.singlePost))
        XCTAssertNotNil(try? storage.fetchObject(for: 0) )
        XCTAssertEqual(0, try? storage.fetchObject(for: 0)?.id)
    }
    
    func testFetchMultiObjects() {
       
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertNotNil(try? storage.fetchObjects(for: [3,2]) )
        XCTAssertEqual("Swift Article3", try? storage.fetchObject(for: 3)?.title)
    }
 
    func testFetchAllObjects() {
       
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertEqual(10, try storage.fetchAllObjects()?.count)
    }
    
    func testObjectExpiry() {
        
        storage = try! initStorageWith(expiry: .seconds(interval: -10))
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertTrue(storage.isExpired(for: 1))
        XCTAssertEqual(0, try storage.fetchAllObjects()?.count)
       
    }
    
    func testFetchStoredInLast() {
       
        storage = try! initStorageWith(injectedDate: Date(timeIntervalSinceNow: -60 * 4))
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertNotNil(try storage.fetchObjectsStored(inLast: .minutes(interval: 3)))
        XCTAssertEqual(0 , try storage.fetchObjectsStored(before: .minutes(interval: 4)).count)
    }
    
    func testfetchStoredBefore() {
        
        storage = try! initStorageWith(injectedDate: Date(timeIntervalSinceNow: -60 * 6))
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertNotNil(try storage.fetchObjectsStored(before: .minutes(interval: 3)))
        XCTAssertEqual(0, try storage.fetchObjectsStored(inLast: .minutes(interval: 3)).count)
    }
    
    func testSubscript() {
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertTrue(storage[1]?.id == 1 )
        XCTAssertFalse(storage[3]?.title == "Swift Article1")
        storage[1] = nil
        XCTAssertNil(storage[1])
    }
    
    func testDeleteSingleObject() {
        
        XCTAssertNoThrow(try storage.save(Post.singlePost))
        XCTAssertEqual(1, storage.objectsCount)
        XCTAssertNoThrow(try storage.deleteObject(forKey: Post.singlePost.id))
        XCTAssertNil(storage[0])
    }
    
    func testDeleteMultiObjects() {
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertNoThrow(try storage.deleteObjects(forKeys: [1,2,3]))
        XCTAssertEqual(7, storage.objectsCount)
        XCTAssertNil(storage[3])
    }
    
    func testDeleteAllObjects() {
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        XCTAssertEqual(10, storage.objectsCount)
        XCTAssertNoThrow(try storage.deleteAll())
        XCTAssertEqual(0, storage.objectsCount)
    }
    
    func testStorageContains() {
        
         XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
         XCTAssert(storage.contains(2))
         XCTAssertFalse(storage.contains(12))
    }
    
    func testDeleteExpired() {
        storage = try! initStorageWith(injectedDate: Date(timeIntervalSinceNow: -60 * 6))
        
        XCTAssertNoThrow(try storage.save(Post.dummyPosts()))
        storage.deleteExpired()
        XCTAssertEqual(0, storage.objectsCount)
    }

    private func initStorageWith(injectedDate: Date) throws -> DiskStorage<Post>{
        return try DiskStorage<Post>(dateProvider: { () -> Date in
                   return injectedDate
        }, storeName: storageName, expiryDate: .minutes(interval: -3))
    }
    
    private func initStorageWith(expiry: SorageDateDescriptor) throws -> DiskStorage<Post> {
        return try DiskStorage(storeName: storageName, expiryDate: expiry)
    }
}


