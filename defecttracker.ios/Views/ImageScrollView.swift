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

protocol TouchDelegate{
    func touched(at relativePosition: CGSize)
}

struct ImageScrollView : UIViewRepresentable, TouchDelegate{
    
    var image: UIImage
    var touchDelegate: TouchDelegate? = nil
    
    func makeUIView(context: Context) -> UIImageScrollView {
        let scrollView = UIImageScrollView(image: image)
        scrollView.touchDelegate = self
        return scrollView
    }

    func updateUIView(_ view: UIImageScrollView, context: Context) {
    }
    
    func touched(at relativePosition: CGSize) {
        touchDelegate?.touched(at: relativePosition)
    }
    
}

class UIImageScrollView: UIScrollView, UIScrollViewDelegate{
    
    var image: UIImage
    var imageView: UIImageView
    
    var touchDelegate: TouchDelegate? = nil
    
    init(image: UIImage) {
        self.image = image
        imageView = UIImageView(image: image)
        super.init(frame: .zero)
        setup()
    }
    
    func setup(){
        isScrollEnabled = true
        scrollsToTop = false
        isDirectionalLockEnabled = false
        isPagingEnabled = false
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = true
        bounces = false
        bouncesZoom = false
        maximumZoomScale = 2.0
        minimumZoomScale = 1.0
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first{
            let winLen = min(window.bounds.width, window.bounds.height)
            let imgLen = max(image.size.width, image.size.height)
            minimumZoomScale = winLen/imgLen
        }
        addSubview(imageView)
        contentSize = image.size
        delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (onTouch))
        addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTouch(_ sender: UIGestureRecognizer){
        let point = sender.location(in: imageView)
        touched(pnt: point)
    }
    
    func touched(pnt: CGPoint){
        touchDelegate?.touched(at: CGSize(width: pnt.x/image.size.width, height: pnt.y/image.size.height))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
}

