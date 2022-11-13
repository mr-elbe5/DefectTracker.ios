//
//  TapOverlay.swift
//  defecttracker
//
//  Created by Michael Rönnau on 13.11.22.
//  Copyright © 2022 Michael Rönnau. All rights reserved.
//

import SwiftUI

struct TapOverlay: UIViewRepresentable
{
    let view = UIView()
    var tapCallback: (CGPoint) -> Void

    func makeCoordinator() -> TapOverlay.Coordinator
    {
        Coordinator(view: view, tapCallback: self.tapCallback)
    }

    func makeUIView(context: UIViewRepresentableContext<TapOverlay>) -> UIView
    {
        view.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(sender:))))
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TapOverlay>)
    {
    }

    class Coordinator
    {
        var view: UIView
        var tapCallback: (CGPoint) -> Void

        init(view: UIView, tapCallback: @escaping (CGPoint) -> Void)
        {
            self.view = view
            self.tapCallback = tapCallback
        }

        @objc func handleTap(sender: UITapGestureRecognizer)
        {
            self.tapCallback(sender.location(in: view))
        }
    }
}

