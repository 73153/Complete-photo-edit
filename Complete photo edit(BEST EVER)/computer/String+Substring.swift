//
//  String+Substring.swift
//  fast-news-ios
//
//  Created by Nate Parrott on 3/5/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import Foundation

extension String {
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let rangeStartIndex = characters.index(startIndex, offsetBy: r.lowerBound)
            let rangeEndIndex = characters.index(rangeStartIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[(rangeStartIndex ..< rangeEndIndex)]
        }
    }
}
