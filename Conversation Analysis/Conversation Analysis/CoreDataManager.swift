//
//  CoreDataManager.swift
//  Conversation Analysis
//
//  Created by Josh Bongard on 4/9/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import Foundation
import Foundation
import CoreData
import UIKit

class CoreDataManager {
//    static let sharedManager = CoreDataManager()

//    lazy var fetchedResultsController: NSFetchedResultsController<ConversationSegment> = {
//        // Initialize Fetch Request
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
//
//
//        let fetchRequest = NSFetchRequest<ConversationSegment>(entityName: "ConversationSegment")
//
//        // Add Sort Descriptors
//        let sortDescriptor = NSSortDescriptor(key: "uuid", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        // Initialize Fetched Results Controller
//        let fetchedResultsController = NSFetchedResultsController<ConversationSegment>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        // Configure Fetched Results Controller
//    //    fetchedResultsController.delegate = self
//
//        return fetchedResultsController
//      }()
  
  //1
  static let sharedManager = CoreDataManager()
  private init() {} // Prevent clients from creating another instance.
  
//  //2
//  lazy var persistentContainer: NSPersistentContainer = {
//
//    let container = NSPersistentContainer(name: "ConversationSegment")
//
//
//    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//
//      if let error = error as NSError? {
//        fatalError("Unresolved error \(error), \(error.userInfo)")
//      }
//    })
//    return container
//  }()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  //3
  func saveContext () {
    let context = appDelegate.persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func update(uuid: UUID?, start_time: Int32,image: URL?, conversationSegment: ConversationSegment?) {
    
    let context = appDelegate.persistentContainer.viewContext
    
    do {
      

      do {
        try context.save()
        print("saved!")
      } catch let error as NSError  {
        print("Could not save \(error), \(error.userInfo)")
      } catch {
        
      }
      
    } catch {
      print("Error with request: \(error)")
    }
  }
  
  /*delete*/
  func delete(conversationSegment : ConversationSegment){
    
    let managedContext = appDelegate.persistentContainer.viewContext
    do {
      
      managedContext.delete(conversationSegment)
      
    } catch {
      // Do something in response to error condition
      print(error)
    }
    
    do {
      try managedContext.save()
    } catch {
      // Do something in response to error condition
    }
  }
  
  func fetchAllPersons() -> [ConversationSegment]?{
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ConversationSegment")
    
    /*You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.*/
    do {
      let people = try managedContext.fetch(fetchRequest)
      return people as? [ConversationSegment]
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
      return nil
    }
  }
  
  
  
  /*In cases we need to flush data, we can call this method*/
  func flushData() {
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
    let objs = try! appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
    for case let obj as NSManagedObject in objs {
        appDelegate.persistentContainer.viewContext.delete(obj)
    }
    
    try!
        appDelegate.persistentContainer.viewContext.save()
  }
}

