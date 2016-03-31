//
//  CellsView.swift
//  UserInterface
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Graphics

public protocol CellsView
{
    typealias Cell : UIView
    
    func currentlyVisibleCells() -> Set<Cell>
    
    func indexPathForView(view: UIView?) -> NSIndexPath?

    func indexPathForCell(cell: Cell) -> NSIndexPath?
    
    func indexPathForLocation(location : CGPoint) -> NSIndexPath?
}

// MARK: - Defaults

extension CellsView
{
    public func indexPathForView(view: UIView?) -> NSIndexPath?
    {
        guard let cellsView = self as? UIView else { return nil }

        guard let view = view else { return nil }
        
        let superviews = view.superviews + [view]

        if let myIndex = superviews.indexOf(cellsView)
        {
            if let cell = Array(superviews[myIndex..<superviews.count]).cast(Cell).first
            {
                return indexPathForCell(cell)
            }
        }
        
        return nil
    }

    public func indexPathForLocation(location : CGPoint) -> NSIndexPath?
    {
        guard let cellsView = self as? UIView else { return nil }
        
        for cell in currentlyVisibleCells()
        {
            if cell.bounds.contains(cellsView.convertPoint(location, toView: cell))
            {
                return indexPathForCell(cell)
            }
        }
        
        return nil
    }
}

// MARK: - CollectionView

extension UICollectionView : CellsView
{
    public typealias Cell = UICollectionViewCell
    
    public func currentlyVisibleCells() -> Set<Cell>
    {
        return Set(visibleCells())
    }
}

// MARK: - UITableView

extension UITableView : CellsView
{
    public typealias Cell = UITableViewCell
    
    public func currentlyVisibleCells() -> Set<Cell>
    {
        return Set(visibleCells)
    }
}

