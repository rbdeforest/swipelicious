//
//  UserLoginViewController.swift
//  Sorteos
//
//  Created by Augusto Guido on 10/13/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

class UserLoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.loginButton.layer.borderWidth = 0.5
        self.loginButton.layer.cornerRadius = 5
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.emailTextField.text = defaults.objectForKey(Constants.Preferences.User.Email) as? String
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserLoginViewController.didRegister(_:)), name: Constants.Notifications.UserDidRegister, object: nil)
    }
    
    func didRegister(notification : NSNotification){
        let alert = UIAlertController.init(title: "Success!", message: "You are now registered, please login to continue.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.emailTextField.text = defaults.objectForKey(Constants.Preferences.User.Email) as? String
    }

    @IBAction func loginHandler(sender:UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            
            if email.isEmpty || password.isEmpty{
                let alert = UIAlertController.init(title: "Error", message: "Please complete all fields", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }else{
                let user = User.init(email: email, password: password)
                
                AppSession.sharedInstance.login(user) { (user, error) -> () in
                    if user != nil{
                        self.dismissViewControllerAnimated(true, completion: { 
                            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.UserDidDismissLogin, object: nil)
                        })
                    }else{
                        let alert = UIAlertController.init(title: "Error", message: "Please verify email and password", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func back(sender : AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
