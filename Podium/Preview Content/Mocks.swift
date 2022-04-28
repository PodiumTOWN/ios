//
//  ProfileMock.swift
//  ink
//
//  Created by Michael Jach on 29/03/2022.
//

struct Mocks {
  var profile = Profile(
    userAddress: "0x000",
    username: "jach"
  )
  var profileEmpty = Profile(
    userAddress: "0xd336f831a39527062f6980232982Bef1cd82Ec57",
    bio: "Hello"
  )
  var story = Story(
    index: 0,
    owner: "0xd336f831a39527062f6980232982Bef1cd82Ec57",
    text: "I’m such a bad interviewer because I constantly want to tell candidates that they’re doing a great job and to not worry about things. I’m honestly usually more nervous than they are.",
    images: ["QmcmThDY2g8cw9djjLSYjY56nBeRp3D7yr5uPiQMYAqdRA"]
  )
  var storyImages = Story(
    index: 0,
    owner: "0xd336f831a39527062f6980232982Bef1cd82Ec57",
    text: "I’m such a bad interviewer because I constantly want to tell candidates that they’re doing a great job and to not worry about things. I’m honestly usually more nervous than they are.",
    images: [
      "QmcmThDY2g8cw9djjLSYjY56nBeRp3D7yr5uPiQMYAqdRA",
      "QmcmThDY2g8cw9djjLSYjY56nBeRp3D7yr5uPiQMYAqdRx",
      "QmcmThDY2g8cw9djjLSYjY56nBeRp3D7yr5uPiQMYAqdax"
    ]
  )
  var storyPending = Story(
    index: 0,
    owner: "0xd336f831a39527062f6980232982Bef1cd82Ec57",
    text: "I’m such a bad interviewer because I constantly want to tell candidates that they’re doing a great job and to not worry about things. I’m honestly usually more nervous than they are.",
    transaction: Transaction(
      address: "0xd336f831a39527062f6980232982Bef1cd82Ec57",
      type: .addStory
    )
  )
  var storyShort = Story(
    index: 0,
    owner: "0xd336f831a39527062f6980232982Bef1cd82Ec57",
    text: "Hello boyz."
  )
  var transaction = Transaction(
    address: "0xd336f831a39527062f6980232982Bef1cd82Ec57",
    type: .addStory
  )
}
