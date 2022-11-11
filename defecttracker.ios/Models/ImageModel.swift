//
//  ImageModel.swift
//  test.ios
//
//  Created by Michael Rönnau on 05.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class ImageModel: ObservableObject {
    @Published var image = UIImage(imageLiteralResourceName: "placeholder")
    
    func load(data: ImageData) {
        Task{
            if let img = await ImageController().loadImage(image: data){
                self.image = img
            }
        }
    }

}
