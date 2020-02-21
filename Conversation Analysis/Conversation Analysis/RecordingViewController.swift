//
//  RecordingViewController.swift
//  Conversation Analysis
//
//  Created by devon on 2/18/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController {
    
    // run when a view is loaded for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RecordingViewController loaded (first time)")
    }
    
    // run everytime a view is loaded
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("RecordingViewController loaded")
    }
    
}
