//
//  View.swift
//  defecttracker
//
//  Created by Michael Rönnau on 22.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

extension View{
    @inlinable public func fullSize() -> some View{
        return self.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity, alignment: .topLeading).padding()
    }
    
    @inlinable public func withMultilineStyle() -> some View{
        return self.overlay(RoundedRectangle(cornerRadius: 4)
        .stroke(Color.gray, lineWidth: 0.4))
    }
    
    @inlinable public func withTextFieldStyle() -> some View{
        return self.textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
    }
}

extension View{
    func dismissKeyboard(){
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow?.endEditing(true)
    }
}

