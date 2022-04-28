//
//  DetailReducer.swift
//  ink
//
//  Created by Michael Jach on 14/04/2022.
//

import ComposableArchitecture
import Combine
import UIKit

let detailReducer = Reducer<DetailState, DetailAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .viewEtherscan(let transaction):
      if let url = URL(string: "\(environment.etherscanUrl)/tx/\(transaction.address)") {
        UIApplication.shared.open(url)
      }
      return .none
    }
  }
)
