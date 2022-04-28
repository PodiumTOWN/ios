//
//  AppReducer.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import ComposableArchitecture
import Combine

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  loginReducer.optional().pullback(
    state: \.login,
    action: /AppAction.login,
    environment: { $0 }
  ),
  pagesReducer.optional().pullback(
    state: \.pages,
    action: /AppAction.pages,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .fetchProfile(let publicKey, let privateKey):
      return Future<Profile, Error> { promise in
        environment.rpcApi.getProfile(
          environment: environment,
          publicKey: publicKey,
          privateKey: privateKey) { profile, error in
            if let profile = profile {
              promise(.success(profile))
            } else if let error = error {
              promise(.failure(error))
            }
          }
      }
      .catchToEffect()
      .map(AppAction.didFetchProfile)
      
    case .didFetchProfile(.success(let profile)):
      var mutatedProfile = profile
      if let localProfile = environment.storage.object(forKey: "profile") as? Data {
        if let loadedProfile = try? JSONDecoder().decode(
          Profile.self,
          from: localProfile
        ) {
          mutatedProfile.following = Array(Set(loadedProfile.following + profile.following))
        }
      }
      
      if let encoded = try? JSONEncoder().encode(mutatedProfile) {
        environment.storage.set(encoded, forKey: "profile")
      }
      state.pages?.profile = mutatedProfile
      state.pages?.profileState?.profile = mutatedProfile
      return .none
      
    case .didFetchProfile(.failure(let error)):
      return .none
      
    case .getProfile:
      environment.walletConnect.reconnectIfNeeded(
        bridgeUrl: environment.bridgeUrl
      )
      
      if let profile = environment.storage.object(forKey: "profile") as? Data {
        if let loadedProfile = try? JSONDecoder().decode(
          Profile.self,
          from: profile
        ) {
          state.login = nil
          state.pages = PagesState(
            profile: loadedProfile
          )
          
          return Effect(value: .fetchProfile(
            publicKey: loadedProfile.userAddress,
            privateKey: loadedProfile.privateKey
          ))
        }
      } else {
        state.login = LoginState()
      }
      
      return .none
      
    case .login(.didGetProfile(.success(let profile))):
      state.login = nil
      state.pages = PagesState(
        profile: profile
      )
      
      if let encoded = try? JSONEncoder().encode(profile) {
        environment.storage.set(encoded, forKey: "profile")
      }
      return .none
      
    case .login(_):
      return .none
      
    case .pages(.profile(.settings(.disconnect))):
      state.pages = nil
      state.login = LoginState()
      return .none
      
    case .pages(_):
      return .none
    }
  }
)
