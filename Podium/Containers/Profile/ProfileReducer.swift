//
//  ProfileReducer.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import ComposableArchitecture
import Combine
import UIKit

let profileReducer = Reducer<ProfileState, ProfileAction, AppEnvironment>.combine(
  editProfileReducer.optional().pullback(
    state: \.editState,
    action: /ProfileAction.edit,
    environment: { $0 }
  ),
  settingsReducer.optional().pullback(
    state: \.settingsState,
    action: /ProfileAction.settings,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .getPendingTransactions:
      state.isLoadingPending = true
      var stateTransactions = state.pendingTransactions
      
      if let pending = environment.storage.object(forKey: "pending") as? Data,
         let loadedPending = try? JSONDecoder().decode(
          [Transaction].self,
          from: pending
        ) {
          stateTransactions = loadedPending
        } else {
          stateTransactions = []
        }
      
      return Future<[Transaction], Error> { promise in
        let dispatchGroup = DispatchGroup()
        var transactions: [Transaction] = []
        stateTransactions.forEach { transaction in
          dispatchGroup.enter()
          environment.rpcApi.getTransactionDetails(
            environment: environment,
            transaction: transaction) { transaction, error in
              if let transaction = transaction {
                transactions.append(transaction)
              } else if let error = error {
                
              }
              dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
          promise(.success(transactions))
        }
      }
      .catchToEffect()
      .map(ProfileAction.didGetPending)
      
    case .didGetPending(.success(let transactions)):
      state.isLoadingPending = false
      state.pendingTransactions = transactions
      return .none
      
    case .didGetPending(.failure(let error)):
      return .none
      
    case .fetchProfile:
      let publicKey = state.profile.userAddress
      let privateKey = state.profile.privateKey
      
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
      .map(ProfileAction.didFetchProfile)
      
    case .didFetchProfile(.success(let profile)):
      state.profile = profile
      return .none
      
    case .didFetchProfile(.failure(let error)):
      return .none
      
    case .presentSettings(let isPresented):
      state.isSettingsPresented = isPresented
      if isPresented {
        state.settingsState = SettingsState()
      }
      return .none
      
    case .presentEdit(let isPresented):
      state.isEditPresented = isPresented
      if isPresented {
        state.editState = EditProfileState(
          profile: state.profile,
          username: state.profile.username ?? "",
          bio: state.profile.bio ?? ""
        )
      }
      return .none
      
    case .edit(.didSave(.success(let profile))):
      if let transaction = profile.transaction {
        state.pendingTransactions.append(transaction)
      }
      if let encoded = try? JSONEncoder().encode(state.pendingTransactions) {
        environment.storage.set(encoded, forKey: "pending")
      }
      state.profile = profile
      state.isEditPresented = false
      return .none
      
    case .edit(.didSave(.failure(let error))):
      state.isEditPresented = false
      state.bannerData = BannerData(
        title: "Error",
        detail: error.description,
        type: .error
      )
      return .none
      
    case .edit(.dismiss):
      state.isEditPresented = false
      return .none
      
    case .edit(_):
      return .none
      
    case .presentDetail(let isPresented, let story):
      state.isDetailPresented = isPresented
      if isPresented {
        state.detailState = DetailState(
          story: story
        )
      }
      return .none
      
    case .presentMedia(let isPresented, let photo):
      state.isMediaPresented = isPresented
      if isPresented {
        state.mediaState = MediaState(
          photo: photo
        )
      }
      return .none
      
    case .media(.dismiss):
      state.isMediaPresented = false
      return .none
      
    case .media(_):
      return .none
      
    case .settings(_):
      return .none
      
    case .viewEtherscan(let transaction):
      if let url = URL(string: "\(environment.etherscanUrl)/tx/\(transaction.address)") {
        UIApplication.shared.open(url)
      }
      return .none
      
    case .detail(_):
      return .none
      
    case .dismissBanner:
      state.bannerData = nil
      return .none
      
    case .getStories:
      let publicKey = state.profile.userAddress
      
      return Future<[Story], Error> { promise in
        environment.rpcApi.getStories(
          environment: environment,
          publicKey: publicKey,
          following: [publicKey]) { result, error in
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
      .map(ProfileAction.didGetStories)
      
    case .didGetStories(.success(let stories)):
      state.stories = stories
      return .none
      
    case .didGetStories(.failure(let error)):
      return .none
    }
  }
)
