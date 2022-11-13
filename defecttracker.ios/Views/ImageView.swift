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
    
    init(uiImage : UIImage){
        self.uiImage = uiImage
    }
    
    private let orientationPublisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
    
    var body: some View {
        GeometryReader{ geo in
            ZoomableScrollView{
                let scale = geo.size.width < geo.size.height ? geo.size.width / self.uiImage.size.width : geo.size.height / self.uiImage.size.height
                let width = (self.uiImage.size.width*scale - geo.size.width - geo.safeAreaInsets.leading)/2
                let height = (self.uiImage.size.height*scale - geo.size.height - geo.safeAreaInsets.top)/2
                Image(uiImage: self.uiImage).scaleEffect(scale)
                    .frame(width: scale * self.uiImage.size.width, height: scale * self.uiImage.size.height)
                    .offset(CGSize(width : width, height: height))
            }
        }
    }
    
}

struct ImageView_Previews: PreviewProvider {
    static let image = UIImage.init(imageLiteralResourceName: "placeholder")
    static var previews: some View {
        ImageView(uiImage: image)
    }
}
