//
//  CollectionViewGridLayout.swift
//  UserInterface
//
//  Created by Christian Otkjær on 16/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import Arithmetic

public protocol CollectionViewGridLayoutDelegate: class
{
    /// Asks the delegate for the number of rows or columns (depending on scroll-direction) that the given item should span. Answer should be between 1 and numberOfDivisions
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, spanForItemAt indexPath: IndexPath) -> Int
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, itemFlexibleDimensionWithFixedDimension fixedDimension: CGFloat) -> CGFloat
 
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, headerFlexibleDimensionWithFixedDimension fixedDimension: CGFloat) -> CGFloat
}

public extension CollectionViewGridLayoutDelegate
{
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, spanForItemAt indexPath: IndexPath) -> Int
    {
        return 1
    }
    

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, itemFlexibleDimensionWithFixedDimension fixedDimension: CGFloat) -> CGFloat
    {
        return fixedDimension
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, headerFlexibleDimensionWithFixedDimension fixedDimension: CGFloat) -> CGFloat
    {
        return 0
    }
}

// A convenient tuple for working with items
private typealias ItemFrame = (section: Int, flexibleIndex: Int, fixedIndex: Int, span: Int)


@IBDesignable
open class CollectionViewGridLayout: UICollectionViewLayout, CollectionViewGridLayoutDelegate
{
    @IBInspectable
    /// Scrolldirection as in UICollectionViewFlowLayout
    open var scrollDirection: UICollectionViewScrollDirection = .vertical
        {
        didSet { invalidateLayoutIfNecessary(oldValue: oldValue, newValue: scrollDirection) }
    }
    
    /// Spacing between items
    open var itemSpacing: CGFloat = 0
        {
        didSet { invalidateLayoutIfNecessary(oldValue: oldValue, newValue: itemSpacing) }
    }
    /// The number of rows or columns, depending on scroll-direction; columns for .vertical, rows for .horizontal
    open var numberOfDivisions: Int
        {
        get
        {
            return _numberOfDivisions
        }
        set
        {
            // ensure a valid numberOfDivisions
            let validNewValue = max(1, newValue)
            
            _numberOfDivisions = validNewValue
        }
    }
    
    // Backing variable for numberOfDivisions
    private var _numberOfDivisions = 1
        {
        didSet
        {
            invalidateLayoutIfNecessary(oldValue: oldValue, newValue: _numberOfDivisions)
        }
    }
    
    func invalidateLayoutIfNecessary<T: Equatable>(oldValue: T, newValue: T)
    {
        guard actualDelegate === self else { return }
        
        if oldValue != newValue { invalidateLayout() }
    }
    
    /// Delegate
    open weak var delegate: CollectionViewGridLayoutDelegate?
    
    private var actualDelegate: CollectionViewGridLayoutDelegate { return delegate ?? collectionView?.delegate as? CollectionViewGridLayoutDelegate ?? self }
    
    private var contentSize: CGSize = .zero

    private var itemFixedDimension: CGFloat = 0
    private var itemFlexibleDimension: CGFloat = 0
    
    /// This represents a 2 dimensional array for each section, indicating whether each block in the grid is occupied
    /// It is grown dynamically as needed to fit every item into a grid
    private var sectionedItemGrid: Array<Array<Array<Bool>>> = []
    
    /// The cache built up during the `prepare` function
    private var itemAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    
    /// The header cache built up during the `prepare` function
    private var headerAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    
    
    // MARK: - UICollectionView Layout
    
    override open func prepare()
    {
        // On rotation, UICollectionView sometimes calls prepare without calling invalidateLayout
        guard itemAttributesCache.isEmpty, headerAttributesCache.isEmpty, let collectionView = collectionView else { return }
        
        let fixedDimension: CGFloat
        
        switch scrollDirection
        {
        case .vertical:
            
            fixedDimension = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
            contentSize.width = fixedDimension
            
        case .horizontal:
            
            fixedDimension = collectionView.frame.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)
            contentSize.height = fixedDimension
        }
        
