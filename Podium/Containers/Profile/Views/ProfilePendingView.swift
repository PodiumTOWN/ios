//
//  ProfilePendingView.swift
//  Podium
//
//  Created by Michael Jach on 19/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfilePendingView: View {
  let store: Store<ProfileState, ProfileAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        if viewStore.isLoadingPending {
          VStack {
            Spacer()
            ProgressView()
            Spacer()
          }
        } else if viewStore.pendingTransactions.count > 0 {
          ScrollView {
            VStack {
              ForEach(viewStore.pendingTransactions) { transaction in
                VStack {
                  Menu {
                    Button {
                      viewStore.send(.viewEtherscan(transaction: transaction))
                    } label: {
                      HStack(spacing: 4) {
                        Image("eth")
                          .resizable()
                          .frame(width: 22, height: 22, alignment: .center)
                        
                        Text("View on Polygonscan")
                      }
                      .padding()
                    }
                  } label: {
                    HStack {
                      Text(transaction.type.rawValue)
                        .fontWeight(.medium)
                      
                      Spacer()
                      
                      HStack {
                        Circle()
                          .fill(Color.orange)
                          .frame(width: 6, height: 6, alignment: .center)
                        
                        switch(transaction.status) {
                        case "-1":
                          Text("Pending")
                          
                        case "0x0":
                          Text("Failed")
                          
                        default:
                          Text("Completed")
                        }
                      }
                    }
                  }
                  .padding()
                }
                .background(Color("ColorBackgroundSecondary"))
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .padding(.horizontal)
              }
            }
          }
        } else {
          VStack {
            Spacer()
            Text("No pending transactions.")
              .fontWeight(.medium)
              .foregroundColor(.gray)
            Spacer()
          }
        }
      }
      .onAppear {
        viewStore.send(.getPendingTransactions)
      }
    }
  }
}
