//
//  UIView+Super.swift
//  UserInterface
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

public extension UIView
{
    /// Adds `self` to a new superview. I `optionalSuperView` parameter equal to current superview, nothing happens, if it is nil `self` is removed from any current superview
    func addToSuperView(optionalSuperView: UIView?)
    {
        guard superview != optionalSuperView else { return }
        
        removeFromSuperview()
        
        optionalSuperView?.addSubview(self)
    }
}