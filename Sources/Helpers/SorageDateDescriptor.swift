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

/// Sorage Date Descriptor
///
/// Describes object's expiry date as well as a time snapshot used in fetching
/// objects based on a specific time interval
public enum SorageDateDescriptor {
    
    /// Fetch the  object stored  in the last `interval` seconds,
    /// or set the object to be expired after `interval` seconds.
    case seconds(interval: Double)
    
    /// Fetch the  object  stored in the last `interval` minutes,
    /// or set the object to be expired after `interval` minutes.
    case minutes(interval: Double)
    
    /// Fetch  the object  stored in the last `interval` houres,
    /// or set the object to be expired after `interval` houres.
    case houres(interval: Double)
    
    /// Fetch  the object  stored in the last `interval` days,
    /// or set the object to be expired after `interval` days.
    case days(interval: Double)
    
    /// Fetch  the object  stored in the last `interval` months,
    /// or set the object to be expired after `interval` months.
    case months(interval: Double)
    
    /// **Warning**: Don't use this case with object retival. Use it only to set object's expiry.
    case never
    
}

// MARK: - Helpers

extension SorageDateDescriptor {
    
    /// Converts time interval to `Date` object.
    /// The date will be in the past.
    var toDate: Date {
        switch self {
        case .seconds(let interval):
            return Date(timeIntervalSinceNow: -interval)
        
        case .minutes(let interval):
            return Date(timeIntervalSinceNow: -60 * interval)
        
        case .houres(let interval):
            return Date(timeIntervalSinceNow: -60 * 60 * interval)
        
        case .days(let interval):
            return Date(timeIntervalSinceNow: -60 * 60 * 24 * interval)
        
        case .months(let interval):
            return Date(timeIntervalSinceNow: -60 * 60 * 24 * 30 * interval)
            
        case .never:
            return Date()
        }
    }
    
    /// Converts time interval to `Date` object.
    /// The date will be in the future,
    var expireDate: Date {
        switch self {
        case .seconds(let interval):
            return Date().addingTimeInterval(interval)
            
        case .minutes(let interval):
            return Date().addingTimeInterval(60 * interval)
        
        case .houres(let interval):
            return Date().addingTimeInterval(60 * 60 * interval)
        
        case .days(let interval):
            return Date().addingTimeInterval(60 * 60 * 24 * interval)
        
        case .months(let interval):
            return Date().addingTimeInterval(60 * 60 * 24 * 30 * interval)
            
        case .never:
            return Date(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
        }
    }
}
