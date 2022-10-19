//
//  ImageView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 21.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageView: View{
    
    let uiImage : UIImage
    @State var fill: Bool = false
    
    init(uiImage : UIImage){
        self.uiImage = uiImage
    }
    
    private let orientationPublisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
    
    var body: some View {
        return GeometryReader{ geo in
            ScrollView([.horizontal, .vertical]){
                Image(uiImage: self.uiImage).scaleEffect(self.getImageScale(frameSize: geo.size))
                    .frame(width: self.getFrameWidth(frameSize: geo.size), height: self.getFrameHeight(frameSize: geo.size))
                    .offset(self.getOffset(geo: geo))
            }.onTapGesture {
                DispatchQueue.main.async {
                    self.fill = !self.fill
                }
            }.onReceive(self.orientationPublisher) { _ in
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
    
    func getImageScale(frameSize : CGSize) -> CGFloat{
        if (frameSize.width >= frameSize.height && fill) || (frameSize.width < frameSize.height && !fill) {
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
    
    func getOffset(geo: GeometryProxy) -> CGSize{
        let scale = getImageScale(frameSize: geo.size)
        let width = (self.uiImage.size.width*scale - geo.size.width - geo.safeAreaInsets.leading)/2
        let height = (self.uiImage.size.height*scale - geo.size.height - geo.safeAreaInsets.top)/2
        return CGSize(width : width, height: height)
    }
    
}

struct ImageView_Previews: PreviewProvider {
    static let image = UIImage.init(imageLiteralResourceName: "placeholder")
    static var previews: some View {
        ImageView(uiImage: image)
    }
}


