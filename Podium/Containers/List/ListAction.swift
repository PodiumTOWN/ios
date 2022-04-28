//
//  ListAction.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

enum ListAction {
  // Actions
  case presentAdd(isPresented: Bool)
  case presentDetail(isPresented: Bool, story: Story)
  case presentMedia(isPresented: Bool, photo: String)
  case presentStory(isPresented: Bool, story: String)
  case presentProfile(isPresented: Bool, profile: Profile?)
  case getStories
  case didGetStories(Result<[Story], Error>)
  case dismissDetail
  case dismissBanner
  
  // View Actions
  case add(AddAction)
  case detail(DetailAction)
  case media(MediaAction)
  case story(StoryAction)
  case profile(ProfileAction)
}
