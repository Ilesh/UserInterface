//
//  UICollectionView+Refresh.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/11/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

//MARK: refresh

public extension UICollectionView
{
    public func refresh(
        itemsAt paths: [IndexPath],
        animated: Bool = true,
        completion: ((Bool) -> ())? = nil)
    {
        if animated
        {
            performBatchUpdates({ self.reloadItems(at: paths) }, completion: completion)
        }
        else
        {
            reloadItems(at: paths)
            
            completion?(true)
        }
    }
    
    /// Reloads all visible cells
    public func refresh(animated: Bool = true, completion: ((Bool) -> ())? = nil)
    {
        refresh(itemsAt: indexPathsForVisibleItems, animated: animated, completion: completion)
    }
    
    /// Reloads a given section
    public func refresh(section: Int?, animated: Bool = true, completion: ((Bool) -> ())? = nil)
    {
        guard let section = section else { return }

        if section >= 0 && section < numberOfSections
        {
            reloadSections(IndexSet(integer: section))
        }

        let paths = indexPathsForVisibleItems.filter({$0.section == section })
        
        refresh(itemsAt: paths, animated: animated, completion: completion)
    }
}
