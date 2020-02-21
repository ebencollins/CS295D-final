//
//  ProcessingViewController.swift
//  Conversation Analysis
//
//  Created by devon on 2/21/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit

class ProcessingViewController: UIViewController {

    // run when a view is loaded for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ProcessingViewController loaded (first time)")
    }
    
    // run everytime a view is loaded
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("ProcessingViewController loaded")
    }

}
