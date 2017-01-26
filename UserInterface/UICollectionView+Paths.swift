//
//  UICollectionView+Paths.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/11/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

// MARK: - Index Paths

public extension UICollectionView
{
    var lastIndexPath : IndexPath?
    {
        let section = numberOfSections - 1
        
        if section >= 0
        {
            let item = numberOfItems(inSection: section) - 1
            
            if item >= 0
            {
                return IndexPath(item: item, section: section)
            }
        }
        
        return nil
    }
    
    var firstIndexPath : IndexPath?
    {
        if numberOfSections > 0
        {
            if numberOfItems(inSection: 0) > 0
            {
                return IndexPath(item: 0, section: 0)
            }
        }
        
        return nil
    }
}
