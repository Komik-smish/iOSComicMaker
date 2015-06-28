//
//  RailsRequest.swift
//  ComicBookMaker
//
//  Created by Whitney Hogg on 6/27/15.
//  Copyright (c) 2015 Whitney Lauren. All rights reserved.
//

import UIKit

private let defaults = NSUserDefaults.standardUserDefaults()
private let _singleton = RailsRequest()

let API_URL = "http://salty-peak-7300.herokuapp.com"

class RailsRequest: NSObject {
    
    var singletonAccessoriesArray: [AnyObject] = []
    var singletonImagesArray: [AnyObject] = []
    
    class func session() -> RailsRequest { return _singleton }
    
    func getImageWithCompletion(completion: () -> Void) {
        
        var info = [
            
            "method" : "GET",
            "endpoint" : "/assets"
        ] as [String:AnyObject]
        
    }
    
    var token: String? {
        
        get {
            
            return defaults.objectForKey("TOKEN") as? String
            
        }
        
        set {
            
            defaults.setValue(newValue, forKey: "TOKEN")
            defaults.synchronize()
            
        }
    }
    //start repeated stuff
    
//    var username: String?
//    var email: String?
//    var password: String?
//    var fullname: String?
//    
//    
//    func registerWithCompletion(completion: () -> Void) {
//        
//        var info = [
//            
//            "method" : "POST",
//            "endpoint" : "/users/signup",
//            "parameters" : [
//                
//                "username" : username!,
//                "email" : email!,
//                "password" : password!,
//                "full_name" : fullname!
//                
//            ]
//            
//            ] as [String:AnyObject]
//        
//
//        requestWithInfo(info, andCompletion: { (responseInfo) -> Void in
//            
//            println(responseInfo)
//            
//            if let accessToken = responseInfo?["access_token"] as? String {
//                
//                self.token = accessToken
//                
//                completion()
//                //end repeated stuff
//                
//            }
//            
//        })
//        
//        completion()
//        
//    }
//    
//    func loginWithCompletion(completion: () -> Void) {
//        
//        
//        var info = [
//            
//            "method" : "POST",
//            "endpoint" : "/users/login",
//            "parameters" : [
//                
//                "username" : username!,
//                "password" : password!
//                
//            ]
//            ] as [String:AnyObject]
//        
//        requestWithInfo(info, andCompletion: { (responseInfo) -> Void in
//            
//            println(responseInfo)
//            
//            if let accessToken = responseInfo?["access_token"] as? String {
//                
//                self.token = accessToken
//                
//                completion()
//                
//            }
//            
//        })
//        
//        completion()
//        
//    }
    
    var imageURL = ""
    
    func postImageWithCompletion(completion: () -> Void) {
        
        var info = [
            
            "method" : "POST",
            "endpoint" : "/images",
            "parameters" : [
                


                    "image_url" : imageURL,
                    "ios" : 1
                
                
//                "accessories" [
//                
//                
//                    [
//                
//                        "x" : 400,
//                        "y" : 200,
//                        "w" : 100,
//                        "h" : 100,
//                        "id" : 3
//                    ]
//                
//                ]
                
            ]
            
            ] as [String:AnyObject]
        
        requestWithInfo(info, andCompletion: { (responseInfo) -> Void in
            
            println(responseInfo)
            
            completion()
            
            
        })
        
//        completion()
    }
    
    func getAccessories(completion: () -> Void) {
        
        var info = [
        
            "method" : "GET",
            "endpoint" : "/accessories",
            
       
            ] as [String:AnyObject]
        
        requestWithInfo(info, andCompletion: { (responseInfo) -> Void in
            
            println("Rails Request getAccessories 1 \(responseInfo)")
            
            completion()
            
            if let insideResponseInfo = responseInfo as? [AnyObject] {
                
                self.singletonAccessoriesArray = insideResponseInfo
                
                println("Rails Request getAccessories 2: \(self.singletonAccessoriesArray)")
                
                completion()
            }
            
        })
        
        completion()
    }
    
    func getImages(completion: () -> Void) {
        
        var info = [
            
            "method" : "GET",
            "endpoint" : "/images/edits",
            
            
            
            ] as [String:AnyObject]
        
        requestWithInfo(info, andCompletion: { (responseInfo) -> Void in
            
            println("Rails Request getImages 1 \(responseInfo)")
            
            completion()
            
            if let insideResponseInfo = responseInfo as? [AnyObject] {
                
                self.singletonImagesArray = insideResponseInfo
                
                println("Rails Request getAccessories 2: \(self.singletonImagesArray)")
                
                completion()
            }
            
        })
        
        completion()
    }

    


    func requestWithInfo(info: [String:AnyObject], andCompletion completion: ((responseInfo: AnyObject?) -> Void)?) {
        
        let endpoint = info["endpoint"] as! String
        
        if let url = NSURL(string: API_URL + endpoint) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = info["method"] as! String
            
            if let token = token {
                
                request.setValue(token, forHTTPHeaderField: "access_token")
            }
            
            ///BODY
            
            if let bodyInfo = info["parameters"] as? [String:AnyObject] {
                
                let requestData = NSJSONSerialization.dataWithJSONObject(bodyInfo, options: NSJSONWritingOptions.allZeros, error: nil)
                
                let jsonString = NSString(data: requestData!, encoding: NSUTF8StringEncoding)
                
                let postLength = "\(jsonString!.length)"
                
                request.setValue(postLength, forHTTPHeaderField: "Content-Length")
                
                let postData = jsonString?.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.HTTPBody = postData
                
            }
            
            ///BODY
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                
                
                if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) {
                    
                    println(json)
                    
                    completion?(responseInfo: json)
                    
                }
                
            })
            
        }
        
    }
    
}




