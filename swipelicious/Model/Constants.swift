//
//  Constants.swift
//  Sorteos
//
//  Created by Augusto Guido on 10/13/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Notifications {
        static let UserDidLogin = "kUserDidLogin"
        static let UserDidRegister = "kUserDidRegister"
        static let UserDidLogout = "kUserDidLogout"
        static let UserDidDismissLogin = "kUserDidDismissLogin"
        static let DidChangeConfigOption = "kDidChangeConfigOption"
        static let DidReceiveLocalNotification = "kDidReceiveLocalNotification"
    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct Preferences {
        struct User {
            static let Password = "UserPassword"
            static let Email = "UserEmail"
            static let FBId = "userfacebookid"
        }
    }
    
    struct API {
        
        static let test = 1
        
        //static let Base = "http://192.168.1.41/~augusto/Swipelicious/"
        static let Base = "http://sousrecipes.com/api/"
        
        struct User {
            static let Login = Constants.API.Base + "users/login.json?test=\(test)"
            static let Register = Constants.API.Base + "users/add.json?test=\(test)"
            static func Save(id : String!) -> String{
                return Base + "users/edit/\(id).json?test=\(test)"
            }
        }
        
        struct Draw {
            static func Share(id : String!) -> String{
                return Constants.API.Base + "draws/view/\(id)?test=\(test)"
            }
            static func View(id : String!) -> String{
                return Constants.API.Base + "draws/\(id).json?test=\(test)"
            }
            static let Index = Constants.API.Base + "queues.json?test=\(test)"
            
            static let Favorites = Base + "draws/favorites.json?test=\(test)"
            static let AddFavorite = Base + "draws/add_favorite.json?test=\(test)"
        }
        
        struct Recipe {
            static func Index(country : String!) -> String{
                return Constants.API.Base + "draws/index.json?test=\(test)"
            }
            
            static let Favorites = Base + "draws/favorites.json?test=\(test)"
            static let AddFavorite = Base + "draws/add_favorite.json?test=\(test)"
            static let RemoveFavorite = Base + "draws/remove_favorite.json?test=\(test)"
        }
        
        struct Category {
            static let Index = Base + "categories.json?test=\(test)"
        }
        
    }
    
}
