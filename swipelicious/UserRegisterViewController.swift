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
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications()
        
        self.loginButton.layer.borderColor = UIColor.white.cgColor
        self.loginButton.layer.borderWidth = 0.5
        self.loginButton.layer.cornerRadius = 5
        
        
        self.datePicker.datePickerMode = UIDatePickerMode.date
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserRegisterViewController.didDismissLogin), name: NSNotification.Name(rawValue: "kUserDidDismissLogin"), object: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDismissLogin(){
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func registerHandler(_ sender:UIButton) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if  let email = emailTextField.text,
            let password = passwordTextField.text,
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text
        {
            
            if !(email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty ){
                let user = User.init(email: email, password: password, firstName: firstName, lastName: lastName)
                
                if (!self.isValidEmail(email)){
                    let alert = UIAlertController.init(title: "Error", message: "Email is incorrect", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                AppSession.sharedInstance.register(user) { (user, error) -> () in
                    if user != nil{
                        self.performSegue(withIdentifier: "login", sender: self)                        
//                        self.dismissViewControllerAnimated(true, completion: { 
//                            //user did register notification
//                            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.UserDidRegister, object: nil)
//                        })
                    }else{
                        let alert = UIAlertController.init(title: "Error", message: "An error has ocurred", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }else{
                let alert = UIAlertController.init(title: "Error", message: "Please complete all fields to register", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    lazy var inputToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        var doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(UserRegisterViewController.inputToolbarDonePressed))
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        var nextButton  = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(UserRegisterViewController.keyboardNextButton))
        nextButton.width = 50.0
        //var previousButton  = UIBarButtonItem(title: "Prev", style: .Plain, target: self, action: "keyboardPrevButton")
        
        toolbar.setItems([fixedSpaceButton, nextButton, fixedSpaceButton, flexibleSpaceButton, doneButton, fixedSpaceButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
        NotificationCenter.default.addObserver(self, selector: #selector(UserRegisterViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserRegisterViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = self.currentTextField
        {
            if (!aRect.contains(activeFieldPresent.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }
    
    
    func keyboardWillBeHidden(_ notification: Notification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.keyboardNextButton()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.currentTextField = nil
    }
    
    @IBAction func back(_ sender : AnyObject){
        self.dismiss(animated: true, completion: nil)
    }

}
