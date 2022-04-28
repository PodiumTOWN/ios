//
//  TimelineReducer.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import ComposableArchitecture
import Combine

let pagesReducer = Reducer<PagesState, PagesAction, AppEnvironment>.combine(
  listReducer.optional().pullback(
    state: \.listState,
    action: /PagesAction.list,
    environment: { $0 }
  ),
  profileReducer.optional().pullback(
    state: \.profileState,
    action: /PagesAction.profile,
    environment: { $0 }
  ),
  searchReducer.optional().pullback(
    state: \.searchState,
    action: /PagesAction.search,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .initialize:
      let publicKey = state.profile.userAddress
      var following = state.profile.following
      following.append(publicKey)
      
      state.listState = ListState(
        profile: state.profile,
        stories: state.stories
      )
      state.profileState = ProfileState(
        profile: state.profile,
        isLocalProfile: true
      )
      state.searchState = SearchState(
        profile: state.profile
      )
      
      if let stories = environment.storage.object(forKey: "stories") as? Data {
        if let loadedStories = try? JSONDecoder().decode(
          [Story].self,
          from: stories
        ) {
          state.stories = loadedStories
        }
      }
      
      return Future<[Story], Error> { promise in
        environment.rpcApi.getStories(
          environment: environment,
          publicKey: publicKey,
          following: following) { result, error in
            if let stories = result {
              promise(.success(stories))
            } else if let error = error {
              promise(.failure(error))
            }
          }
      }
      .catchToEffect()
      .map(PagesAction.didGetStories)
      
    case .didGetStories(.success(let stories)):
      state.stories = stories
      state.profileState?.stories = stories
      state.listState?.stories = stories
      if let encoded = try? JSONEncoder().encode(stories) {
        environment.storage.set(encoded, forKey: "stories")
      }
      return .none
      
    case .didGetStories(.failure(let error)):
      return .none
      
    case .list(.add(.didSend(.success(let post)))):
      if let transaction = post.transaction {
        state.profileState?.pendingTransactions.append(transaction)
      }
      
      state.stories.insert(post, at: 0)
      
      if let encoded = try? JSONEncoder().encode(state.stories) {
        environment.storage.set(encoded, forKey: "stories")
      }

      if let encoded = try? JSONEncoder().encode(state.profileState?.pendingTransactions) {
        environment.storage.set(encoded, forKey: "pending")
      }
      return .none
      
    case .list(_):
      return .none
      
    case .profile(_):
      return .none
      
    case .search(.follow(let publicKey)):
      state.profile.following.append(publicKey)
      state.listState?.profile.following.append(publicKey)
      state.searchState?.profile.following.append(publicKey)
      if let encoded = try? JSONEncoder().encode(state.profile) {
        environment.storage.set(encoded, forKey: "profile")
      }
      return .none
      
    case .search(.unfollow(let publicKey)):
      state.profile.following.removeAll(where: { $0 == publicKey })
      state.searchState?.profile.following.removeAll(where: { $0 == publicKey })
      if let encoded = try? JSONEncoder().encode(state.profile) {
        environment.storage.set(encoded, forKey: "profile")
      }
      return .none
      
    case .search(_):
      return .none
    }
  }
)