        var additionalSectionSpacing: CGFloat = 0

        let headerFlexibleDimension = actualDelegate.collectionView(collectionView, layout: self, headerFlexibleDimensionWithFixedDimension: fixedDimension)

        itemFixedDimension = (fixedDimension - (numberOfDivisions * itemSpacing) + itemSpacing) / numberOfDivisions
        
        itemFlexibleDimension = actualDelegate.collectionView(collectionView, layout: self, itemFlexibleDimensionWithFixedDimension: itemFixedDimension)
        
        for section in 0 ..< collectionView.numberOfSections
        {
            let itemCount = collectionView.numberOfItems(inSection: section)
            
            // Calculate header attributes
            if headerFlexibleDimension > 0 && itemCount > 0
            {
                if headerAttributesCache.count > 0
                {
                    additionalSectionSpacing += itemSpacing
                }
                
                let frame: CGRect
                switch scrollDirection
                {
                case .vertical:
                    frame = CGRect(x: 0, y: additionalSectionSpacing, width: fixedDimension, height: headerFlexibleDimension)
                    
                case .horizontal:
                    frame = CGRect(x: additionalSectionSpacing, y: 0, width: headerFlexibleDimension, height: fixedDimension)
                }
                
                let headerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
                headerLayoutAttributes.frame = frame
                
                headerAttributesCache.append(headerLayoutAttributes)
                additionalSectionSpacing += headerFlexibleDimension + itemSpacing
            }
            
            // Calculate item attributes
            let sectionOffset = additionalSectionSpacing
            sectionedItemGrid.append([])
            
            var flexibleIndex = 0, fixedIndex = 0
            
            for item in 0 ..< itemCount
            {
                if fixedIndex >= numberOfDivisions
                {
                    // Reached end of row in .vertical or column in .horizontal
                    fixedIndex = 0
                    flexibleIndex += 1
                }
                
                let itemIndexPath = IndexPath(item: item, section: section)
                let itemSpan = indexableSpan(forItemAt: itemIndexPath)
                let intendedFrame = ItemFrame(section, flexibleIndex, fixedIndex, itemSpan)
                
                // Find a place for the item in the grid
                let (itemFrame, didFitInOriginalFrame) = nextAvailableFrame(startingAt: intendedFrame)
                
                reserveItemGrid(frame: itemFrame)
                
                let itemAttributes = layoutAttributes(for: itemIndexPath, at: itemFrame, with: sectionOffset)
                
                itemAttributesCache.append(itemAttributes)
                
                // Update flexible dimension
                switch scrollDirection
                {
                case .vertical:
                    
                    contentSize.height = max(contentSize.height, itemAttributes.frame.maxY)

                    additionalSectionSpacing = max(additionalSectionSpacing, itemAttributes.frame.maxY)
                    
                case .horizontal:

                    contentSize.width = max(contentSize.width, itemAttributes.frame.maxX)
                    
                    additionalSectionSpacing = max(additionalSectionSpacing, itemAttributes.frame.maxX)
                }
                
                if (didFitInOriginalFrame)
                {
                    fixedIndex += 1 + itemFrame.span
                }
            }
        }
        
        sectionedItemGrid.removeAll() // Only used during prepare()
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        let headerAttributes = headerAttributesCache.filter { $0.frame.intersects(rect) }
        let itemAttributes = itemAttributesCache.filter { $0.frame.intersects(rect) }
        
        return headerAttributes + itemAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return itemAttributesCache.first { $0.indexPath == indexPath }
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard elementKind == UICollectionElementKindSectionHeader else { return nil }
        
        return headerAttributesCache.first { $0.indexPath == indexPath }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        guard let currentBounds = collectionView?.bounds else { return false }
        
