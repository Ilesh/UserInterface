//
//  UIBezierPath.swift
//  Silverback
//
//  Created by Christian Otkjær on 12/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - Transform

public extension UIBezierPath
{
    func translate(tx: CGFloat, ty: CGFloat)
    {
        apply(CGAffineTransform(translationX: tx, y: ty))
    }
    
    func translated(tx: CGFloat, ty: CGFloat) -> UIBezierPath
    {
        let path = self
        
        path.translate(tx: tx, ty: ty)
        
        return path
    }
    
    func translate(_ v: CGVector)
    {
        translate(tx: v.dx, ty: v.dy)
    }
    
    func translated(_ v: CGVector) -> UIBezierPath
    {
        return translated(tx: v.dx, ty: v.dy)
    }
    
    func rotate(_ angle: CGFloat)
    {
        apply(CGAffineTransform(rotationAngle: angle))
    }
    
    func rotated(_ angle: CGFloat) -> UIBezierPath
    {
        let path = self
        
        path.rotate(angle)
        
        return path
    }
    
    func scale(sx: CGFloat, sy: CGFloat)
    {
        apply(CGAffineTransform(scaleX: sx, y: sy))
    }
    
    func scaled(sx: CGFloat, sy: CGFloat) -> UIBezierPath
    {
        let path = self
        
        path.scale(sx: sx, sy: sy)
        
        return path
    }
}

