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
        
        guard section >= 0 else { return nil }
        
        let item = numberOfItems(inSection: section) - 1
            
        guard item >= 0 else { return nil }
        
        return IndexPath(item: item, section: section)
    }
    
    var firstIndexPath : IndexPath?
    {
        guard numberOfSections > 0, numberOfItems(inSection: 0) > 0 else { return nil }
        
        return IndexPath(item: 0, section: 0)
    }
}
