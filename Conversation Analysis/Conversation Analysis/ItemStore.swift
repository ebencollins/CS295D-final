//
//  ItemStore.swift
//  Conversation Analysis
//
//  Created by EJ on 2/24/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//
import UIKit

class ItemStore{
    var allItems = [Item]()
    @discardableResult func createItem() -> Item{
        let newItem = Item(random: true)
        allItems.append(newItem)
        
        return newItem
    }
    init(){
        for _ in 0..<5{
            createItem()
        }
    }
//    if let unwrappedList = list.contains {
//            let itemsOnListArray = unwrappedList.allObjects
//    }
    
    
    
    
}
