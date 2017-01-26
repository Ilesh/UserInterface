//
//  UIEdgeInsets.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - insets

extension UIEdgeInsets
{
    /// - parameter rect: the rectangle to adjust
    /// - returns : A rectangle that is adjusted by these `UIEdgeInsets`.
    public func adjust(_ rect: CGRect) -> CGRect
    {
        return UIEdgeInsetsInsetRect(rect, self)
    }
    
    /// - parameter rect: the rectangle to apply these insets on
    /// - returns : A rectangle that is adjusted by these `UIEdgeInsets`.
    public func inset(_ rect: CGRect) -> CGRect
    {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}

