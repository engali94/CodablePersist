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

/// Describes various storage errors.
enum StorageError: Swift.Error {

    /// The specified path could not be found
    case pathNotFound
    
    /// Obectt can't be stored or encodded.
    case objectUnreadable
    
    /// Object can't be fetched or encodded.
    case objectUnwritable
    
    /// Can't encode object
    case objectEncodingFailed(underlying: Swift.Error)
    
    /// Can't decode object
    case objectDecodingFailed(underlying: Swift.Error)
}

extension StorageError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .pathNotFound:
            return "The object couldn't be found at the specified path."
        case .objectUnwritable:
            return "Obectt can't be stored or encodded."
        case .objectUnreadable:
            return "Object can't be fetched or encodded."
        case .objectEncodingFailed(let error):
            return "Can't encode object due to \(error.localizedDescription)"
        case .objectDecodingFailed(let error):
            return "Can't decode object due to \(error.localizedDescription)"
        }
    }
}
