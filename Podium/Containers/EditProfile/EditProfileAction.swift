//
//  EditProfileAction.swift
//  ink
//
//  Created by Michael Jach on 04/04/2022.
//

import UIKit

enum EditProfileAction {
  // Actions
  case save
  case didSave(Result<Profile, AppError>)
  case setUsername(username: String)
  case dismiss
  case setBio(bio: String)
  case setAvatar(image: UIImage?)
  case presentImagePicker(isPresented: Bool)
  
  // View Actions
}
