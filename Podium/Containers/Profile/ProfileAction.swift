//
//  ProfileAction.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

enum ProfileAction {
  // Actions
  case presentEdit(isPresented: Bool)
  case presentDetail(isPresented: Bool, story: Story)
  case presentMedia(isPresented: Bool, photo: String)
  case presentSettings(isPresented: Bool)
  case getPendingTransactions
  case didGetPending(Result<[Transaction], Error>)
  case viewEtherscan(transaction: Transaction)
  case dismissBanner
  case fetchProfile
  case didFetchProfile(Result<Profile, Error>)
  case getStories
  case didGetStories(Result<[Story], Error>)
  
  // View Actions
  case edit(EditProfileAction)
  case detail(DetailAction)
  case media(MediaAction)
  case settings(SettingsAction)
}
