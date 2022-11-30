//
//  StaticPlanView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 24.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct StaticPlanView: View{
    
    var defects : Array<DefectData>
    
    let uiImage : UIImage
    
    let marker = UIImage(imageLiteralResourceName: "redarrow")
    
    init(uiImage : UIImage, defects: Array<DefectData>){
        self.uiImage = uiImage
        self.defects = defects
    }
    
    init(uiImage : UIImage, defect: DefectData){
        self.uiImage = uiImage
        self.defects=Array<DefectData>()
        self.defects.append(defect)
    }
    
    var body: some View {
        GeometryReader{ geo in
            ZStack(alignment: .topLeading){
                Image(uiImage: self.uiImage)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                ForEach(self.defects) { defect in
                    if defect.hasValidPosition{
                        Image(uiImage: self.marker)
                            .offset(self.getMarkerOffset(frameSize: geo.size, defect: defect))
                    }
                }
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
    }
    
    func getMarkerOffset(frameSize: CGSize, defect: DefectData) -> CGSize{
        let x : CGFloat = defect.position.width/10000 * frameSize.width - 8
        let y : CGFloat = defect.position.height/10000 * frameSize.height
        return CGSize(width: x, height: y)
    }
    
}

struct StaticPlanView_Previews: PreviewProvider {
    static let image = UIImage.init(imageLiteralResourceName: "placeholder")
    static var defect = DefectData()
    static var defects = [defect]
    static var previews: some View {
        GeometryReader{ geo in
            StaticPlanView(uiImage: image, defects: defects)
        }
    }
}
