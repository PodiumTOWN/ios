//
//  ListState.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import Foundation

struct ListState: Equatable {
  // Fields
  var profile: Profile
  var stories: [Story] = []
  var isAddPresented = false
  var isDetailPresented = false
  var isPhotoPresented = false
  var isStoryPresented = false
  var isProfilePresented = false
  var isLoadingRefreshable = false
  var bannerData: BannerData?
  
  // View States
  var addState: AddState?
  var detailState: DetailState?
  var mediaState: MediaState?
  var storyState: StoryState?
  var profileState: ProfileState?
}
