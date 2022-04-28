//
//  AddReducer.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import ComposableArchitecture
import Combine
import UIKit

let addReducer = Reducer<AddState, AddAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .setText(let text):
      if text.count <= 220 {
        state.text = text
      }
      return .none
      
    case .send:
      var story = Story(
        index: 0,
        owner: state.profile.userAddress,
        text: state.text,
        profile: state.profile,
        timestamp: UInt(Date().timeIntervalSince1970 * 1000)
      )
      
      let images = state.images.map { image in
        return image.scalePreservingAspectRatio(
          targetSize: CGSize(
            width: 300,
            height: 300
          )
        )
      }
      
      state.isLoading = true
      let privateKey = state.profile.privateKey
      
      return Future<Story, AppError> { promise in
        if let text = story.text {
          let myGroup = DispatchGroup()
          var imagesToUpload: [String] = []
          
          images.forEach { image in
            myGroup.enter()
            environment.ipfsApi.uploadPhoto(
              url: environment.ipfsUrl,
              imageData: image.jpegData(compressionQuality: 8)!) { response, error in
                if let response = response {
                  imagesToUpload.append(response.Hash)
                  myGroup.leave()
                } else if let error = error {
                  myGroup.leave()
                }
              }
          }
          
          myGroup.notify(queue: .main) {
            story.images = imagesToUpload
            environment.rpcApi.addStory(
              environment: environment,
              publicKey: story.owner,
              privateKey: privateKey,
              story: story) { story, error in
                DispatchQueue.main.async {
                  if let story = story {
                    promise(.success(story))
                  } else if let error = error {
                    promise(.failure(error))
                  }
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
        } else {
          promise(.failure(.general))
        }
      }
      .catchToEffect()
      .map(AddAction.didSend)
      
    case .didSend(.success(let story)):
      state.isLoading = false
      return .none
      
    case .didSend(.failure(let error)):
      state.isLoading = false
      return .none
      
    case .presentPicker(let isPresented):
      state.isPickerPresented = isPresented
      return .none
      
    case .setImage(let image):
      state.image = image
      if let image = image {
        state.images.append(image)
      }
      return .none
      
    case .dismiss:
      return .none
    }
  }
)