        switch scrollDirection
        {
        case .vertical:
            return currentBounds.width != newBounds.width
            
        case .horizontal:
            return currentBounds.height != newBounds.height
        }
    }
    
    override open func invalidateLayout()
    {
        super.invalidateLayout()
        
        itemAttributesCache.removeAll()
        headerAttributesCache.removeAll()
        contentSize = .zero
    }
    
    override open var collectionViewContentSize: CGSize
    {
        return contentSize
    }
    
    // MARK: - Private
    
    private func indexableSpan(forItemAt indexPath: IndexPath) -> Int
    {
        guard let collectionView = collectionView else { return 0 }
        
        let itemSpan = actualDelegate.collectionView(collectionView, layout: self, spanForItemAt: indexPath)
        
        // Using with indices, want 0-based
        return min(numberOfDivisions, max(0, itemSpan - 1))
    }
    
    private func nextAvailableFrame(startingAt originalFrame: ItemFrame) -> (frame: ItemFrame, fitInOriginalFrame: Bool)
    {
        var flexibleIndex = originalFrame.flexibleIndex
        var fixedIndex = originalFrame.fixedIndex
        
        var newFrame = ItemFrame(originalFrame.section, flexibleIndex, fixedIndex, originalFrame.span)
        
        while !isSpaceAvailable(for: newFrame)
        {
            fixedIndex += 1
            
            // Reached end of fixedIndex, restart on next flexibleIndex
            if fixedIndex + originalFrame.span >= _numberOfDivisions
            {
                fixedIndex = 0
                flexibleIndex += 1
            }
            
            newFrame = ItemFrame(originalFrame.section, flexibleIndex, fixedIndex, originalFrame.span)
        }
        
        // Fits iff we never had to walk the grid to find a position
        return (newFrame, flexibleIndex == originalFrame.flexibleIndex && fixedIndex == originalFrame.fixedIndex)
    }
    
    /// Checks the grid from the origin to the origin + span for occupied blocks
    private func isSpaceAvailable(for frame: ItemFrame) -> Bool
    {
        for flexibleIndex in frame.flexibleIndex ... frame.flexibleIndex + frame.span
        {
            // Ensure we won't go off the end of the array
            while sectionedItemGrid[frame.section].count <= flexibleIndex
            {
                sectionedItemGrid[frame.section].append(Array(repeating: false, count: _numberOfDivisions))
            }
            
            for fixedIndex in frame.fixedIndex ... frame.fixedIndex + frame.span
            {
                if fixedIndex >= _numberOfDivisions || sectionedItemGrid[frame.section][flexibleIndex][fixedIndex]
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func reserveItemGrid(frame: ItemFrame)
    {
        for flexibleIndex in frame.flexibleIndex ... frame.flexibleIndex + frame.span
        {
            for fixedIndex in frame.fixedIndex ... frame.fixedIndex + frame.span
            {
                sectionedItemGrid[frame.section][flexibleIndex][fixedIndex] = true
            }
        }
    }
    
    private func layoutAttributes(for indexPath: IndexPath, at itemFrame: ItemFrame, with sectionOffset: CGFloat) -> UICollectionViewLayoutAttributes
    {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let fixedIndexOffset = CGFloat(itemFrame.fixedIndex) * (itemSpacing + itemFixedDimension)
        let longitudinalOffset = CGFloat(itemFrame.flexibleIndex) * (itemSpacing + itemFlexibleDimension) + sectionOffset
        let itemSpannedTransverseDimension = itemFixedDimension + (itemFrame.span * (itemSpacing + itemFixedDimension))
        let itemSpannedLongitudinalDimension = itemFlexibleDimension + (itemFrame.span * (itemSpacing + itemFlexibleDimension))
        
        switch scrollDirection
        {
        case .vertical:
            layoutAttributes.frame = CGRect(x: fixedIndexOffset, y: longitudinalOffset, width: itemSpannedTransverseDimension, height: itemSpannedLongitudinalDimension)
            
        case .horizontal:
            layoutAttributes.frame = CGRect(x: longitudinalOffset, y: fixedIndexOffset, width: itemSpannedLongitudinalDimension, height: itemSpannedTransverseDimension)
        }
        
        return layoutAttributes
    }
}
