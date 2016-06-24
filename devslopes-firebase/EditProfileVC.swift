//
//  EditProfileVC.swift
//  devslopes-firebase
//
//  Created by KwokWing Tong on 15/6/2016.
//  Copyright © 2016 Tong Kwok Wing. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import EZLoadingActivity

class EditProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

  @IBOutlet weak var editProfileImage: UIImageView!
  @IBOutlet weak var editUsernameTxtField: MaterialTextField!
  @IBOutlet weak var UpdateProfileProgressView: UIProgressView!
  
 
  
  var imagePicker: UIImagePickerController!
  var profileImageSelected = false
  
  var post: Post!
  var request: Request?
  
  var usernames: String?
  var profileImgUrl: String?
  
  var percent: Float?
  

  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
      editProfileImage.userInteractionEnabled = true
//     editProfileImage.layer.cornerRadius = editProfileImage.frame.size.width / 2
//      editProfileImage.clipsToBounds = true
      UpdateProfileProgressView.progress = 0
      UpdateProfileProgressView.hidden = true
      
      EZLoadingActivity.Settings.FontName = "NotoSans-Regular"
      EZLoadingActivity.Settings.ActivityColor = UIColor(red: 219/255, green: 223/255, blue: 34/255, alpha: 1.0)
      EZLoadingActivity.Settings.SuccessText = "Success Update"
      EZLoadingActivity.Settings.TextColor = UIColor(red: 219/255, green: 223/255, blue: 34/255, alpha: 1.0)
      EZLoadingActivity.Settings.BackgroundColor = UIColor(red: 150/255, green: 102/255, blue: 50/255, alpha: 0.7)
      EZLoadingActivity.Settings.SuccessColor = UIColor(red: 219/255, green: 223/255, blue: 34/255, alpha: 1.0)
      EZLoadingActivity.hide()
      
    }
  
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    usernames = NSUserDefaults.standardUserDefaults().objectForKey(USERNAME_DEFAULT_KEY) as? String
    profileImgUrl = NSUserDefaults.standardUserDefaults().objectForKey(PROFILEIMAGE_DEFAULT_KEY) as? String
    var imageCache: UIImage?
    if profileImgUrl != nil {
      if let url = profileImgUrl {
        imageCache = FeedVC.imageCache.objectForKey(url) as? UIImage
      }
      self.editProfileImage.hidden = true
      
      configureProfileView(usernames, profileURL: profileImgUrl, img: imageCache)
    }else{
      configureProfileView(usernames, profileURL: nil, img: editProfileImage.image)
    }
    
    
    
    
    
    
  }
  
  @IBAction func selectProfileImage(sender: UITapGestureRecognizer){
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    NSUserDefaults.standardUserDefaults().removeObjectForKey(PROFILEIMAGE_DEFAULT_KEY)
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    editProfileImage.image = image
    
    profileImageSelected = true
  }

  @IBAction func changeUserProfile(sender: AnyObject) {
    
    if let editTxt = editUsernameTxtField.text where editTxt != "" {
      
      if let editImage = editProfileImage.image where profileImageSelected == true || profileImgUrl != ""{
        
//        let urlStr = "https://post.imageshack.us/upload_api.php"
//        let url = NSURL(string: urlStr)!
//        let imgData = UIImageJPEGRepresentation(image, 0.2)!
//        let keyData = "ZWUR08QX39b872c69c7ddb60eb59886469a90d89".dataUsingEncoding(NSUTF8StringEncoding)!
//        // this key from Mark Price let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3"
//        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        let urlStr = "https://post.imageshack.us/upload_api.php"
        let url = NSURL(string: urlStr)!
        let imgData = UIImageJPEGRepresentation(editImage, 0.5)!
        let keyData = "ZWUR08QX39b872c69c7ddb60eb59886469a90d89".dataUsingEncoding(NSUTF8StringEncoding)!
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
          multipartFormData.appendBodyPart(data: imgData, name: "fileupload",fileName: "image",mimeType: "image/jpg")
          multipartFormData.appendBodyPart(data: keyData, name: "key")
          multipartFormData.appendBodyPart(data: keyJSON, name: "format")
          
        }) { encodeingResult in
          
          switch encodeingResult{
          case .Success(request: let upload, streamingFromDisk: _, streamFileURL: _):
            upload.progress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
              
              dispatch_async(dispatch_get_main_queue()){
                self.UpdateProfileProgressView.hidden = false
                 self.percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                self.UpdateProfileProgressView.setProgress(self.percent!, animated: true)
                print(self.percent!)
                EZLoadingActivity.show("Updating your profile", disableUI: true)
                
                if self.percent! == 1.0 {
                  self.UpdateProfileProgressView.hidden = true
                  EZLoadingActivity.hide(success: true, animated: true)
                }
              }
              
              
            })
            
            upload.responseJSON(completionHandler: { (response) in
              
              let result = response.result
              
              if let info = result.value as? Dictionary<String,AnyObject> {
                if let links = info["links"] as? Dictionary<String, AnyObject> {
                  if let imageLink = links["image_link"] as? String {
                    self.changeProfileInFirebase(imageLink)
                    
                  }
                }
              }
              
            })
          case .Failure(let error):
            print(error)
          
          }
          
        }
      }else{
        self.changeProfileInFirebase(profileImgUrl)
      }
    }
  }
  
  func changeProfileInFirebase(imgUrl: String?){
    var post: Dictionary<String, AnyObject> = ["username" : editUsernameTxtField.text!]
    
    if editUsernameTxtField.text == "" {
      post["username"] = "anonymous"
    }else{
      post["username"] = editUsernameTxtField.text
    }
    
    
    
    if imgUrl != nil {
      post["profileImg"] = imgUrl
    }
    
    let firebaseProfile = DataService.ds.REF_USER_CURRENT.child("profile")
    firebaseProfile.updateChildValues(post)
    
    let userStr = post["username"] as! String
    let profileImgStr = post["profileImg"] as! String
     NSUserDefaults.standardUserDefaults().setObject(userStr, forKey: USERNAME_DEFAULT_KEY)
     NSUserDefaults.standardUserDefaults().setObject(profileImgStr,forKey: PROFILEIMAGE_DEFAULT_KEY)
    self.post = Post(username: userStr, profileImgUrl: profileImgStr)
    
    profileImageSelected = false
    
   
    
    
  }
  
  
  func configureProfileView(username: String?,profileURL:String?, img: UIImage?){
    //self.post = post
    
    if profileURL != nil {
      
      if img != nil {
        self.editProfileImage.image = img
      }else{
        
        request = Alamofire.request(.GET, profileURL!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, error) in
          
          if error == nil {
            
            
            let image = UIImage(data: data!)!
            self.editProfileImage.image = image
            self.editProfileImage.hidden = false
            FeedVC.imageCache.setObject(image, forKey: profileURL!)
          }
        })
      }
      
      
      
    }
   
    if username != "" {
      editUsernameTxtField.text = username
    }
    
    
  }
    


}
