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

//class ItemsViewController: UITableViewController {
//    var itemStore: ItemStore!
//    var conversation: Conversation!
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int{
//        return itemStore.allItems.count
//    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        //get a new or recyced cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Graph Cell",for: indexPath) as! GraphCell
//        let item = itemStore.allItems[indexPath.row]
//        cell.name?.text = item.name
//        cell.timeStamp?.text = item.dateCreated
////        cell.textLabel?.text = item.name
////        cell.textLabel?.text =
////
//        return cell
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // If the triggered segue is the "showItem" segue
//        switch segue.identifier {
//
//            case "Detail Graph"?:
//
//            // Figure out which row was just tapped
//            if let row = tableView.indexPathForSelectedRow?.row {
//
//                // Get the item associated with this row and pass it along
//                let item = itemStore.allItems[row]
//                let dgv = segue.destination as! DetailGraphView
//
//                dgv.item = item
//            }
//            default:
//                preconditionFailure("Unexpected segue identifier.")
//            }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // print to console to alert whether it's view has been loaded
////        tableView.rowHeight = UITableView.automaticDimension
////        tableView.estimatedRowHeight = 160
//        self.tableView.rowHeight = 160.0
//        print("ListViewController loaded its view")
//    }
//
//}
// class GraphTableViewCell: UITableViewCell{
//    @IBOutlet var name: UILabel!
//    @IBOutlet var timeStamp: UILabel!
//
//
//}
//
//


class ItemsViewController: UIViewController, NSFetchedResultsControllerDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemStore: ItemStore!
    var segments:[(duration: Int, start:Int, imageData:Data)] = []
    
    @IBOutlet var graph:UILabel!
    @IBOutlet var tableView:UITableView!


    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    public enum NSFetchedResultsChangeType : UInt {
    
        case insert
        
        case delete
        
        case move
        
        case update
    }
    


     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        
         switch (type) {
                case .insert:
                  if let indexPath = newIndexPath {
                    tableView.insertRows(at: [indexPath], with: .fade)
                  }
                  break;
                case .delete:
                  if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                  }
                  break;
                case .update:
                  if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                    configureCell(cell, at: indexPath)
                  }
                  break;
                  
                case .move:
                  if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                  }
                  
                  if let newIndexPath = newIndexPath {
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                  }
                  break;
//         @unknown default:
//            fatalError("Fatal Error")
//        }
        }}
      func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /*finally balance beginUpdates with endupdates*/
        tableView.endUpdates()
      }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
            //tableView.estimatedRowHeight = 160
        self.tableView.rowHeight = 160.0
        print("ListViewController loaded its view")
          
        }
    }
//    var conversations = [ConversationSegment](){
//        didSet{
//            updateView()
//
//        }
//    }
//
//    private func updateView(){
//        var hasConversations = false
//
//        if let hasConversations = fetchedResultsController.fetchedObjects{
//            hasConversations = conversations.count > 0
//        }
//
//        tableView.isHidden = !hasConversations
//        messageLabel.isHidden = hasConversations
//    }
//    private func setupView(){
//        setUpMessageLabel()
//        updateView()
//
//    }
//
//    private func setUpMessageLabel(){
//        messageLabel.text = "You dont have any conversation segments analyzed yet"
//    }
//
//

//    }
//

extension ItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = CoreDataManager.sharedManager.fetchedResultsController.sections else {
        return 0}
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Graph Cell",for: indexPath) as! GraphCell

        configureCell(cell,at: indexPath)
    
        return cell
        
    }
    
    func configureCell(_ cell: UITableViewCell,at indexPath: IndexPath){
        let conversationSegment = CoreDataManager.sharedManager.fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Graph Cell",for: indexPath) as! GraphCell
        // Configure Cell
        
        DispatchQueue.global().async{
            if let data = try? Data(contentsOf: conversationSegment.image!){
            if let image = UIImage(data: data){
                DispatchQueue.main.async{
                    cell.ImageView.image = image
                }
            }
            }
        }
        
        
        
        //cell.ImageView = conversationSegment.image)
        cell.duration.text = "\(conversationSegment.duration)"
        
    }
    
    
    func fetchAllPersons(){
      /*This class is delegate of fetchedResultsController protocol methods*/
      CoreDataManager.sharedManager.fetchedResultsController.delegate = self
      do{
        
        /*initiate performFetch() call on fetchedResultsController*/
        try CoreDataManager.sharedManager.fetchedResultsController.performFetch()
        
      }catch{
        print(error)
      }
     
      }
    }
    func update(uuid: UUID?, start_time: Int32,image: URL?, conversationSegment: ConversationSegment) {
        CoreDataManager.sharedManager.update(uuid: uuid, start_time: start_time,image: image ,conversationSegment: conversationSegment)
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
