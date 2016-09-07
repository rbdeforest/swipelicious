//
//  Draw.swift
//  Sorteos360
//
//  Created by Augusto Guido on 10/8/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import Foundation

@objc class Draw : NSObject{
    var id: String
    var title: String
    var link: String?
    var result_link: String?
    var short_description: String?
    var large_description: String?
    var owner: String?
    var photo_url: String?
    var uploaded_photo: String?
    var small_uploaded_photo: String?
    var favorite_count: String?
    var review_count: String?
    var ingredient_count: String?
    var rating_average: String?
    var ingredients: [String]?
    var categories: [String]?
    var prep_time: String?
    var cook_time: String?
    var ready_time: String?
    var blog_url: String?
    var pos: String?
    
    init(data: NSDictionary ){
        
        let formatter = NSDateFormatter.init()
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        id = data["id"] as! String
        title = data["title"] as! String
        link = data["link"] as? String
        if let rl = data["results_link"] as? String{
            result_link = rl
        }else{
            result_link = link
        }
        
        short_description = data["short_description"] as? String
        large_description = data["description"] as? String
        owner = data["owner"] as? String
        photo_url = data["photo_url"] as? String
        small_uploaded_photo = data["small_photo_url"] as? String
        
        favorite_count = data["favorite_count"] as? String
        review_count = data["review_count"] as? String
        rating_average = data["rating_average"] as? String
        ingredient_count = data["ingredient_count"] as? String
        
        ingredients = data["ingredients"] as? [String]
        categories = data["categories"] as? [String]
        
        prep_time = data["prep_time"] as? String
        cook_time = data["cook_time"] as? String
        ready_time = data["ready_time"] as? String
        blog_url = data["blog_url"] as? String
    }
        
    func finished() -> Bool{
        return false
    }
    
    class func getURL() -> String{
        return Constants.API.Draw.Index
    }
}
