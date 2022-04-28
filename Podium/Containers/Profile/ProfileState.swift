//
//  ProfileAction.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

struct ProfileState: Equatable {
  var profile: Profile
  var stories: [Story] = []
  var pendingTransactions: [Transaction] = []
  var isEditPresented = false
  var isDetailPresented = false
  var isMediaPresented = false
  var isSettingsPresented = false
  var bannerData: BannerData?
  var isLoadingPending = false
  var isLocalProfile = false
  
  // View States
  var editState: EditProfileState?
  var detailState: DetailState?
  var mediaState: MediaState?
  var settingsState: SettingsState?
}
