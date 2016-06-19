//
//  MaterialTextField.swift
//  devslopes-firebase
//
//  Created by KwokWing Tong on 7/6/2016.
//  Copyright © 2016 Tong Kwok Wing. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {
  
  override func awakeFromNib() {
    layer.cornerRadius = 2.0
    layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
    layer.borderWidth = 1.0
    
  }
  
  
  override func textRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectInset(bounds, 10, 0)
  }
  
  override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectInset(bounds, 10, 0)
  }
  
  override func editingRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectInset(bounds, 10, 0)
  }
}
