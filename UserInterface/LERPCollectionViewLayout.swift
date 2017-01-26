//
//  LERPCollectionViewLayout.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/11/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Arithmetic
import Graphics
import Collections

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
