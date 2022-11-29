//
//  ZoomImageView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 13.11.22.
//  Copyright © 2022 Michael Rönnau. All rights reserved.
//

import SwiftUI

struct ZoomableScrollView<Content: View>: UIViewRepresentable, TouchDelegate {
    
    private var content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  func makeUIView(context: Context) -> TouchScrollView {
    let scrollView = TouchScrollView()
    scrollView.delegate = context.coordinator  // for viewForZooming(in:)
      scrollView.touchDelegate = self
    scrollView.maximumZoomScale = 10
    scrollView.minimumZoomScale = 1
    scrollView.bouncesZoom = true

    let hostedView = context.coordinator.hostingController.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    scrollView.addSubview(hostedView)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: TouchScrollView, context: Context) {
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }
    
    func touched(at point: CGPoint) {
        print(point)
    }

  class Coordinator: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return hostingController.view
    }
  }
}

protocol TouchDelegate{
    func touched(at point: CGPoint)
}

class TouchScrollView: UIScrollView, UIScrollViewDelegate{
    
    var touchDelegate: TouchDelegate? = nil
    
    func setup(){
        delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchDelegate = touchDelegate, let hostedView = subviews.first, let touch = touches.first{
            var pos = touch.location(in: hostedView)
            print("pos= \(pos)")
            print("width= \(bounds.width)")
            print("height= \(bounds.height)")
            print("contentOffset= \(contentOffset)")
            print("contentSize= \(contentSize)")
            var scale = contentSize.width/bounds.width
            print("scale= \(scale)")
            pos = CGPoint(x: pos.x*scale, y: pos.y*scale)
            print("pos= \(pos)")
            touchDelegate.touched(at: pos)
        }
        super.touchesBegan(touches, with: event)
    }
    
}
