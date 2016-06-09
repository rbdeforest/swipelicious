//
//  User.swift
//  Sorteos360
//
//  Created by Augusto Guido on 10/9/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import Foundation

@objc class User:NSObject {
    
    var id: String?
    var email: String?
    var password: String?
    var fbid: String?
    var FBToken: String?
    var favoriteIds: [String]?
    var favorites: [Draw]?
    var profile: Profile?
    
    init(data: NSDictionary ){
        id = data["id"] as? String
        email = data["email"] as? String
        password = data["password"] as? String
        fbid = data["fbid"] as? String
        favoriteIds = data["favorite_ids"] as? [String]
        
        let draws = data["favorites"] as? NSArray
        print(draws);
        
        favorites = [Draw]()
        favoriteIds = [String]()
        
        if let favoriteDraws = draws{
            for item in favoriteDraws{
                let draw = Draw.init(data: item as! NSDictionary)
                favorites?.append(draw)
                favoriteIds?.append(draw.id)
            }
        }
        
        
        FBToken = data["FBToken"] as? String
        if let profileData = data["profile"] as! NSDictionary?{
            profile = Profile.init(data: profileData)
        }
    }
    
    init(email: String, password: String){
        self.email = email
        self.password = password
    }
    
    init(email: String, password: String, firstName: String, lastName: String, birthday: String, country: String){
        self.email = email
        self.password = password
        
        self.profile = Profile.init(email: email, firstName: firstName, lastName: lastName, birthday: birthday, country: country)
    }

    init(FBToken: String){
        self.FBToken = FBToken
    }
    
    func toParams() -> [String : AnyObject] {
        var profileParams : [String : AnyObject] = [String : AnyObject]()
            //"email": self.profile?.email as! AnyObject,
            //"first_name": self.profile?.first_name as! AnyObject,
            //"last_name": self.profile?.last_name as! AnyObject]
        
        if let i = self.profile?.id{
            profileParams["id"] = i
        }
        
        if let i = self.profile?.first_name{
            profileParams["first_name"] = i
        }
        
        if let i = self.profile?.last_name{
            profileParams["last_name"] = i
        }
        
        if let i = self.profile?.notifications{
            profileParams["notifications"] = i
        }
        
        if let i = self.profile?.country_code{
            profileParams["country_code"] = i
        }
        
        if let i = self.profile?.birthday{
            profileParams["birthday"] = i
        }
        
        var params = [String: AnyObject]()
        
        params["profile"] = profileParams
        
        if let i = self.id{
            params["id"] = i
        }else{
            if let e = self.email as? AnyObject{
                params["email"] = e
            }
            if let e = self.password as? AnyObject{
                params["password"] = e
            }
        }
        
        return params
    }
    
    func isFavorite(draw : Draw) -> Bool {
        print(self.favoriteIds)
        if let fids = self.favoriteIds{
            return (fids.contains(draw.id))
        }
        return false
    }
    
    func addToFavorites(draw : Draw, like : Bool) {
        //if self.favoriteIds == nil{ return }
        
        let url : String = Constants.API.Draw.AddFavorite
        let request = AppSession.sharedInstance.requestForURL(.POST, url: url, parameters:["like" : like, "draw_id" : draw.id])
        
        request.responseJSON {
            response in
            if let error = response.result.error {
                print(error.localizedDescription)
                print(NSString.init(data: response.data!, encoding: NSUTF8StringEncoding))
            }else{
                if like && !self.isFavorite(draw){
                    self.favoriteIds?.append(draw.id)
                    self.favorites?.append(draw)
                }
                if (!like && self.isFavorite(draw)){
                    self.favoriteIds?.removeAtIndex((self.favoriteIds?.indexOf(draw.id))!)
                    if (self.favorites!.contains(draw)){
                        self.favorites?.removeAtIndex((self.favorites?.indexOf(draw))!)
                    }
                    
                }
            }
        }
    }
}