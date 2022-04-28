//
//  EditProfileReducer.swift
//  ink
//
//  Created by Michael Jach on 04/04/2022.
//

import ComposableArchitecture
import Combine
import UIKit

let editProfileReducer = Reducer<EditProfileState, EditProfileAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .setUsername(let username):
      state.username = username
      return .none
      
    case .setBio(let bio):
      state.bio = bio
      return .none
      
    case .setAvatar(let image):
      state.avatar = image
      return .none
      
    case .presentImagePicker(let isPresented):
      state.isImagePickerPresented = isPresented
      return .none
      
    case .save:
      var profile = Profile(
        userAddress: state.profile.userAddress,
        username: state.username,
        following: [],
        avatar: state.profile.avatar,
        bio: state.bio.isEmpty ? state.profile.bio : state.bio,
        privateKey: state.profile.privateKey
      )
      
      let avatar = state.avatar
      let privateKey = state.profile.privateKey
      state.isLoading = true
      
      return Future<Profile, AppError> { promise in
        let myGroup = DispatchGroup()
        if let avatar = avatar?.scalePreservingAspectRatio(targetSize: CGSize(width: 150, height: 150)).pngData() {
          myGroup.enter()
          environment.ipfsApi.uploadPhoto(
            url: environment.ipfsUrl,
            imageData: avatar) { response, error in
              if let response = response {
                profile.avatar = response.Hash
                myGroup.leave()
              } else if let error = error {
                myGroup.leave()
              }
            }
        }
        
        myGroup.notify(queue: .main) {
          environment.rpcApi.updateProfile(
            environment: environment,
            profile: profile) { profile, error in
              if let profile = profile {
                promise(.success(profile))
              } else if let error = error {
                promise(.failure(error))
              }
            }
          
          if privateKey == nil {
            let deepLinkUrl = environment.walletConnect.getUrl()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              if let url = URL(string: "wc://"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
            }
          }
        }
      }
      .catchToEffect()
      .map(EditProfileAction.didSave)
      
    case .didSave(.success(let profile)):
      state.isLoading = false
      state.profile = profile
      return .none
      
    case .didSave(.failure(let error)):
      state.isLoading = false
      return .none
      
    case .dismiss:
      return .none
    }
  }
)
