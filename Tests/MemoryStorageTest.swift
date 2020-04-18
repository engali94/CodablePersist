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

class MemoryStorageTest: XCTestCase {
    
    var storage: MemoryStorage<Post>!
    
    override func setUp() {
        super.setUp()
        storage  = MemoryStorage<Post>(expiryDate: .minutes(interval: 3))
    }
    
    override func tearDown() {
        
        try? storage.deleteAll()
        storage = nil
        super.tearDown()
    }
    
    func testInitStorage() {
        storage = MemoryStorage<Post>(expiryDate: .minutes(interval: 3))
        XCTAssertNotNil(storage)
    }
       
   
    func testSaveSingleObject() {
        storage.save(Post.singlePost)
        XCTAssertEqual(storage.objectsCount, 1)
        XCTAssertTrue(storage.contains(0))
    }
       
    func testSaveMultiObjects() {
        storage.save(Post.dummyPosts())
        XCTAssertEqual(10, storage.objectsCount)
        XCTAssertTrue(storage.contains(4))
        XCTAssertEqual([1,2,3],[ storage[1]?.id, storage[2]?.id, storage[3]?.id])
    }
       
    func testFetchSingleObject() {
        storage.save(Post.singlePost)
        XCTAssertNotNil(try storage.fetchObject(for: 0) )
        XCTAssertEqual(0, try storage.fetchObject(for: 0)?.id)
        XCTAssertEqual("Single post test", try storage.fetchObject(for: 0)?.title)
    }
    
       
    func testFetchMultiObjects() {
          
        storage.save(Post.dummyPosts())
        XCTAssertNotNil(try? storage.fetchObjects(for: [3,2]) )
        XCTAssertEqual("Swift Article3", try? storage.fetchObject(for: 3)?.title)
    }
    
    func testFetchAllObjects() {
        
        storage.save(Post.dummyPosts())
        XCTAssertEqual(10, try storage.fetchAllObjects()?.count)
        XCTAssertEqual(1, try storage.fetchAllObjects(descending: false)?[0].id)
    }
       
    func testObjectExpiry() {
        storage = initStorageWith(injectedDate: Date(), expiryDate: .seconds(interval: -10))
         
        storage.save(Post.dummyPosts())
        XCTAssertTrue(storage.isExpired(for: 1))
        XCTAssertEqual(0, try storage.fetchAllObjects()?.count)
    }
       
    func testFetchStoredInLast() {

        storage = initStorageWith(injectedDate: Date(timeIntervalSinceNow: -60 * 4))
        storage.save(Post.dummyPosts())
        
        XCTAssertEqual(10, try storage.fetchObjectsStored(inLast: .minutes(interval: 5)).count)
        XCTAssertEqual(0, try storage.fetchObjectsStored(before: .minutes(interval: 5)).count)
        XCTAssertNotNil(try storage.fetchObjectsStored(inLast: .minutes(interval: 5))[0])
    }
    
    func testfetchStoredBefore() {
        storage = initStorageWith(injectedDate: Date(timeIntervalSinceNow: -60 * 4))
        storage.save(Post.dummyPosts())
        
        XCTAssertEqual(0, try storage.fetchObjectsStored(inLast: .minutes(interval: 3)).count)
        XCTAssertEqual(10, try storage.fetchObjectsStored(before: .minutes(interval: 3)).count)
        XCTAssertNotNil(try storage.fetchObjectsStored(before: .minutes(interval: 3))[0])
    }
       
    func testSubscript() {
        storage.save(Post.dummyPosts())
        XCTAssertTrue(storage[1]?.id == 1 )
        XCTAssertFalse(storage[3]?.title == "Swift Article1")
        storage[1] = nil
        XCTAssertNil(storage[1])
    }
    
    func testDeleteSingleObject() {
        storage.save(Post.singlePost)
        
        XCTAssertEqual(1, storage.objectsCount)
        XCTAssertNoThrow(try storage.deleteObject(forKey: Post.singlePost.id))
        XCTAssertNil(storage[0])
    }
    
    func testDeleteMultiObjects() {
        storage.save(Post.dummyPosts())
        XCTAssertNoThrow(try storage.deleteObjects(forKeys: [1,2,3]))
        XCTAssertEqual(7, storage.objectsCount)
        XCTAssertNil(storage[3])
    }
    
    func testDeleteAllObjects() {
        storage.save(Post.dummyPosts())
        XCTAssertEqual(10, storage.objectsCount)
        XCTAssertNoThrow(try storage.deleteAll())
        XCTAssertEqual(0, storage.objectsCount)
    }
       
    func testStorageContains() {
    
        storage.save(Post.dummyPosts())
        XCTAssert(storage.contains(2))
        XCTAssertFalse(storage.contains(12))
    }
       
    func testDeleteExpired() {
        storage = initStorageWith(injectedDate: Date(timeIntervalSinceNow: -60 * 10), expiryDate: .minutes(interval: -4))
        storage.save(Post.dummyPosts())
        
        storage.deleteExpired()
        XCTAssertEqual(0, storage.objectsCount)
    }
    
    func testStorageCapacity() {
        storage = initStorageWith(injectedDate: Date(timeIntervalSinceNow: -60 * 4), maxObjectsCount: 5)
        storage.save(Post.dummyPosts())
        XCTAssertEqual(5, storage.objectsCount)
    }
    
    private func initStorageWith(injectedDate: Date,
                                 expiryDate: SorageDateDescriptor = .minutes(interval: 4),
                                 maxObjectsCount: Int = 10) -> MemoryStorage<Post>{
        
        return MemoryStorage<Post>(dateProvider: {return injectedDate},
                                   expiryDate: expiryDate,
                                   maxObjectsCount: maxObjectsCount)
    }
    
    
}

