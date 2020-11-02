//
//  PresentationController.swift
//  HSBFilter
//
//  Created by Hasan Qasim on 2/11/20.
//

import Foundation
import UIKit

class PresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let theView = containerView else {
                return CGRect.zero
            }
            let rect = CGRect(x: 0, y: theView.bounds.height/1.33, width: theView.bounds.width, height: theView.bounds.height/4)
            return rect
        }
    }
}
