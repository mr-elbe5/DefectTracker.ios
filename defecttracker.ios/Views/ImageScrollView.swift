//
//  ImageScrollView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 29.11.22.
//  Copyright © 2022 Michael Rönnau. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import SwiftUI
import CoreLocation

struct ImageScrollView : UIViewRepresentable, TouchDelegate{
    
    var image: UIImage
    func makeUIView(context: Context) -> UIImageScrollView {
        let scrollView = UIImageScrollView(image: image)
        scrollView.touchDelegate = self
        return scrollView
    }

    func updateUIView(_ view: UIImageScrollView, context: Context) {
    }
    
    func touched(at point: CGPoint) {
        print("touch received")
    }
    
}

class UIImageScrollView: UIScrollView, UIScrollViewDelegate{
    
    var image: UIImage? = nil
    var touchDelegate: TouchDelegate? = nil
    
    init(image: UIImage) {
        self.image = image
        super.init(frame: .zero)
        isScrollEnabled = true
        scrollsToTop = false
        isDirectionalLockEnabled = false
        isPagingEnabled = false
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = true
        bounces = false
        bouncesZoom = false
        maximumZoomScale = 2.0
        minimumZoomScale = 0.5
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first{
            let winLen = min(window.bounds.width, window.bounds.height)
            let imgLen = max(image.size.width, image.size.height)
            minimumZoomScale = winLen/imgLen
        }
        addSubview(UIImageView(image: image))
        contentSize = image.size
        delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (onTouch))
        addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTouch(_ sender: UIGestureRecognizer){
        if let view = subviews.first{
            let point = sender.location(in: view)
            touchDelegate?.touched(at: point)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        subviews.first
    }
    
}
