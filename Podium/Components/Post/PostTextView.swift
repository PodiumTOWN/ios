//
//  PostTextView.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

import SwiftUI

struct PostTextView: View {
  var story: Story
  var onImageTap: (_ image: String) -> Void
  var onProfileTap: (_ profile: Profile?) -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top, spacing: 8) {
        VStack {
          if let profile = story.profile,
             let avatar = profile.avatar,
             avatar != "" {
            AsyncImage(
              url: URL(string: "https://ipfs.infura.io/ipfs/\(avatar)")!) {
                ProgressView()
              }
              .scaledToFill()
              .frame(width: 44, height: 44, alignment: .center)
              .clipShape(Circle())
          } else {
            Image("dummy-avatar")
              .resizable()
              .scaledToFill()
              .frame(width: 44, height: 44, alignment: .center)
              .clipShape(Circle())
          }
        }
        .padding(4)
        .onTapGesture {
          onProfileTap(story.profile)
        }
        
        
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            if let profile = story.profile, let username = profile.username, username != "" {
              Text("@\(username)")
                .fontWeight(.semibold)
                .lineLimit(1)
            } else {
              Text(story.owner)
                .fontWeight(.semibold)
                .lineLimit(1)
            }
            
            Spacer()
            
            if story.transaction?.status == "-1" {
              HStack(spacing: 4) {
                Circle()
                  .fill(.orange)
                  .frame(width: 6, height: 6, alignment: .center)
                
                Text("Pending")
                  .fontWeight(.medium)
                  .font(.caption)
                  .foregroundColor(Color("ColorText"))
              }
            } else {
              Text("2 hours ago")
                .fontWeight(.medium)
                .font(.caption)
                .foregroundColor(Color("ColorText"))
            }
          }
          
          VStack(alignment: .leading, spacing: 0) {
            Text(story.text ?? "-")
              .multilineTextAlignment(.leading)
            
            VStack(spacing: 0) {
              if let images = story.images, images.count > 0 {
                LazyVGrid(columns: Array.init(repeating: GridItem(.flexible(minimum: 50)), count: images.count > 1 ? 2 : images.count), spacing: 8) {
                  ForEach(images, id: \.self) { image in
                    if let imageUrl = URL(string: "https://ipfs.infura.io/ipfs/\(image)") {
                      Color.clear
                        .aspectRatio(1, contentMode: .fit)
                        .background(
                          AsyncImage(
                            url: imageUrl) {
                              VStack {
                                Spacer()
                                HStack {
                                  Spacer()
                                  ProgressView()
                                  Spacer()
                                }
                                Spacer()
                              }
                            }
                            .scaledToFill()
                        )
                        .background(Color("ColorBackgroundSecondary"))
                        .clipped()
                        .contentShape(Rectangle())
                        .clipShape(
                          RoundedRectangle(cornerRadius: 13)
                        )
                        .onTapGesture {
                          onImageTap(image)
                        }
                    }
                  }
                }
                .padding(.top, 12)
              }
            }
          }
        }
        .padding(.top, 2)
      }
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 8)
    .foregroundColor(Color("ColorText"))
    .background(
      story.transaction?.status == "-1" ? Color("ColorBackgroundSecondary") : Color("ColorBackground")
    )
  }
}

struct PostTextView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
#if DEBUG
      Button {
        
      } label: {
        PostTextView(
          story: Mocks().story, onImageTap: { image in
            
          }, onProfileTap: { _ in
            
          }
        )
      }
      
      Button {
        
      } label: {
        PostTextView(
          story: Mocks().storyImages, onImageTap: { image in
            
          }, onProfileTap: { _ in
            
          }
        )
      }
      
      Button {
        
      } label: {
        PostTextView(
          story: Mocks().storyPending, onImageTap: { image in
            
          }, onProfileTap: { _ in
            
          }
        )
      }
      Button {
        
      } label: {
        PostTextView(
          story: Mocks().storyPending, onImageTap: { image in
            
          }, onProfileTap: { _ in
            
          }
        )
      }
      .preferredColorScheme(.dark)
      
      Button {
        
      } label: {
        PostTextView(
          story: Mocks().storyShort, onImageTap: { image in
            
          }, onProfileTap: { _ in}
        )
      }
#endif
    }
  }
}
