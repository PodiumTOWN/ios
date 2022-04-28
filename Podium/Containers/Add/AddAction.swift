//
//  AddAction.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import UIKit

enum AddAction {
  // Actions
  case setText(text: String)
  case send
  case didSend(Result<Story, AppError>)
  case presentPicker(isPresented: Bool)
  case setImage(image: UIImage?)
  case dismiss
}
