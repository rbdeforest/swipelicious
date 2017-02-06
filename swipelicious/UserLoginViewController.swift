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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.layer.borderColor = UIColor.white.cgColor
        self.loginButton.layer.borderWidth = 0.5
        self.loginButton.layer.cornerRadius = 5
        
        let defaults = UserDefaults.standard
        self.emailTextField.text = defaults.object(forKey: Constants.Preferences.User.Email) as? String
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserLoginViewController.didRegister(_:)), name: NSNotification.Name(rawValue: Constants.Notifications.UserDidRegister), object: nil)
    }
    
    func didRegister(_ notification : Notification){
        let alert = UIAlertController.init(title: "Success!", message: "You are now registered, please login to continue.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        let defaults = UserDefaults.standard
        self.emailTextField.text = defaults.object(forKey: Constants.Preferences.User.Email) as? String
    }

    @IBAction func loginHandler(_ sender:UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            
            if email.isEmpty || password.isEmpty{
                let alert = UIAlertController.init(title: "Error", message: "Please complete all fields", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }else{
                let user = User.init(email: email, password: password)
                
                AppSession.sharedInstance.login(user) { (user, error) -> () in
                    if user != nil{
                        self.dismiss(animated: true, completion: { 
                            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.UserDidDismissLogin), object: nil)
                        })
                    }else{
                        let alert = UIAlertController.init(title: "Error", message: "Please verify email and password", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func back(_ sender : AnyObject){
        self.dismiss(animated: true, completion: nil)
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
