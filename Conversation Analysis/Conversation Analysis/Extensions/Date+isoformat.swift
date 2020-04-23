//
//  Date+isoformat.swift
//  Conversation Analysis
//
//  Created by Eben Collins on 2020-4-2.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import Foundation

extension Date {
    
    func isoformat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter.string(from: self)
    }
    
    func format(_ format:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
