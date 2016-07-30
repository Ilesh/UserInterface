//
//  UIView+Size.swift
//  UserInterface
//
//  Created by Christian Otkjær on 30/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

extension UIView
{
    public func resizeToFitSubviews()
    {
        guard let rect = subviews.first?.frame else { frame.size = CGSizeZero; return }
        
        let subviewsRect = subviews.reduce(rect) { $0.union($1.frame) }
        
        let offset = subviewsRect.origin
        
        subviews.forEach { $0.frame.offsetInPlace(dx: -offset.x, dy: -offset.y) }
        
        frame.size = subviewsRect.size
        
        superview?.setNeedsLayout()
    }
}
