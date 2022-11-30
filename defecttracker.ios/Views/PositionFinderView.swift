//
//  PositionFinderView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 03.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct PositionFinderView: View, TouchDelegate{
    
    @ObservedObject var defect : DefectData
    
    let uiImage : UIImage
    
    let marker = UIImage(imageLiteralResourceName: "redarrow")
    
    init(defect: DefectData, uiImage: UIImage){
        self.defect = defect
        self.uiImage=uiImage
    }
    
    var body: some View {
        Text("setMarkerHint").font(.footnote).underline().background(Color.white).foregroundColor(Color.red).padding(3)
        DefectImageScrollView(image: uiImage, touchDelegate: self, defect: defect)
    }
    
    func touched(at relativePosition: CGSize) {
        defect.position = CGSize(width: relativePosition.width*10000, height: relativePosition.height*10000)
    }
    
}

struct DefectImageScrollView : UIViewRepresentable, TouchDelegate{
    
    var image: UIImage
    var touchDelegate: TouchDelegate? = nil
    
    @ObservedObject var defect: DefectData
    
    func makeUIView(context: Context) -> UIMarkedImageScrollView {
        let scrollView = UIMarkedImageScrollView(image: image)
        scrollView.relativeMarkerPosition = CGSize(width: defect.position.width/10000, height: defect.position.height/10000)
        scrollView.touchDelegate = self
        return scrollView
    }

    func updateUIView(_ view: UIMarkedImageScrollView, context: Context) {
        view.updateMarkerPosition()
    }
    
    func touched(at relativePosition: CGSize) {
        touchDelegate?.touched(at: relativePosition)
        
    }
    
}

class UIMarkedImageScrollView: UIImageScrollView{
    
    var relativeMarkerPosition : CGSize = .zero
    var marker = UIImageView(image: UIImage(imageLiteralResourceName: "redarrow"))
    var markerFrame : CGRect = .zero
    
    override func setup(){
        super.setup()
        addSubview(marker)
        markerFrame = CGRect(x: -marker.frame.width/2, y: 0, width: marker.frame.width, height: marker.frame.height)
    }
    
    override func touched(pnt: CGPoint){
        setRelativeMarkerPosition(pnt: pnt)
        touchDelegate?.touched(at: relativeMarkerPosition)
        updateMarkerPosition()
    }
    
    func setRelativeMarkerPosition(pnt: CGPoint){
        relativeMarkerPosition = CGSize(width: pnt.x/image.size.width, height: pnt.y/image.size.height)
    }
    
    func updateMarkerPosition(){
        marker.frame = markerFrame.offsetBy(dx: relativeMarkerPosition.width*contentSize.width, dy: relativeMarkerPosition.height*contentSize.height)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateMarkerPosition()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateMarkerPosition()
    }
    
}

