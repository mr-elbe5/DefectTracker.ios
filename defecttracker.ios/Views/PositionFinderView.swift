//
//  PositionFinderView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 03.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct PositionFinderView: View{
    
    @ObservedObject var defect : DefectData
    
    let uiImage : UIImage
    var imageRatio : CGFloat = 0.0
    
    let marker = UIImage(imageLiteralResourceName: "redarrow")
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var startLocation: CGPoint = .zero
    @State private var startTime: Date? = nil
    @State private var previousScaleIndex : Int = 0
    @State var scaleIndex : Int = 0
    
    init(defect: DefectData, uiImage: UIImage){
        self.defect = defect
        self.uiImage=uiImage
        self.imageRatio = uiImage.size.height / uiImage.size.width
    }
    
    var body: some View {
        GeometryReader{ geo in
            VStack(alignment: .leading){
                ZStack(alignment: .topLeading){
                    Image(uiImage: self.uiImage)
                        .resizable()
                        .frame(width: self.getFrameWidth(frameSize: geo.size), height: self.getFrameHeight(frameSize: geo.size), alignment: .topLeading)
                    Image(uiImage: self.marker)
                        .offset(self.getMarkerOffset(frameSize: geo.size))
                }.offset(x: self.currentPosition.width,y: self.currentPosition.height)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged(){ value in
                            if (self.startTime == nil){
                                self.startTime = value.time
                                self.startLocation = value.location
                            }
                            self.setCurrentPosition(frameSize: geo.size, translation: value.translation)
                    }
                    .onEnded { value in
                        self.setCurrentPosition(frameSize: geo.size, translation: value.translation)
                        if !(self.hasMoved(location: value.location)), let startTime = self.startTime {
                            let interval = value.time.timeIntervalSince(startTime)
                            if interval > 0.5 {
                                self.setMarkerInImage(frameSize: geo.size, location: value.location)
                            }
                        }
                        self.startTime = nil
                        self.newPosition = self.currentPosition
                    }).animation(.default, value: 0)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                .clipped().contentShape(Rectangle())
            Text("setMarkerHint").font(.footnote).underline().background(Color.white).foregroundColor(Color.red).padding(3)
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
    
    func getMarkerOffset(frameSize : CGSize) -> CGSize{
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
    
    private func getMarkerPosition(frameSize : CGSize) -> CGSize{
        let markerPos = CGSize(width: defect.position.width*frameSize.width/100 - 9, height: defect.position.height*frameSize.height/10000 - 1)
        return markerPos
    }
    
    private func setMarkerInImage(frameSize : CGSize, location: CGPoint){
        defect.position.width=(location.x - currentPosition.width)*10000/getFrameWidth(frameSize: frameSize)
        defect.position.height=(location.y - currentPosition.height)*10000/getFrameHeight(frameSize: frameSize)
    }

    private func hasMoved(location: CGPoint) -> Bool{
        return Int(abs(self.startLocation.x - location.x)) > 5 || Int(abs(self.startLocation.y - location.y)) > 5
    }
    
}

struct PositionFinderView_Previews: PreviewProvider {
    @State static var defect = DefectData()
    static let uiImage = UIImage(imageLiteralResourceName: "placeholder")
    
    static var previews: some View {
        GeometryReader{ geo in
            ScrollView(.vertical){
                VStack(alignment: .leading){
                    Text("test")
                    PositionFinderView(defect: self.defect, uiImage: self.uiImage)
                    Text("test")
                }
            }
        }.navigationBarTitle("home", displayMode: .inline)
    }
}
