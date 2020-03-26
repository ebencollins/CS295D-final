//
//  DetailViewController.swift
//  Conversation Analysis
//
//  Created by devon on 2/20/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var conversation: Conversation!

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var timeInterval: UILabel!
    @IBOutlet var id: UILabel!
    
    // run when a view is loaded for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print to console to alert that view has been loaded
        print("DetailViewController loaded its view with conversation \(conversation.uuid)")
        
        // set imageView to image
        
        //set interval (using duration for now)
        timeInterval.text = "\(conversation.duration) "
        
        // set id to uuid
        if let uuid = conversation.uuid {
            id.text = "\(uuid)"
        }
    }
    
    // run everytime a view is loaded
    override func viewDidAppear(_ animated: Bool) {
        print("DetailViewController loaded")
    }
}
