//
//  LoadingStrokeView.swift
//  ink
//
//  Created by Michael Jach on 08/04/2022.
//

import SwiftUI

struct SpinnerCircle: View {
  var start: CGFloat
  var end: CGFloat
  var rotation: Angle
  var color: Color
  
  var body: some View {
    Circle()
      .trim(from: start, to: end)
      .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
      .fill(color)
      .rotationEffect(rotation)
  }
}
