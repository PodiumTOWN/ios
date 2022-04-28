//
//  AddState.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import UIKit

struct AddState: Equatable {
  // Fields
  var profile: Profile
  var text: String = ""
  var images: [UIImage] = []
  var isPickerPresented = false
  var image: UIImage?
  var isLoading = false
  
  // View States
}
