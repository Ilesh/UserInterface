//
//  UICollectionView.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - CustomDebugStringConvertible

extension UICollectionViewScrollDirection : CustomDebugStringConvertible, CustomStringConvertible
{
    public var description : String { return debugDescription }
    
    public var debugDescription : String
        {
            switch self
            {
            case .vertical: return "Vertical"
            case .horizontal: return "Horizontal"
            }
    }
}


//MARK: - IndexPaths
/*
extension UICollectionView
{
    public func indexPathForLocation(_ location : CGPoint) -> IndexPath?
    {
        for cell in visibleCells
        {
            if cell.bounds.contains(convert(location, to: cell))
            {
                return indexPath(for: cell)
            }
        }
        
        return nil
    }
}
*/

// MARK: - Sections

extension UICollectionView
{
    public func insert(sectionsAt sections: Int...)
    {
        insertSections(IndexSet(sections))
    }
    
    public func insert(sectionAt section: Int?)
    {
        guard let section = section else { return }
        
        insertSections(IndexSet(integer: section))
    }
    
    
    public func delete(sectionsAt sections: Int...)
    {
        deleteSections(IndexSet(sections))// indexSet(sections))
    }
    
    public func delete(sectionAt section: Int?)
    {
        guard let section = section else { return }
        
        deleteSections(IndexSet(integer: section))
    }
    
    
    public func reload(sectionsAt sections: Int...)
    {
        reloadSections(IndexSet(sections))
    }
    
    public func reload(sectionAt section: Int?)
    {
        guard let section = section else { return }
        
        reloadSections(IndexSet(integer: section))
    }
    
    // MARK: Items
    
    public func insert(itemAt indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else { return }
        
        insertItems(at: [indexPath])
    }
    
    public func delete(itemAt indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else { return }
        
        deleteItems(at: [indexPath])
    }
    
    public func reload(itemAt indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else { return }
        
        reloadItems(at: [indexPath])
    }
    
    public func move(itemAt at: IndexPath?, to: IndexPath?)
    {
        guard let at = at, let to = to else { return }
        
        moveItem(at: at, to: to)
    }
}

// MARK: - Lookup

extension UICollectionView
{
    public func numberOfItems(inSection: Int?) -> Int
    {
        guard let section = inSection else { return 0 }
        
        return numberOfItems(inSection: section)
    }

    public func numberOfItemsInSection(forIndexPath indexPath: IndexPath?) -> Int
    {
        return numberOfItems(inSection: indexPath?.section)
    }
}

//MARK: - batch updates

public extension UICollectionView
{
    public func performBatchUpdates(_ updates: (() -> Void)?)
    {
        performBatchUpdates(updates, completion: nil)
    }
}

