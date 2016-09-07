//
//  Draw.swift
//  Sorteos360
//
//  Created by Augusto Guido on 10/8/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import Foundation

@objc class Tag : NSObject{
    var id: String
    var title: String
    var pos: String?
    var color: String?
    
    init(data: NSDictionary ){
        id = data["id"] as! String
        title = data["title"] as! String
        pos = data["pos"] as? String
        color = data["color"] as? String
    }
    
    
    class func getURL() -> String{
        return Constants.API.Category.Index
    }
}
