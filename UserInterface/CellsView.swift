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
    associatedtype Cell : UIView
    
    var visibleCells : [Cell] { get }
    
    func path(forView view: UIView?) -> IndexPath?

    func path(forCell cell: Cell?) -> IndexPath?
    
    func path(forLocation location : CGPoint?) -> IndexPath?
}

// MARK: - Defaults

extension CellsView
{
    public func path(forView view: UIView?) -> IndexPath?
    {
        guard let cellsView = self as? UIView else { return nil }

        guard let view = view else { return nil }
        
        let superviews = view.superviews + [view]

        if let myIndex = superviews.index(of: cellsView)
        {
            if let cell = Array(superviews[myIndex..<superviews.count]).cast(Cell.self).first
            {
                return path(forCell: cell)
            }
        }
        
        return nil
    }

    public func path(forLocation location : CGPoint?) -> IndexPath?
    {
        guard let location = location else { return nil }
        
        guard let cellsView = self as? UIView else { return nil }
        
        for cell in visibleCells
        {
            if cell.bounds.contains(cellsView.convert(location, to: cell))
            {
                return path(forCell: cell)
            }
        }
        
        return nil
    }
}

// MARK: - CollectionView

extension UICollectionView : CellsView
{
    public typealias Cell = UICollectionViewCell
    
    public func path(forCell cell: Cell?) -> IndexPath?
    {
        guard let cell = cell else { return nil }
        
        return indexPath(for: cell)
    }
}

// MARK: - UITableView

extension UITableView : CellsView
{
    public typealias Cell = UITableViewCell

    public func path(forCell cell: Cell?) -> IndexPath?
    {
        guard let cell = cell else { return nil }

        return indexPath(for: cell)
    }
}

