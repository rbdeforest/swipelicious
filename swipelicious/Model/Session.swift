//
//  Session.swift
//  Sorteos360
//
//  Created by Augusto Guido on 10/9/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import Foundation
import Alamofire

@objc class AppSession: NSObject{

    var user : User?
    
    static let sharedInstance = AppSession()
    
    override init() {
        
    }
    
    func login(user:User, completion:(user:User?, error: NSError?) -> ()) -> (){
        
        let url : String = Constants.API.User.Login
        
        self.user = user
        
        let request = self.requestForURL(.POST, url: url)
        
        print(request)
        
        request.responseJSON {
            response in
            
            if let error = response.result.error {
                let errorString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)
                print(errorString)
                self.user = nil
                completion(user: nil, error: error)
            }else{

                if let JSON = response.result.value {
                    let userData = JSON as! NSDictionary
                    let user = User.init(data: userData)
                    user.FBToken = self.user?.FBToken
                    user.email = self.user?.email
                    user.password = self.user?.password
                    
                    self.saveToPreferences(user)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.UserDidLogin, object: user)
                    
                    self.user = user
                    
                    completion(user: user, error: nil)
                }
            }
        }
    }
    
    func loginCurrentUser(completion:(user: User?, error: NSError?) ->()) -> (){
        if user?.FBToken != nil
        {
            AppSession.sharedInstance.login(user!) { (user, error) -> () in
                completion(user: user, error: error)
            }
        }else{
            let defaults = NSUserDefaults.standardUserDefaults()
            if  let email = defaults.objectForKey(Constants.Preferences.User.Email) as? String,
                let password = defaults.objectForKey(Constants.Preferences.User.Password) as? String
            {
                let user = User.init(email: email, password: password)
                
                AppSession.sharedInstance.login(user) { (user, error) -> () in
                    completion(user: user, error: error)
                }
            }else{
                completion(user: nil, error: nil)
            }
        }
    }
    
    func saveToPreferences(user: User){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(user.email, forKey: Constants.Preferences.User.Email)
        defaults.setObject(user.password, forKey: Constants.Preferences.User.Password)
        defaults.setObject(user.fbid, forKey: Constants.Preferences.User.FBId)
                
        defaults.synchronize()
    }
    
    func removeUserFromPreferences(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Constants.Preferences.User.Password)
        defaults.synchronize()
    }
    
    func logOut() {
        if (self.user != nil)
        {
            self.removeUserFromPreferences()
            //FBSDKLoginManager.init().logOut()
            self.user = nil
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.UserDidLogout, object: nil)
        }
    }
    
    func shouldLogin() -> Bool{
        return self.user == nil
    }
    
    func register(user:User, completion:(user:User?, error: NSError?) -> ()) -> (){
        
        let url : String = Constants.API.User.Register
        
        let request = Alamofire.request(.POST, url, parameters: user.toParams())
        
        request.responseJSON {
            response in
            
            if let error = response.result.error {
                completion(user: nil, error: error)
            }else{
                if let JSON = response.result.value {
                    let userData = JSON as! NSDictionary
                    let user = User.init(data: userData)
                    
                    self.login(user, completion: completion)
                }else{
                    completion(user: nil, error: nil)
                }
            }
        }
    }
    
    func requestForURL(method: Alamofire.Method, url: String, parameters: [String: AnyObject]? = nil) -> Request{
        
        var url = url
        if self.user != nil, let token = self.user?.FBToken{
            let separator : String = url.containsString("?") ? "&" : "?"
            url.appendContentsOf("\(separator)fbtoken=\(token)")
        }
        
        let request = Alamofire.request(method, url, parameters: parameters)
        
        if self.user != nil, let email = self.user?.email, let password = self.user?.password{
            request.authenticate(user: email, password: password)
        }

        return request
        
    }
    
    func saveUser() {
        
        let url : String = Constants.API.User.Save(self.user!.id)
        let request = AppSession.sharedInstance.requestForURL(.POST, url: url, parameters:self.user!.toParams())
        
        request.responseJSON {
            response in
            if let error = response.result.error {
                print(error.localizedDescription)
                print(NSString.init(data: response.data!, encoding: NSUTF8StringEncoding))
            }else{
                if let JSON = response.result.value {
                    print(JSON)
                    
                }
            }
        }
    }
    
}
