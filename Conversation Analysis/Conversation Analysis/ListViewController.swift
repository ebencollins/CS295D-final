//
//  ListViewController.swift
//  Conversation Analysis
//
//  Created by devon on 2/18/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit

class ItemsViewController: UITableViewController {
    var itemStore: ItemStore!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int{
        return itemStore.allItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //get a new or recyced cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell",for: indexPath)
        
        //set the test on the cell with the description of the item
        //that is at the nth index of items, where n = row this cell
        //will appear in on the tableview
        let item = itemStore.allItems[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.dateCreated)"
        
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // print to console to alert whether it's view has been loaded
        print("ListViewController loaded its view")
    }
//
//}
//class Item: NSObject{
//    var image: String?// Graph
//    var timeStamp: String?//TimeStamp
}

    
}
