//
//  UIView.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit


//MARK: - Corner Radius

extension UIView
{
    @IBInspectable
    public var cornerRadius : CGFloat
        {
        
        get { return layer.cornerRadius }
        set { layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100) }
        
    }
}

//MARK: - Border

public extension UIView
{
    @discardableResult
    func roundCorners(_ optionalRadius: CGFloat? = nil) -> CGFloat
    {
        var radius = min(bounds.midX, bounds.midY)
        
        if let requestedRadius = optionalRadius
        {
            radius = min(requestedRadius, radius)
        }
        
        layer.cornerRadius = round(radius * 100) / 100
        
        return layer.cornerRadius
    }
    
    @IBInspectable
    var borderSize : CGFloat
        {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    @IBInspectable
    var borderColor :  UIColor?
        {
        set
        {
            if let color = newValue
            {
                layer.borderColor = color.cgColor
            }
            else
            {
                layer.borderColor = nil
            }
        }
        
        get
        {
            if let cgColor = layer.borderColor
            {
                return UIColor(cgColor: cgColor)
            }
            else
            {
                return nil
            }
        }
    }
}

//MARK: - Radius

public extension UIView
{
    var radius : CGFloat { return min(bounds.width, bounds.height) / 2 }
}

//MARK: - Scrolling

public extension UIView
{
    func anySubViewScrolling() -> Bool
    {
        for scrollView in subviews.cast(UIScrollView.self)
        {
            if scrollView.isDragging || scrollView.isDecelerating
            {
                return true
            }
        }
        
        for subview in subviews
        {
            if subview.anySubViewScrolling()
            {
                return true
            }
        }
        
        return false
    }
}


//MARK: - First Responder

public extension UIView
{
    func findFirstResponder() -> UIView?
    {
        if isFirstResponder
        {
            return self
        }
        
        for subview in subviews
        {
            if let fr = subview.findFirstResponder()
            {
                return fr
            }
        }
        
        return nil
    }
}

// MARK: - Frames

public extension UIView
{
    func frameInView(_ view: UIView) -> CGRect
    {
        return bounds.convert(fromView: self, toView: view)
    }
}


