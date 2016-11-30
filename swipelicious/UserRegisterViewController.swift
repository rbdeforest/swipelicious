//
//  UserRegisterViewController.swift
//  Sorteos
//
//  Created by Augusto Guido on 10/14/15.
//  Copyright © 2015 Looping. All rights reserved.
//

import UIKit

class UserRegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var currentTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var datePicker: UIDatePicker! = UIDatePicker()
    var countryPicker: UIPickerView! = UIPickerView()
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications()
        
        self.loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.loginButton.layer.borderWidth = 0.5
        self.loginButton.layer.cornerRadius = 5
        
        
        self.datePicker.datePickerMode = UIDatePickerMode.Date
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserRegisterViewController.didDismissLogin), name: "kUserDidDismissLogin", object: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDismissLogin(){
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func registerHandler(sender:UIButton) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if  let email = emailTextField.text,
            let password = passwordTextField.text,
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text
        {
            
            if !(email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty ){
                let user = User.init(email: email, password: password, firstName: firstName, lastName: lastName)
                
                if (!self.isValidEmail(email)){
                    let alert = UIAlertController.init(title: "Error", message: "Email is incorrect", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    return
                }
                
                AppSession.sharedInstance.register(user) { (user, error) -> () in
                    if user != nil{
                        self.performSegueWithIdentifier("login", sender: self)                        
//                        self.dismissViewControllerAnimated(true, completion: { 
//                            //user did register notification
//                            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.UserDidRegister, object: nil)
//                        })
                    }else{
                        let alert = UIAlertController.init(title: "Error", message: "An error has ocurred", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }else{
                let alert = UIAlertController.init(title: "Error", message: "Please complete all fields to register", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    lazy var inputToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .Default
        toolbar.translucent = true
        toolbar.sizeToFit()
        
        var doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(UserRegisterViewController.inputToolbarDonePressed))
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        
        var nextButton  = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(UserRegisterViewController.keyboardNextButton))
        nextButton.width = 50.0
        //var previousButton  = UIBarButtonItem(title: "Prev", style: .Plain, target: self, action: "keyboardPrevButton")
        
        toolbar.setItems([fixedSpaceButton, nextButton, fixedSpaceButton, flexibleSpaceButton, doneButton, fixedSpaceButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        return toolbar
    }()

    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.inputAccessoryView = inputToolbar
        self.currentTextField = textField
        
        return true
    }
    
    func inputToolbarDonePressed(){
        self.currentTextField?.resignFirstResponder()
    }
    
    func keyboardNextButton(){
        if let view = self.view.viewWithTag(self.currentTextField.tag + 1){
            view.becomeFirstResponder()
        }else{
            self.currentTextField.resignFirstResponder()
        }
    }
    
    func keyboardPrevButton(){
        if let view = self.view.viewWithTag(self.currentTextField.tag - 1){
            view.becomeFirstResponder()
        }else{
            self.currentTextField.resignFirstResponder()
        }
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserRegisterViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserRegisterViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = self.currentTextField
        {
            if (!CGRectContainsPoint(aRect, activeFieldPresent.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.keyboardNextButton()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        self.currentTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        self.currentTextField = nil
    }
    
    @IBAction func back(sender : AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
