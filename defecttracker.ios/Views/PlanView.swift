//
//  PlanView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 18.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct PlanView: View{
    
    var defects : Array<DefectData>
    
    let uiImage : UIImage
    var imageRatio : CGFloat = 0.0
    
    let marker = UIImage(imageLiteralResourceName: "redarrow")
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var startLocation: CGPoint? = nil
    
    init(uiImage : UIImage, defects: Array<DefectData>){
        self.uiImage = uiImage
        self.defects = defects
        self.imageRatio = uiImage.size.height / uiImage.size.width
        
    }
    
    init(uiImage : UIImage, defect: DefectData){
        self.uiImage = uiImage
        self.defects=Array<DefectData>()
        self.defects.append(defect)
        self.imageRatio = uiImage.size.height / uiImage.size.width
    }
    
    var body: some View {
        GeometryReader{ geo in
            VStack(alignment: .leading){
                ZStack(alignment: .topLeading){
                    Image(uiImage: self.uiImage)
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: self.getFrameWidth(frameSize: geo.size), height: self.getFrameHeight(frameSize: geo.size), alignment: .topLeading)
                    ForEach(self.defects) { defect in
                        Image(uiImage: self.marker)
                            .offset(self.getMarkerOffset(frameSize: geo.size, defect: defect))
                    }
                }.offset(x: self.currentPosition.width,y: self.currentPosition.height)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged(){ value in
                            if (self.startLocation == nil){
                                self.startLocation = value.location
                            }
                            self.setCurrentPosition(frameSize: geo.size, translation: value.translation)
                    }
                    .onEnded { value in
                        self.setCurrentPosition(frameSize: geo.size, translation: value.translation)
                        self.startLocation = nil
                        self.newPosition = self.currentPosition
                    }).animation(.default)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                .clipped().contentShape(Rectangle())
        }
    }
    
    func getImageScale(frameSize : CGSize) -> CGFloat{
        if frameSize.width >= frameSize.height {
            return frameSize.width / self.uiImage.size.width
        }
        else {
            return frameSize.height / self.uiImage.size.height
        }
    }
    
    func getFrameWidth(frameSize : CGSize) -> CGFloat{
        return getImageScale(frameSize : frameSize) * self.uiImage.size.width
    }
    
    func getFrameHeight(frameSize : CGSize) -> CGFloat{
        return getImageScale(frameSize : frameSize) * self.uiImage.size.height
    }
    
    func getMarkerOffset(frameSize: CGSize, defect: DefectData) -> CGSize{
        let x : CGFloat = defect.position.width/10000 * getFrameWidth(frameSize: frameSize) - 8
        let y : CGFloat = defect.position.height/10000 * getFrameHeight(frameSize: frameSize)
        return CGSize(width: x, height: y)
    }
    
    func getScrollLimit(frameSize: CGSize) -> CGSize{
        return CGSize(width: frameSize.width - getFrameWidth(frameSize: frameSize),height: frameSize.height - getFrameHeight(frameSize: frameSize))
    }
    
    func updatePosition(frameSize: CGSize){
        let limit = getScrollLimit(frameSize: frameSize)
        let width = max(min(0,(currentPosition.width - frameSize.width/2) + frameSize.width/2),limit.width)
        let height = max(min(0,(currentPosition.height - frameSize.height/2) + frameSize.height/2),limit.height)
        self.currentPosition = CGSize(width: width, height: height)
        self.newPosition = CGSize(width: width, height: height)
    }

    private func setCurrentPosition(frameSize: CGSize, translation: CGSize){
        let limit = getScrollLimit(frameSize: frameSize)
        let width = max(min(0,translation.width + self.newPosition.width),limit.width)
        let height = max(min(0,translation.height + self.newPosition.height),limit.height)
        self.currentPosition = CGSize(width: width, height: height)
    }
    
}

struct PlanView_Previews: PreviewProvider {
    static let image = UIImage.init(imageLiteralResourceName: "placeholder")
    static var defect = DefectData()
    static var defects = [defect]
    static var previews: some View {
        GeometryReader{ geo in
            PlanView(uiImage: image, defects: defects)
        }
    }
}
