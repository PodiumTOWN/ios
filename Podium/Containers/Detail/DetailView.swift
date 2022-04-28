//
//  DetailView.swift
//  ink
//
//  Created by Michael Jach on 14/04/2022.
//

import SwiftUI
import ComposableArchitecture

struct DetailView: View {
  let store: Store<DetailState, DetailAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView {
        PostTextView(
          story: viewStore.story) { image in
            
          } onProfileTap: { profile in
            
          }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            if let transaction = viewStore.story.transaction {
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
            }
          } label: {
            Image("info")
              .resizable()
              .frame(width: 24, height: 24, alignment: .center)
          }
        }
      }
    }
  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
#if DEBUG
    NavigationView {
      DetailView(store: Store(
        initialState: DetailState(
          story: Mocks().story
        ),
        reducer: detailReducer,
        environment: AppEnvironment()
      ))
    }
#endif
  }
}
