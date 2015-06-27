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

let API_URL = "http://shrouded-peak-4702.herokuapp.com/"

class RailsRequest: NSObject {
    
    class func session() -> RailsRequest { return _singleton }
    
    func getImageWithCompletion(completion: () -> Void) {
        
        var info = [
            
            "method" : "GET",
            "endpoint" : "/assets"
        ] as [String:AnyObject]
        
    }
}
