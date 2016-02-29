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
    
    public func moveScrollIndicatorToLeft(left: Bool = true, offset: CGFloat = 6)
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

//MARK: - IndexPaths

extension UITableView
{
    public func indexPathForLocation(location : CGPoint) -> NSIndexPath?
    {
        for cell in visibleCells
        {
            let locationInCell = convertPoint(location, toView: cell)
            
            if cell.bounds.contains(locationInCell)
            {
                return indexPathForCell(cell)
            }
        }
        
        return nil
    }
    
    public func indexPathForView(view: UIView) -> NSIndexPath?
    {
        let superviews = view.superviews
        
        if let myIndex = superviews.indexOf(self)
        {
            if let cell = Array(superviews[myIndex..<superviews.count]).cast(UITableViewCell).first
            {
                return indexPathForCell(cell)
            }
        }
    
        return nil
    }
}