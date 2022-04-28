//
//  ListReducer.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import ComposableArchitecture
import Combine

let listReducer = Reducer<ListState, ListAction, AppEnvironment>.combine(
  addReducer.optional().pullback(
    state: \.addState,
    action: /ListAction.add,
    environment: { $0 }
  ),
  detailReducer.optional().pullback(
    state: \.detailState,
    action: /ListAction.detail,
    environment: { $0 }
  ),
  storyReducer.optional().pullback(
    state: \.storyState,
    action: /ListAction.story,
    environment: { $0 }
  ),
  mediaReducer.optional().pullback(
    state: \.mediaState,
    action: /ListAction.media,
    environment: { $0 }
  ),
  profileReducer.optional().pullback(
    state: \.profileState,
    action: /ListAction.profile,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .dismissBanner:
      state.bannerData = nil
      return .none
      
    case .getStories:
      let publicKey = state.profile.userAddress
      var following = state.profile.following
      following.append(publicKey)
      
      state.isLoadingRefreshable = true
      
      if let stories = environment.storage.object(forKey: "stories") as? Data {
        if let loadedStories = try? JSONDecoder().decode(
          [Story].self,
          from: stories
        ) {
          state.stories = loadedStories
        }
      }
      
      if let pending = environment.storage.object(forKey: "pending") as? Data {
        if let loadedPending = try? JSONDecoder().decode(
          [Transaction].self,
          from: pending
        ) {
          let pendingAdd = loadedPending
            .filter({ $0.type == .addStory })
            
          
        }
      }
      
      return Future<[Story], Error> { promise in
        environment.rpcApi.getStories(
          environment: environment,
          publicKey: publicKey,
          following: following) { result, error in
            DispatchQueue.main.async {
              if let stories = result {
                promise(.success(stories))
              } else if let error = error {
                promise(.failure(error))
              }
            }
          }
      }
      .catchToEffect()
      .map(ListAction.didGetStories)
      
    case .didGetStories(.success(let stories)):
      state.stories = stories
      state.isLoadingRefreshable = false
      if let encoded = try? JSONEncoder().encode(stories) {
        environment.storage.set(encoded, forKey: "stories")
      }
      return .none
      
    case .didGetStories(.failure(let error)):
      state.isLoadingRefreshable = false
      return .none
      
    case .presentAdd(let isPresented):
      state.isAddPresented = isPresented
      if isPresented {
        state.addState = AddState(
          profile: state.profile
        )
      }
      return .none
      
    case .presentDetail(let isPresented, let story):
      state.isDetailPresented = isPresented
      if isPresented {
        state.detailState = DetailState(
          story: story
        )
      }
      return .none
      
    case .presentProfile(let isPresented, let profile):
      state.isProfilePresented = isPresented
      if let profile = profile, isPresented {
        state.profileState = ProfileState(
          profile: profile
        )
      }
      return .none
      
    case .presentMedia(let isPresented, let photo):
      state.isPhotoPresented = isPresented
      if isPresented {
        state.mediaState = MediaState(
          photo: photo
        )
      }
      return .none
      
    case .presentStory(let isPresented, let story):
      state.isStoryPresented = isPresented
      if isPresented {
        state.storyState = StoryState(
          
        )
      }
      return .none
      
    case .dismissDetail:
      state.isDetailPresented = false
      return .none
      
    case .add(.didSend(.success(let story))):
      state.stories.insert(story, at: 0)
      state.isAddPresented = false
      return .none
      
    case .add(.didSend(.failure(let error))):
      state.isAddPresented = false
      state.bannerData = BannerData(
        title: "Error",
        detail: error.description,
        type: .error
      )
      return .none
      
    case .add(.dismiss):
      state.isAddPresented = false
      return .none
      
    case .add(_):
      return .none
      
    case .media(.dismiss):
      state.isPhotoPresented = false
      return .none
      
    case .media(_):
      return .none
      
    case .detail(_):
      return .none
      
    case .profile(_):
      return .none
    }
  }
)
