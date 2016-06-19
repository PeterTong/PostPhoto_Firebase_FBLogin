//
//  PostCell.swift
//  devslopes-firebase
//
//  Created by KwokWing Tong on 10/6/2016.
//  Copyright © 2016 Tong Kwok Wing. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var likesLbl: UILabel!
  @IBOutlet weak var likeImage: UIImageView!
  
  @IBOutlet weak var usernameLbl: UILabel!
  var post: Post!
  var request: Request?
  var likeRef: FIRDatabaseReference!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
//    likeRef = FIRDatabaseReference()
    let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped(_:)))
    tap.numberOfTapsRequired = 1
    likeImage.addGestureRecognizer(tap)
    likeImage.userInteractionEnabled = true
  }
  
  override func drawRect(rect: CGRect) {
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
    
    showcaseImg.clipsToBounds = true
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    
  }
  
  func configureCell(post: Post, img: UIImage?) {
    
    self.post = post
   
    
    self.descriptionText.text = post.postDescription
    self.likesLbl.text = "\(post.likes)"
    
    if post.imageUrl != nil {
      
      if img != nil {
        self.showcaseImg.image = img
      }else{
        
        request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, error) in
          
          if error == nil {
            let img = UIImage(data: data!)!
            self.showcaseImg.image = img
            FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
          }
          
        })
        
      }
      
    }else{
      self.showcaseImg.hidden = true
    }
    
    likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
    
    likeRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
      print(snapshot.value)
      if let doesNotExist = snapshot.value as? NSNull {
        
        // This means we have not liked this specific post
        self.likeImage.image = UIImage(named: "heart-empty")
        
      }else{
        self.likeImage.image = UIImage(named: "heart-full")
      }
    })
    
  }
  
   func likeTapped(sender: UITapGestureRecognizer){
    likeRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
      
      if let doesNotExist = snapshot.value as? NSNull {
        
        
        self.likeImage.image = UIImage(named: "heart-full")
        self.post.adjustLikes(true)
        self.likeRef.setValue(true)
        
      }else{
        self.likeImage.image = UIImage(named: "heart-empty")
        self.post.adjustLikes(false)
        self.likeRef.removeValue()
      }
    })
  }

}
