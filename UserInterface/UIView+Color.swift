//
//  UIView+Color.swift
//  UserInterface
//
//  Created by Christian Otkjær on 29/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import QuartzCore

// MARK: - Color of Point
/* Wonky - see Colour project
extension UIView
{
    public func colorOfPoint(point: CGPoint) -> UIColor
    {
        var pixel:[CUnsignedChar] = [0,0,0,0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        guard let context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue) else { print("Could not create context"); return UIColor.clearColor() }
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        
        layer.renderInContext(context)
        
        let red:CGFloat = CGFloat(pixel[0])/255
        let green:CGFloat = CGFloat(pixel[1])/255
        let blue:CGFloat = CGFloat(pixel[2])/255
        let alpha:CGFloat = CGFloat(pixel[3])/255
        
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        
        return color
    }
}
 */