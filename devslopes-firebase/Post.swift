//
//  Post.swift
//  devslopes-firebase
//
//  Created by KwokWing Tong on 11/6/2016.
//  Copyright © 2016 Tong Kwok Wing. All rights reserved.
//

import Foundation
import Firebase
class Post {
  
  private var _postDescription: String!
  private var _imageUrl: String?
  private var _likes: Int!
  private var _username: String!
  private var _postKey: String!
  private var _postRef: FIRDatabaseReference!
  
  private var _profileImageUrl: String?
  
  var profileImageUrl: String? {
    return _profileImageUrl
  }
  
  var postDescription: String {
    return _postDescription
  }
  
  var imageUrl: String? {
    return _imageUrl
  }
  
  var likes: Int {
    return _likes
  }
  
  var username: String {
    return _username
  }
  
  var postKey: String {
    return _postKey
  }
  
  init(description: String, imageUrl: String?, username: String){
    self._postDescription = description
    self._imageUrl = imageUrl
    self._username = username
  }
  
  init(postKey: String, dictionary: Dictionary<String, AnyObject>){
    self._postKey = postKey
    
    if let likes = dictionary["likes"] as? Int {
      self._likes = likes
    }
    
    if let imgUrl = dictionary["imageUrl"] as? String {
      self._imageUrl = imgUrl
    }
    
    if let desc = dictionary["description"] as? String {
      self._postDescription = desc
    }
    
    if let userName = dictionary["username"] as? String
    {
      self._username = userName
    }
    
    if let profileImgUrl = dictionary["profileImg"] as? String{
      self._profileImageUrl = profileImgUrl
    }
    
    
    self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
  }
  
  init(username: String,profileImgUrl: String){
    self._username = username
    self._profileImageUrl = profileImageUrl
  }
  
  func adjustLikes(addLikes: Bool)  {
    
    if addLikes {
      _likes = _likes + 1
    }else {
      _likes = _likes - 1
    }
    
    _postRef.child("likes").setValue(_likes)
  }
  
}