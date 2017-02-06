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
    
    init?(data: NSDictionary ){
        id = data["id"] as? String
        if id == nil {
            return nil
        }
        email = data["email"] as? String
        password = data["password"] as? String
        fbid = data["fbid"] as? String
        favoriteIds = data["favorite_ids"] as? [String]
        
        let draws = data["favorites"] as? NSArray
        print("\(draws)");
        
        favorites = [Draw]()
        favoriteIds = [String]()
        
        var i : Int = 0
        if let favoriteDraws = draws{
            for item in favoriteDraws{
                let draw = Draw.init(data: item as! NSDictionary)
                draw.pos = String(i)
                i += 1
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
    
    init(email: String, password: String, firstName: String, lastName: String){
        self.email = email
        self.password = password
        
        self.profile = Profile.init(email: email, firstName: firstName, lastName: lastName)
    }

    init(FBToken: String){
        self.FBToken = FBToken
    }
    
    func toParams() -> [String : Any] {
        var profileParams : [String : Any] = [String : Any]()
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
        
        var params = [String: Any]()
        
        params["profile"] = profileParams
        
        if let i = self.id{
            params["id"] = i
        }else{
            if let e = self.email{
                params["email"] = e
            }
            if let e = self.password{
                params["password"] = e
            }
        }
        
        return params
    }
    
    func isFavorite(_ draw : Draw) -> Bool {
        print("\(self.favoriteIds)")
        if let fids = self.favoriteIds{
            return (fids.contains(draw.id))
        }
        return false
    }
    
    func addToFavorites(_ draw : Draw, like : Bool) {
        
        guard let _ = self.favoriteIds, let _ = self.favorites else{
            return
        }
        
        let url = Constants.API.Draw.AddFavorite
        let request = AppSession.sharedInstance.requestForURL(.post, url: url, parameters:["like" : like, "draw_id" : draw.id])
        
        request.responseJSON {
            response in
            if let error = response.result.error, let errorString = String(data: response.data!, encoding: .utf8) {
                print(error.localizedDescription)
                print("\(errorString)")
            }else{
                if like && !self.isFavorite(draw){
                    if self.favorites!.count > 0{
                        if let pos = self.favorites?.first?.pos{
                            draw.pos = String(Int(pos)! - 1)
                        }
                    }
                    
                    self.favoriteIds?.insert(draw.id, at: 0)
                    self.favorites?.insert(draw, at: 0)
                    
                }
                if (!like && self.isFavorite(draw)){
                    self.favoriteIds?.remove(at: (self.favoriteIds?.index(of: draw.id))!)
                    if (self.favorites!.contains(draw)){
                        self.favorites?.remove(at: (self.favorites?.index(of: draw))!)
                    }
                    
                }
            }
        }
    }
}
