//
//  UICollectionView.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit
import Arithmetic
import Graphics
import Collections

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

extension UICollectionView
{
    //    public func visibleCells() -> [UICollectionViewCell]
    //    {
    //        return indexPathsForVisibleItems().flatMap{ self.cellForItemAtIndexPath($0) }
    //    }
    
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

open class LERPCollectionViewLayout: UICollectionViewLayout
{
    public enum Alignment
    {
        case top, bottom, left, right
    }
    
    open var alignment = Alignment.left { didSet { if oldValue != alignment { invalidateLayout() } } }
    
    public enum Axis
    {
        case vertical, horizontal
    }
    
    open var axis = Axis.horizontal { didSet { if oldValue != axis { invalidateLayout() } } }
    
    public enum Distribution
    {
        case fill, stack
    }
    
    open var distribution = Distribution.fill { didSet { if oldValue != distribution { invalidateLayout() } } }
    
    fileprivate var attributes = Array<UICollectionViewLayoutAttributes>()
    
    override open func prepare()
    {
        super.prepare()
        
        attributes.removeAll()
        
        if let sectionCount = collectionView?.numberOfSections
        {
            for section in 0..<sectionCount
            {
                if let itemCount = collectionView?.numberOfItems(inSection: section)
                {
                    for item in 0..<itemCount
                    {
                        let indexPath = IndexPath(item: item, section: section)
                        
                        if let attrs = layoutAttributesForItem(at: indexPath)
                        {
                            attributes.append(attrs)
                        }
                    }
                }
            }
        }
    }
    
    override open var collectionViewContentSize : CGSize
    {
        if var frame = attributes.first?.frame
        {
            for attributesForItemAtIndexPath in attributes
            {
                frame.union(attributesForItemAtIndexPath.frame)
            }
            
            return CGSize(width: frame.right, height: frame.top)
        }
        
        return CGSize.zero
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return collectionView?.bounds != newBounds
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributesForElementsInRect = [UICollectionViewLayoutAttributes]()
        
        for attributesForItemAtIndexPath in attributes
        {
            if attributesForItemAtIndexPath.frame.intersects(rect)
            {
                attributesForElementsInRect.append(attributesForItemAtIndexPath)
            }
        }
        
        return attributesForElementsInRect
    }
    
    func factorForIndexPath(_ indexPath: IndexPath) -> CGFloat
    {
        if let itemCount = collectionView?.numberOfItems(inSection: (indexPath as NSIndexPath).section)
        {
            let factor = itemCount > 1 ? CGFloat((indexPath as NSIndexPath).item) / (itemCount - 1) : 0
            
            return factor
        }
        
        return 0
    }
    
    func zIndexForIndexPath(_ indexPath: IndexPath) -> Int
    {
        if let selectedItem = (collectionView?.indexPathsForSelectedItems?.first as NSIndexPath?)?.item,
            let itemCount = collectionView?.numberOfItems(inSection: (indexPath as NSIndexPath).section)
        {
            
            return itemCount - abs(selectedItem - (indexPath as NSIndexPath).item)
        }
        
        return 0
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        if let collectionView = self.collectionView
            //            let attrs = super.layoutAttributesForItemAtIndexPath(indexPath)
        {
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let factor = factorForIndexPath(indexPath)
            
            let l = ceil(min(collectionView.bounds.height, collectionView.bounds.width))
            let l_2 = l / 2
            
            var lower = collectionView.contentOffset + CGPoint(x: l_2, y: l_2)
            var higher = lower//CGPoint(x: l_2, y: l_2)
            
            switch axis
            {
            case .horizontal:
                higher.x += collectionView.bounds.width - l
            case .vertical:
                higher.y += collectionView.bounds.height - l
            }
            
            switch alignment
            {
            case .top, .left:
                break
                
            case .bottom:
                swap(&higher.y, &lower.y)
                
            case .right:
                swap(&higher.x, &lower.x)
            }
            
            attrs.frame = CGRect(center: (lower, higher) ◊ factor, size: CGSize(l))
            
            attrs.zIndex = zIndexForIndexPath(indexPath)
            
            return attrs
        }
        
        return nil
    }
}

// MARK: - Sections

extension UICollectionView
{
    fileprivate func indexSet(_ sections: [Int]) -> IndexSet
    {
        let indexSet = NSMutableIndexSet()
        
        sections.forEach { indexSet.add($0)}

        return indexSet as IndexSet
    }
    
    public func insertSections(_ sections: Int...)
    {
        insertSections( indexSet(sections) )
    }
    
