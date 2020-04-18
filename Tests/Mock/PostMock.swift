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

@testable import CodablePersist
import Foundation

struct Post: Identifiable, Codable {
    static var idKey = \Post.id
    var title: String
    var id: Int
    
    static func dummyPosts() -> [Post] {
        var reqs: [Post] = []
        for i in 1...10 {
            let re = Post(title: "Swift Article\(i)", id: i)
            reqs.append(re)
        }
        return reqs
       
    }
    
    static func dummyPosts2() -> [Post] {
           var reqs: [Post] = []
           for i in 1...10 {
               let re = Post(title: "Swift Article1\(i)", id: 10 + i)
               reqs.append(re)
           }
           return reqs
          
       }
    
    static let singlePost = Post(title: "Single post test", id: 0)
}
