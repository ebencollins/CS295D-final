//
//  APIClient.swift
//  Conversation Analysis
//
//  Created by Eben Collins on 2020-3-30.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ConversationsAPIClient {
    static let BASE_URL = "https://ecolli11.w3.uvm.edu/cs295d/api"
    
    private static let DEVICE_UUID_KEY = "DEVICE_UUID"
    
    static func getAbsoluteURL(endpoint: String) -> String {
        return "\(BASE_URL)/\(endpoint)/"
    }
    
    // this function will register the device if it has not yet been registered
    static func registerDevice(completion: @escaping (_ result: Bool) -> ()){
        // don't re-register
        if let uuid = ConversationsAPIClient.getDeviceUUID() {
            return;
        }
        
        print("Attempting to register device...")
        let uuid = UUID().uuidString
        AF.request(getAbsoluteURL(endpoint: "devices"), method: .post, parameters: ["uuid": uuid])
            .responseJSON { response in
                switch (response.result){
                case .success:
                    // save if successful
                    let defaults = UserDefaults.standard
                    defaults.set(uuid, forKey: DEVICE_UUID_KEY)
                    completion(true)
                    print("Device registered successfully: \(getDeviceUUID())")
                case .failure(let error):
                    completion(false)
                    print("Error registering device: \(error)")
                }
        }
    }
    
    static func upload(conversation: Conversation, completion: @escaping (_ result: Bool, _ message:String) -> ()){
        // cont try to reupload
        if conversation.uploaded {
            return;
        }
        
        let parameters:[String:String] = [
            "device": getDeviceUUID()!,
            "uuid": conversation.uuid!.uuidString,
            "date": conversation.date!.isoformat(),
            "duration": String(conversation.duration)
        ]
        AF.request(getAbsoluteURL(endpoint: "conversations"), method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch(response.result) {
                case .success:
                    uploadSegments(conversation: conversation, completion: {result in
                        if result {
                            completion(true, "All extracted segments have been successfully uploaded")
                            conversation.uploaded = true
                            let managedContext = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
                            try? managedContext.save()
                        } else {
                            completion(false, "One or more segments failed to upload")
                        }
                    });
                case .failure(let error):
                    completion(false, "An error occured while uploading this conversation")
                    print("Error uploading conversation: \(error)")
                }
        }
    }
    
    static func uploadSegments(conversation: Conversation, completion: @escaping (_ result: Bool)->()) {
        
        var result = true
        let group = DispatchGroup()
        for segment in conversation.segments as! Set<ConversationSegment> {
            group.enter()
            let parameters:[String:String] = [
                "uuid": segment.uuid!.uuidString,
                "conversation": conversation.uuid!.uuidString,
                "start_time": String(segment.start_time),
                "duration": String(segment.duration),
            ]
            AF.upload(multipartFormData:
                { multipartFormData in
                    multipartFormData.append(segment.image!, withName: "image")
                    multipartFormData.append((segment.uuid?.uuidString.data(using: String.Encoding.utf8, allowLossyConversion: false)!)!, withName :"uuid")
                    multipartFormData.append((segment.conversation?.uuid?.uuidString.data(using: String.Encoding.utf8, allowLossyConversion: false)!)!, withName :"conversation")
                    multipartFormData.append(("\(segment.start_time)".data(using: String.Encoding.utf8, allowLossyConversion: false)!), withName :"start_time")
                    multipartFormData.append(("\(segment.duration)".data(using: String.Encoding.utf8, allowLossyConversion: false)!), withName :"duration")
            }, to: ConversationsAPIClient.getAbsoluteURL(endpoint: "conversation-segments"))
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch(response.result) {
                    case .success:
                        break
                    case .failure(let error):
                        result = false
                        print("Error uploading conversation segment: \(error)")
                    }
                    group.leave()
            }
            group.notify(queue: .main) {
                completion(result)
            }
        }
    }
    
    static func getDeviceUUID() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: DEVICE_UUID_KEY);
    }
}
