//
//  FeedVC.swift
//  devslopes-firebase
//
//  Created by KwokWing Tong on 10/6/2016.
//  Copyright © 2016 Tong Kwok Wing. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var posts = [Post]()
  static var imageCache = NSCache()
  
  var imagePicker: UIImagePickerController!
  
  @IBOutlet weak var postField: MaterialTextField!
  @IBOutlet weak var imageSelectorImage: UIImageView!
  
  var imageSelected = false
  
  @IBOutlet weak var profileBarItem: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    
    tableView.estimatedRowHeight = 339
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    
    
    DataService.ds.REF_POSTS.observeEventType( FIRDataEventType.Value, withBlock:{ snapshot in
      print(snapshot.value)
      
      self.posts = []
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          print("SNAP: \(snap)")
          
          if let postDict = snap.value as? Dictionary<String, AnyObject> {
            let key = snap.key
            let post = Post(postKey: key, dictionary: postDict)
            self.posts.append(post)
          }
        }
      }
      self.tableView.reloadData()
      
    })
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    profileBarItem.image = UIImage(named: "profileEdit")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let post = posts[indexPath.row]
    
    if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
      
      cell.request?.cancel()
      
      var img: UIImage?
      
      if let url = post.imageUrl {
        img = FeedVC.imageCache.objectForKey(url) as? UIImage
        
      }
      
      cell.configureCell(post,img: img)
      
      return cell
    }else{
      return PostCell()
    }
    
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    let post = posts[indexPath.row]
    
    // If there are no image in the cell, we want to resize/decrease the cell height
    if post.imageUrl == nil {
      return 160
    }else{
      return tableView.estimatedRowHeight
    }
  }
  
//  override func viewDidAppear(animated: Bool) {
//    super.viewDidAppear(animated)
//    tableView.reloadData()
//  }
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    imageSelectorImage.image = image
    imageSelected = true
    
  }
  
  @IBAction func selectImage(sender: UITapGestureRecognizer) {
    presentViewController(imagePicker, animated: true, completion: nil)
    
  }

  @IBAction func makePost(sender: AnyObject) {
    
    if let txt = postField.text where txt != "" {
      
      if let image = imageSelectorImage.image where imageSelected == true{
        
        let urlStr = "https://post.imageshack.us/upload_api.php"
        let url = NSURL(string: urlStr)!
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        let keyData = "ZWUR08QX39b872c69c7ddb60eb59886469a90d89".dataUsingEncoding(NSUTF8StringEncoding)!
        // this key from Mark Price let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3"
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
          
          multipartFormData.appendBodyPart(data: imgData, name: "fileupload",fileName: "image",mimeType: "image/jpg")
          multipartFormData.appendBodyPart(data: keyData, name: "key")
          multipartFormData.appendBodyPart(data: keyJSON, name: "format")
          
        }) { encodeingResult in
          
          switch encodeingResult {
          case .Success(let upload, _, _):
            
            upload.responseJSON(completionHandler: { (response) in
              
              let result = response.result
              
              if let info = result.value as? Dictionary<String,AnyObject> {
                if let links = info["links"] as? Dictionary<String, AnyObject> {
                  if let imgLink = links["image_link"] as? String {
                    print("LINK: \(imgLink)")
                    
                    self.postToFirebase(imgLink)
                  }
                }
              }
              
            })
          case .Failure(let error):
            print(error)
          }
          
          
        }
      }else{
        self.postToFirebase(nil)
      }
    }
  }
  
  
  func postToFirebase(imgUrl: String?){
    var post: Dictionary<String, AnyObject> = [
      "description": postField.text!,
      "likes": 0
    ]
    
    if imgUrl != nil {
      post["imageUrl"] = imgUrl
    }
    
    let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
    firebasePost.setValue(post)
    
    postField.text = ""
    imageSelectorImage.image = UIImage(named: "camera")
    imageSelected = false
    
    tableView.reloadData()
  }
  @IBAction func logoutBarItemPressed(sender: UIBarButtonItem) {
    
    do {
      try FIRAuth.auth()?.signOut()
      NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_UID)
      
    } catch let error as NSError {
      print(error.debugDescription)
    }
    
    dismissViewControllerAnimated(true, completion: nil)
//    self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("View1") , animated: true)
  }
}
