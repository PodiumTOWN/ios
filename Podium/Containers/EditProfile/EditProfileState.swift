//
//  EditProfileState.swift
//  ink
//
//  Created by Michael Jach on 04/04/2022.
//

import UIKit

struct EditProfileState: Equatable {
  // Fields
  var profile: Profile
  var username = ""
  var bio = ""
  var avatar: UIImage?
  var isImagePickerPresented = false
  var isLoading = false
  
  // View States
}