    public func insertSection(_ section: Int?)
    {
        guard let section = section else { return }
        
        insertSections(IndexSet(integer: section))
    }
    
    
    public func deleteSections(_ sections: Int...)
    {
        deleteSections( indexSet(sections) )
    }
    
    public func deleteSection(_ section: Int?)
    {
        guard let section = section else { return }
        
        deleteSections(IndexSet(integer: section))
    }
    
    
    public func reloadSections(_ sections: Int...)
    {
        reloadSections( indexSet(sections) )
    }
    
    public func reloadSection(_ section: Int?)
    {
        guard let section = section else { return }
        
        reloadSections(IndexSet(integer: section))
    }
    
    // MARK: Items
    
    public func insertItemAtIndexPath(_ indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else { return }
        
        insertItems( at: [indexPath] )
    }
    
    public func deleteItemAtIndexPath(_ indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else { return }
        
        deleteItems( at: [indexPath] )
    }
    
    public func reloadItemAtIndexPath(_ indexPath: IndexPath?)
    {
        guard let indexPath = indexPath else { return }
        
        reloadItems( at: [indexPath] )
    }
    
    public func moveItemFromIndexPath(_ indexPath: IndexPath?, toIndexPath newIndexPath: IndexPath?)
    {
        guard let fromIndexPath = indexPath, let toIndexPath = newIndexPath else { return }
        
        moveItem(at: fromIndexPath, to: toIndexPath)
    }
}

// MARK: - Lookup

extension UICollectionView
{
    public func numberOfItemsInSection(_ section: Int?) -> Int
    {
        guard let section = section else { return 0 }
        
        return numberOfItems(inSection: section)
    }

    public func numberOfItemsInSectionForIndexPath(_ indexPath: IndexPath?) -> Int
    {
        return numberOfItemsInSection((indexPath as NSIndexPath?)?.section)
    }
}


//MARK: - FlowLayout

extension UICollectionViewController
{
    public var flowLayout : UICollectionViewFlowLayout? { return collectionViewLayout as? UICollectionViewFlowLayout }
}

//MARK: - batch updates

public extension UICollectionView
{
    public func performBatchUpdates(_ updates: (() -> Void)?)
    {
        performBatchUpdates(updates, completion: nil)
    }
    
    public func reloadSection(_ section: Int)
    {
        if section >= 0 && section < numberOfSections
        {
            self.reloadSections(IndexSet(integer: section))
        }
    }
}

//MARK: refresh

public extension UICollectionView
{
    public func refreshVisible(_ animated: Bool = true, completion: ((Bool) -> ())? = nil)
    {
        let animations = { self.reloadItems(at: self.indexPathsForVisibleItems) }
        
        if animated
        {
            performBatchUpdates(animations, completion: completion)
        }
        else
        {
            animations()
            completion?(true)
        }
    }
}

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

// MARK: - TODO: Move to own file

class PaginationCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    init(flowLayout: UICollectionViewFlowLayout)
    {
        super.init()
        
        itemSize = flowLayout.itemSize
        sectionInset = flowLayout.sectionInset
        minimumLineSpacing = flowLayout.minimumLineSpacing
        minimumInteritemSpacing = flowLayout.minimumInteritemSpacing
        scrollDirection = flowLayout.scrollDirection
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder:aDecoder)
    }
    
    func applySelectedTransform(_ attributes: UICollectionViewLayoutAttributes?) -> UICollectionViewLayoutAttributes?
    {
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        if let layoutAttributesList = super.layoutAttributesForElements(in: rect)
        {
            return layoutAttributesList.flatMap( self.applySelectedTransform )
        }
        
        return nil
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        
        return applySelectedTransform(attributes)
    }
    
    // Mark : - Pagination
    
    var pageWidth : CGFloat { return itemSize.width + minimumLineSpacing }
    
    let flickVelocity : CGFloat = 0.3
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        var contentOffset = proposedContentOffset
        
        if let collectionView = self.collectionView
        {
            let rawPageValue = collectionView.contentOffset.x / pageWidth
            
            let currentPage = velocity.x > 0 ? floor(rawPageValue) : ceil(rawPageValue)
            
            let nextPage = velocity.x > 0 ? ceil(rawPageValue) : floor(rawPageValue);
            
            let pannedLessThanAPage = abs(1 + currentPage - rawPageValue) > 0.5
            
            let flicked = abs(velocity.x) > flickVelocity
            
            if pannedLessThanAPage && flicked
            {
                contentOffset.x = nextPage * pageWidth
            }
            else
            {
                contentOffset.x = round(rawPageValue) * pageWidth
            }
        }
        
        return contentOffset
    }
}
