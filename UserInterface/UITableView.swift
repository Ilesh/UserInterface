//
//  UITableView.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit
import Collections

extension UITableView
{
    public func refreshCellHeights()
    {
        beginUpdates()
        endUpdates()
    }
    
    public func moveScrollIndicatorToLeft(_ left: Bool = true, offset: CGFloat = 6)
    {
        let indicatorThickness = CGFloat(2)
        
        let inset = bounds.width - (indicatorThickness + offset)
        
        if left
        {
           scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)
        }
        else
        {
            scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -offset)
        }
    }
}
