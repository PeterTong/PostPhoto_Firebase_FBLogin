//
//  MaterialButton.swift
//  devslopes-firebase
//
//  Created by KwokWing Tong on 6/6/2016.
//  Copyright © 2016 Tong Kwok Wing. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

  override func awakeFromNib() {
    layer.cornerRadius = 2.0
    layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSizeMake(0.0, 2.0)
  }
}
