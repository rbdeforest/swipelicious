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
    
    func login(_ user:User, completion:@escaping (_ : User?, _: Error?) -> ()) -> (){
        
        let url : String = Constants.API.User.Login
        
        self.user = user
        
        let request = self.requestForURL(.post, url: url)
        
        print(request)
        
        request.responseJSON {
            response in
            
            if let error = response.result.error {
                let errorString = String(data: response.data!, encoding: .utf8)

                print(errorString ?? "nil error")
                self.user = nil
                completion(nil, error)
            }else{

                if let JSON = response.result.value {
                    let userData = JSON as! NSDictionary
                    if let user = User.init(data: userData){
                        user.FBToken = self.user?.FBToken
                        user.email = self.user?.email
                        user.password = self.user?.password
                        
                        self.saveToPreferences(user)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.UserDidLogin), object: user)
                        
                        self.user = user
                        
                        completion(user, nil)
                    }else{
                        completion(nil, NSError(domain: "", code: 10, userInfo: [:]))
                    }
                    
                    
                }
            }
        }
    }
    
    func loginCurrentUser(_ completion:@escaping (_: User?, _: Error?) ->()) -> (){
        if user?.FBToken != nil
        {
            AppSession.sharedInstance.login(user!) { (user, error) -> () in
                completion(user, error)
                
            }
        }else{
            let defaults = UserDefaults.standard
            if  let email = defaults.object(forKey: Constants.Preferences.User.Email) as? String,
                let password = defaults.object(forKey: Constants.Preferences.User.Password) as? String
            {
                let user = User.init(email: email, password: password)
                
                AppSession.sharedInstance.login(user) { (user, error) -> () in
                    completion(user, error)
                }
            }else{
                completion(nil, nil)
            }
        }
    }
    
    func saveToPreferences(_ user: User){
        let defaults = UserDefaults.standard
        defaults.set(user.email, forKey: Constants.Preferences.User.Email)
        defaults.set(user.password, forKey: Constants.Preferences.User.Password)
        defaults.set(user.fbid, forKey: Constants.Preferences.User.FBId)
        defaults.synchronize()
    }
    
    func removeUserFromPreferences(){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.Preferences.User.Password)
        defaults.removeObject(forKey: Constants.Preferences.User.FBId)
        defaults.synchronize()
    }
    
    func logOut() {
        if (self.user != nil)
        {
            self.removeUserFromPreferences()
            self.user = nil
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.UserDidLogout), object: nil)
        }
    }
    
    func shouldLogin() -> Bool{
        return self.user == nil
    }
    
    func register(_ user:User, completion:@escaping (_ :User?, _: Error?) -> ()) -> (){
        
        let url : String = Constants.API.User.Register
        
        let request = Alamofire.request(url, method: .post, parameters: user.toParams())
        
        request.responseJSON {
            response in
            
            if let errorString = String(data: response.data!, encoding: .utf8){
                print(errorString)
            }
            
            if let error = response.result.error {
                completion(nil, error)
            }else{
                if let JSON = response.result.value {
                    let userData = JSON as! NSDictionary
                    if let user = User.init(data: userData){
                        self.saveToPreferences(user)
                        completion(user, nil)
                    }else{
                        completion(nil, nil)
                    }
                    
                    //self.login(user, completion: completion)
                }else{
                    completion(nil, nil)
                }
            }
        }
    }
    
    func requestForURL(_ method: HTTPMethod, url: String, parameters: [String: Any]? = nil) -> DataRequest{
        
        var url = url
        if self.user != nil, let token = self.user?.FBToken{
            let separator : String = url.contains("?") ? "&" : "?"
            url.append("\(separator)fbtoken=\(token)")
        }
        
        let request = Alamofire.request(url, method: method, parameters: parameters)
        
        if self.user != nil, let email = self.user?.email, let password = self.user?.password{
            request.authenticate(user: email, password: password)
        }

        return request
        
    }
    
    func saveUser() {
        
        let url : String = Constants.API.User.Save(self.user!.id)
        let request = AppSession.sharedInstance.requestForURL(.post, url: url, parameters:self.user!.toParams())
        
        request.responseJSON {
            response in
            if let error = response.result.error {
                print(error.localizedDescription)
                print(String(data: response.data!, encoding: .utf8) ?? "nil")
            }else{
                if let JSON = response.result.value {
                    print(JSON)
                    
                }
            }
        }
    }
    
}
