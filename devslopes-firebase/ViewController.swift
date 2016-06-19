//
//  ViewController.swift
//  devslopes-firebase
//
//  Created by KwokWing Tong on 6/6/2016.
//  Copyright © 2016 Tong Kwok Wing. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase


class ViewController: UIViewController {
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }

  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
      self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
    }
  }

  @IBAction func fbBtnPressed(sender: UIButton){
    let facebookLogin = FBSDKLoginManager()
    
    facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult:FBSDKLoginManagerLoginResult!, facebookError:NSError!) in
      
      if facebookError != nil {
        print("Facebook Login failed. Error \(facebookError)")
      }else {
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        print("Successfully logged in with Facebook. \(accessToken)")
        
//        DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token:accessToken, withCompletionBlock{  error, authData in
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
          
          if error != nil {
            print("Login failed. \(error)")
          }else {
            print("Logged in. \(user)!")
            
            let userData = ["provider": credential.provider]
            DataService.ds.createFirebaseUser(user!.uid, user: userData)
            
            NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
            
          }
          
        })
        
        
      }
    }
    
    
  
  }
  
  @IBAction func attemptLogin(sender: UIButton!){
    
    if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
      
      FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
        
        if error != nil {
          print(error)
          print(error?.code)
          
          if error!.code == STATUS_ACCOUNT_NONEXIST {
            
            FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
              
              if error != nil {
                self.showErrorAlert("Could Not Create Account", msg: "Problem creating the account. Try again")
                print(error)
                print(error?.code)
              }else {
                
                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                
                
                let userData = ["provider": "email"]
                
                DataService.ds.createFirebaseUser(user!.uid, user: userData)
                
                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
              }
            })
          } else {
            self.showErrorAlert("Could Not Log In", msg: "Please check username and password.")
          }
        }else {
          NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
          self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
        
      })
      
      
    }else {
      showErrorAlert("Email and Password Required", msg: "Please fill in an email and a password")
    }
  }
  
  func showErrorAlert(title: String, msg: String){
    
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default , handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
    
  }
  
}

