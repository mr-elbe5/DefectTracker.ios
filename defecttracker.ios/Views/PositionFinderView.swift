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
        Text("setMarkerHint").font(.footnote).underline().background(Color.white).foregroundColor(Color.red).padding(3)
        GeometryReader{ geo in
            ZoomableScrollView{
                let scale = getScale(geo: geo)
                let offset = getOffset(geo: geo, scale: scale)
                let width = scale * uiImage.size.width
                let height = scale * uiImage.size.height
                ZStack(alignment: .topLeading){
                    Image(uiImage: self.uiImage).scaleEffect(scale)
                        .frame(width: width, height: height)
                        .offset(offset)
                        .overlay(
                            TapOverlay { point in
                                //print(point)
                                //print("image size: \(uiImage.size)")
                                //print("offset: \(offset)")
                                defect.position.width = (point.x - offset.width)*10000/width
                                defect.position.height = (point.y - offset.height)*10000/height
                        })
                    if defect.hasValidPosition{
                        Image(uiImage: self.marker)
                            .offset(getDefectOffset(defect: defect, scale: scale, offset: offset))
                    }
                }
            }
        }
    }
    
    func getScale(geo: GeometryProxy) -> CGFloat{
        geo.size.width < geo.size.height ? geo.size.width / self.uiImage.size.width : geo.size.height / self.uiImage.size.height
    }
    
    func getOffset(geo: GeometryProxy, scale: CGFloat) -> CGSize{
        CGSize(width: (self.uiImage.size.width*scale - geo.size.width - geo.safeAreaInsets.leading)/2,
               height: (self.uiImage.size.height*scale - geo.size.height - geo.safeAreaInsets.top)/2)
    }
    
    func getDefectOffset(defect: DefectData, scale: CGFloat, offset: CGSize) -> CGSize{
        CGSize(width: defect.position.width/10000 * scale * self.uiImage.size.width - 8 + offset.width,
               height: defect.position.height/10000 * scale * self.uiImage.size.height + offset.height)
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

