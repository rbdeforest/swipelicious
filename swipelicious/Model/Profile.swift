//
//  Profile.swift
//  Sorteos360
//
//  Created by Augusto Guido on 10/9/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import Foundation

@objc class Profile : NSObject {
    
    var id : String?
    var user_id : String?
    var email : String?
    var first_name : String?
    var last_name : String?
    var photo : String?
    var timezone : String?
    var gender : String?
    var locale : String?
    var link : String?
    var country_id : Int?
    var country_code : String?
    var birthday : String?
    var notifications : String?
    
    init(data: NSDictionary ){
        id = data["id"] as? String
        email = data["email"] as? String
        first_name = data["first_name"] as? String
        last_name = data["last_name"] as? String
        birthday = data["birthday"] as? String
        
        if let c = data["country_code"] as? String{
            country_code = c
        }
        if let c = data["notifications"] as? String{
            notifications = c
        }
    }
    
    init(email: String, firstName: String, lastName: String, birthday: String, country: String){
        self.email = email
        self.first_name = firstName
        self.last_name = lastName
        self.birthday = birthday
        self.country_code = country
    }
    
    func setConfigOption(option: String, value: String){
        AppSession.sharedInstance.saveUser()
    }
    
}

