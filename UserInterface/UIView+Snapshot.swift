//
//  UIView+Snapshot.swift
//  UserInterface
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - Snapshot

extension UIView
{
    public func snapshot() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext()
        {
            layer.renderInContext(context)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
