//
//  Sequence+transposed.swift
//  Conversation Analysis
//
//  Created by Eben Collins on 2020-3-18.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import Foundation

extension Sequence where
    Element: Collection,
    Element.Index == Int,
    Element.IndexDistance == Int
{
    public func transposed(prefixWithMaxLength max: Int = .max) -> [[Element.Element]] {
        var o: [[Element.Element]] = []
        let n = Swift.min(max, self.min{ $0.count < $1.count }?.count ?? 0)
        o.reserveCapacity(n)
        for i in 0 ..< n {
            o.append(map{ $0[i] })
        }
        return o
    }
}
