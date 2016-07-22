//
//  UISlider.swift
//  UserInterface
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - Slider

extension UISlider
{
    /// The current drawing rectangle for the slider’s track in the sliders coordinate-space, given the current bounds of the slider
    public var currentTrackRect : CGRect
    {
        return trackRectForBounds(bounds)
    }
    
    /// The current drawing rectangle for the thumb image in the sliders coordinate-space, given the current bounds, track rectangle, and value of the slider
    public var currentThumbRect : CGRect
    {
        return thumbRectForBounds(bounds, trackRect:trackRectForBounds(bounds), value:value)
    }

    /// Centers `view` on the thumb image, given the current bounds and value of the slider
    public func centerViewOnThumb(view: UIView)
    {
        view.center = convertPoint(currentThumbRect.center, toView: view.superview)
    }

    /// Sets `view`s frame to match the drawing rectangle of the thumb image, given the current bounds and value of the slider
    public func frameViewOnThumb(view: UIView)
    {
        view.frame = convertRect(currentThumbRect, toView: view.superview)
    }
    
    var currentThumbImageMidX : CGFloat
    {
        let currentThumbSize = currentThumbRect.size
        
        let minX = frame.minX
        
        let maxX = frame.maxX - currentThumbSize.width
        
        let t = CGFloat((value - minimumValue)/(maximumValue - minimumValue))
        
        let x = minX * (1 - t) + maxX * t
        
        return x + currentThumbSize.width / 2
    }
}
