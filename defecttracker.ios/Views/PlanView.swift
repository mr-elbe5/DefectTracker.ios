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
            ZoomableScrollView{
                let scale = getScale(geo: geo)
                let offset = getOffset(geo: geo, scale: scale)
                ZStack(alignment: .topLeading){
                    Image(uiImage: self.uiImage).scaleEffect(scale)
                        .frame(width: scale * self.uiImage.size.width, height: scale * self.uiImage.size.height)
                        .offset(CGSize(width : offset.width, height: offset.height))
                    ForEach(self.defects) { defect in
                        if defect.hasValidPosition{
                            Image(uiImage: self.marker)
                                .offset(getDefectOffset(defect: defect, scale: scale, offset: offset))
                        }
                    }
                }
            }
        }
    }
    
    func getScale(geo: GeometryProxy) -> CGFloat{
        let scale = geo.size.width < geo.size.height ? geo.size.width / self.uiImage.size.width : geo.size.height / self.uiImage.size.height
        print(scale)
        return scale
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
