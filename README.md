
<p align="center">

<img width="200" src="https://github.com/engali94/CodablePersist/blob/master/Assets/CodablePersistLogo.png" alt="CodablePersist Logo">

</p>

  

<p align="center">

<a href="https://developer.apple.com/swift/">

<img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">

</a>

<a href="http://cocoapods.org/pods/CodablePersist">

<img src="https://img.shields.io/cocoapods/v/CodablePersist.svg?style=flat" alt="Version">

</a>

<a href="http://cocoapods.org/pods/CodablePersist">

<img src="https://img.shields.io/cocoapods/p/CodablePersist.svg?style=flat" alt="Platform">

</a>

<a href="https://github.com/Carthage/Carthage">

<img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">

</a>

<a href="https://github.com/apple/swift-package-manager">

<img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">

</a>

</p>

  

# CodablePersist

  

<p align="center">

Store your awsome `Codable` objects and retreive them with ease. `CodablePersist` gives you a convenient way store your objects in disk, UserDefaluts and memory and manage them easly.

</p>

  

## Features

  

- ✅ Easily save and retrieve any `Codable` type.
- 📆 Set expiration date to the objects.
- 🔍Time-based storage filtring.
- 🗃Retrieve, delete, save objects using subscript

## Example

  

To quickly show you how `CodablePersist` can be useful, consider the following use case:

```swift
struct PostFetcher { 
    typealias Handler = (Result<Article, Error>) -> Void 
    private let cache = Cache<Article.ID, Article>()
    
    func fetchPost(withID id: Post.ID, then handler: @escaping  Handler) {
    // check if the post is cached or not
     if let cached = cache[id] { return  handler(.success(cached)) } 
     // if not cached fetch it from the backend
     performFetching { [weak self] result in 
     // load post and cache it
     let post = try? result.get() post.map { self?.cache[id] = $0 }
     //then return the result
      handler(result) 
      } 
    } 
}
```

## Installation

  

### <summary>CocoaPods</summary>

  

CodablePersist is available through [CocoaPods](http://cocoapods.org). To install

it, simply add the following line to your Podfile:

  

```bash

pod 'CodablePersist'

```

  

### Carthage

  

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

  

To integrate CodablePersist into your Xcode project using Carthage, specify it in your `Cartfile`:

  

```ogdl

github "engali94/CodablePersist"

```

  

Run `carthage update` to build the framework and drag the built `CodablePersist.framework` into your Xcode project.

  

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

  

### Swift Package Manager

  

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

  

```swift

dependencies: [

.package(url: "https://github.com/engali94/CodablePersist.git", from: "0.1")

]

```
Next, add `CodablePersist` to your targets as follows:
```swift
.target(
    name: "YOUR_TARGET_NAME",
    dependencies: [
        "CodablePersist",
    ]
),
```
Then run `swift package update` to install the package.


Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for `CodablePersist`.

  

### Manually

  

If you prefer not to use any of the aforementioned dependency managers, you can integrate CodablePersist into your project manually. Simply drag the `Sources` Folder into your Xcode project.

  

## Usage

  ### 1. Prepare your data  
  Make sure your type conforms to `Identifiable` protocol, and assign a unique `idKey` property like follows:
  ``` swift
  struct Post: Codable, Identifiable {
     // Identifiable conformance
     static var idKey = \Post.id
    
     var title: String
     var id: String // should be unique per post 
}
  ``` 


 ### 2. Initialize Storage

- `DiskStorage`:  We can init a Disk Storage by passing a `storeName` and  `expiryDate` 
    ``` swift
     let storage = try? DiskStorage<Post>(storeName: storageName, expiryDate: .minutes(interval: 10))
    ```
 
- `UserDefalutsStorage`:  Also we can init UserDefaults Storage by passing a `storeName` and  `expiryDate` 
  ``` swift
  let storage = UserDefaultsStorage<Post>(storeName: storageName, expiryDate: .minutes(interval: 10))! 
  ```
  
- `MemoryStorage`:  This should be used with precaution, if any memory load happens the system will delete some or all objects to free memory. **Consider using `DiskStorage` or   `UserDefalutsStorage` for long term persistence.** 
 we can init ``
    ```swift
     let storage = MemoryStorage<Post>(expiryDate: .minutes(interval: 10))
    ```
    ### 3. Storage!!
    Now you are good to go... You can persist, retrieve and delete your `Codable` objects 😎
    #### Saving
    ```swift
    let singlePost = Post(title: "I'm persistable", id: 1)
    let posts: [Post] = [Post(title: "I'm persistable2", id: 2), Post(title: "I'm persistable3", id: 3)]
    
    //Save a single object
    try? storage.save(singlePost)
    
    // Save single object by subscript
    storage[1] = singlePost
    
    //Save mutliple objects
    try? storage.save(posts)
    
    
    ```
    #### Retrieval 
    ```swift
    // fetch single object
    let post1 = try? storage.fetchObject(for: 1)
    
    // fetch by subscript
    let post2 = storage[2]
    
    // fetch multiple objects
    let multiPosts = try? storage.fetchObjects(for: [3,2])
    
    // fetch all objects in the store sorted by date ascendingly
    let allObjets = try? storage.fetchAllObjects(descending: false)
    
    // fetch only objects saved in las ten minutes 
    // ------(10)++++++(now) -> will only returns ++++++
    let obejetsAfterTenMin = try? storage.fetchObjectsStored(inLast: .minutes(interval: 10)
    
    // fetch object stored before the last 10 minutes
    // ++++++(10)------(now) -> will only returns ++++++
    let obejetsBeforeTemMin = try? storage.fetchObjectsStored(before: .minutes(interval: 10))
    
    // check if an object exists in the storage
    storage.contains(2)
    
    // check the number of objects in the storage
    storage.objectsCount
    
    ```
    #### Deletion
    ```swift
    // delete a single object
    try? storage.deleteObject(forKey: singlePost.id)
    
    // delete a single object by subscript
    storage[singlePost.id] = nil
    
    // delete multiple posts
    try? storage.deleteObjects(forKeys: [2,3])
    
    // delete all objects
    try? storage.deleteAll()
    
    // Delete expired objects
    storage.deleteExpired()
    ```
## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 10.0+
- Swift 4.2+

## Contributing

Contributions are warmly welcomed 🙌

  

## License

CodablePesist is released under the MIT license. See [LICENSE](https://github.com/engali94/CodablePersist/blob/master/LICENSE) for more information.  
