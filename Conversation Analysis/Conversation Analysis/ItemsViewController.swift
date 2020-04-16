//
//  ListViewController.swift
//  Conversation Analysis
//
//  Created by devon on 2/18/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftPlot
import AGGRenderer
import CoreData


class ItemsViewController: UIViewController, NSFetchedResultsControllerDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemStore: ItemStore!
    var segments:[(duration: Int, start:Int, imageData:Data)] = []
    var conversations: [NSManagedObjectModel]=[]
    
    @IBOutlet var tableView:UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Conversation> = {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Conversation>(entityName: "Conversation")
        // Configure the request's entity, and optionally its predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        tableView.rowHeight = UITableView.automaticDimension
        //tableView.estimatedRowHeight = 160
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 160.0
        NSObject.self.load()
        print("ListViewController loaded its view")
        
    }
    
    // MARK: - View Methods
    
    func setupView() {
        updateView()
    }
    
    func updateView() {
        // fetch conversations
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        var hasConversations = false
        
        if let conversations = fetchedResultsController.fetchedObjects {
            hasConversations = conversations.count > 0
        }
        
        tableView.isHidden = !hasConversations
        
        self.tableView.reloadData()
        //activityIndicatorView.stopAnimating()
    }
    
}

extension ItemsViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let conversations = fetchedResultsController.fetchedObjects else { return 0 }
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Graph Cell",for: indexPath) as! GraphCell
        
        // Fetch Quote
        let conversation = fetchedResultsController.object(at: indexPath)
        cell.duration.text = "Duration: \(conversation.duration)"
        cell.graphName.text = "\(conversation.hashValue)"
        let segments = conversation.getSegments()
        if let segment = segments.first {
            // Configure Cell
            DispatchQueue.global().async{
                print(segment.image)
                if let data = try? Data(contentsOf: segment.image){
                    print("Data")
                    if let image = UIImage(data: data){
                        print("image")
                        DispatchQueue.main.async{
                            cell.ImageView.image = image
                        }
                    }
                }
            }
        }
        
        
        return cell
    // EJ: - Segueway to the graph detailed view @indexPath Cell
        
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // If the triggered segue is the "showItem" segue
           switch segue.identifier {

               case "Detail Graph"?:

               // Figure out which row was just tapped
               if let indexPath = tableView.indexPathForSelectedRow?.row {

                   // Get the item associated with this row and pass it along
                let conversation = fetchedResultsController.object(at: IndexPath(row:indexPath, section:0))
                let dgv = segue.destination as! DetailGraphView

                dgv.conversation = conversation
               }
               default:
                   preconditionFailure("Unexpected segue identifier.")
               }
       }
       
    
}



extension UIImageView{
     func load(url: URL){
        DispatchQueue.global().async{ [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async{
                        self?.image = image
                    }
                }
            }
        }
        
    }
    
}

class GraphCell:UITableViewCell{
    //properties
    static let reuseIdentifier = "GraphCell"
    
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var graphName: UILabel!
    @IBOutlet var duration: UILabel!
    
    
    override func awakeFromNib(){
        super.awakeFromNib()
    }
}
