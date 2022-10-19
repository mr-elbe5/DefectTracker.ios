//
//  ImageBlock.swift
//  defecttracker
//
//  Created by Michael Rönnau on 17.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageBlock: View{
    
    var images: Array<ImageData> = Array()
    var numRows: Int = 0
    
    init(images: Array<ImageData>){
        self.images=images
        numRows = (images.count / 3) + 1
    }
    
    var body: some View{
        GridStack(rows: self.numRows, columns: 3){ row, col in
            GridImage(image: (3*row+col < self.images.count) ? self.images[3*row+col] : nil, row: row, col: col)
        }
    }
    
}
    
struct GridImage: View{
    
    var image: ImageData? = nil
    var uiImage: UIImage? = nil
    var row: Int = 0
    var col: Int = 0
    
    init(image: ImageData?, row: Int, col: Int){
        self.image = image
        if image != nil{
            self.uiImage = ImageController.shared.getImage(image: self.image!)
        }
        self.row = row
        self.col = col
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if self.image != nil && self.uiImage != nil {
                NavigationLink(destination: ImageView(uiImage: self.uiImage!)){
                    Image(uiImage: self.uiImage!).resizable().renderingMode(.original).scaledToFit().cornerRadius(5)
                }
            }
            else {
                Rectangle().fill(Color.clear).frame(maxHeight: 10)
            }
        }
    }
}

struct FormImageBlock: View{
    
    var images: Array<ImageData> = Array()
    var numRows: Int = 0
    
    init(images: Array<ImageData>){
        self.images=images
        numRows = (images.count / 3) + 1
    }
    
    var body: some View{
        GridStack(rows: self.numRows, columns: 3){ row, col in
            FormGridImage(image: (3*row+col < self.images.count) ? self.images[3*row+col] : nil, row: row, col: col)
        }
    }
    
}
    
struct FormGridImage: View{
    
    var image: ImageData? = nil
    var hasImage : Bool = false
    var row: Int = 0
    var col: Int = 0
    
    init(image: ImageData?, row: Int, col: Int){
        self.image = image
        self.hasImage = image != nil
        self.row = row
        self.col = col
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if self.hasImage {
                Image(uiImage: ImageController.shared.getImage(image: self.image!)).resizable().renderingMode(.original).scaledToFit().cornerRadius(5)
            }
            else {
                Rectangle().fill(Color.clear).frame(maxHeight: 10)
            }
        }
    }
}

