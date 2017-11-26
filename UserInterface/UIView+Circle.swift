//
//  UIView+Circle.swift
//  UserInterface
//
//  Created by Christian Otkjær on 24/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import Graphics
// MARK: - Circle

extension UIView
{
    public func addOvalMask(in frame: CGRect? = nil)
    {
        let frame = frame ?? bounds
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = frame
        maskLayer.path = UIBezierPath(ovalIn: frame).cgPath
        layer.mask = maskLayer
    }
    
    public func addCircleMask()
    {
        let frame = bounds.squared(horizontal: .middle, vertical: .middle, inner: true)
        
        addOvalMask(in: frame)
    }
    
}
