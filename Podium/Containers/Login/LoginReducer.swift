//
//  LoginReducer.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import ComposableArchitecture
import Combine
import UIKit
import WalletCore

let loginReducer = Reducer<LoginState, LoginAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .viewTerms:
      DispatchQueue.main.asyncAfter(deadline: .now()) {
        if let url = URL(string: "https://podium.town/tos"), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      }
      return .none
      
    case .setMnemonic(let mnemonic):
      state.mnemonic = mnemonic
      return .none
      
    case .connectMnemonic:
      let wallet = HDWallet(mnemonic: state.mnemonic, passphrase: "")
      
      return Future<(String, Data?), AppError> { promise in
        if let publicKey = wallet?.getAddressForCoin(coin: .ethereum) {
          promise(.success((publicKey, wallet?.getKeyForCoin(coin: .ethereum).data)))
        } else {
          promise(.failure(.general))
        }
      }
      .receive(on: DispatchQueue.main)
      .catchToEffect()
      .map(LoginAction.didConnect)
      
    case .connect:
      return Future<(String, Data?), AppError> { promise in
        environment.walletConnect.reconnectIfNeeded(
          bridgeUrl: environment.bridgeUrl
        )
        environment.walletConnect.setOnConnect { session in
          if let publicKey = session.walletInfo?.accounts.first {
            promise(.success((publicKey, nil)))
          }
        }
        let connectionUrl = environment.walletConnect.connect(
          bridgeUrl: environment.bridgeUrl,
          chainId: environment.chainId
        )
        let deepLinkUrl = "\(connectionUrl)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          if let url = URL(string: deepLinkUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
        }
      }
      .receive(on: DispatchQueue.main)
      .catchToEffect()
      .map(LoginAction.didConnect)
      
    case .didConnect(.success((let publicKey, let privateKey))):
      return Effect(value: .getProfile(publicKey: publicKey, privateKey: privateKey))
      
    case .didConnect(.failure(let error)):
      state.bannerData = BannerData(title: "Error", detail: error.localizedDescription, type: .error)
      return .none
      
    case .getProfile(let publicKey, let privateKey):
      return Future<Profile, AppError> { promise in
        environment.rpcApi.getProfile(
          environment: environment,
          publicKey: publicKey,
          privateKey: privateKey) { profile, error in
            if let profile = profile {
              var mutatedProfile = profile
              mutatedProfile.privateKey = privateKey
              promise(.success(mutatedProfile))
            } else if let error = error {
              promise(.failure(error))
            }
          }
      }
      .catchToEffect()
      .map(LoginAction.didGetProfile)
      
    case .didGetProfile(.success(let profile)):
      return .none
      
    case .didGetProfile(.failure(let error)):
      state.bannerData = BannerData(
        title: "Error",
        detail: error.description,
        type: .error
      )
      return .none
      
    case .presentRawLogin(let isPresented):
      state.isRawLoginPresented = isPresented
      return .none
      
    case .dismissBanner:
      state.bannerData = nil
      return .none
    }
  }
)

