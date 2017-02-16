//
//  CenteredCollectionViewFlowLayout.swift
//  UserInterface
//
//  Created by Christian Otkjær on 15/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import Graphics

open class CenteredCollectionViewFlowLayout: SubstitutionCollectionViewFlowLayout
{
    func findSizeForItem(at path: IndexPath) -> CGSize
    {
        guard let collectionView = collectionView else { return itemSize }
        
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return itemSize }

        return delegate.collectionView?(collectionView, layout: self, sizeForItemAt: path) ?? itemSize
    }

    func findSectionInsetsFor(section: Int) -> UIEdgeInsets
    {
        guard let collectionView = collectionView else { return sectionInset }
        
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return sectionInset }
        
        return delegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? sectionInset
    }

    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    
    func prepare(section: Int, offset: CGPoint) -> CGPoint
    {
        guard let collectionView = collectionView else { return .zero }

        let foundSectionInsets = findSectionInsetsFor(section: section)
        
        var lineOffset: CGFloat = 0
        var itemOffset: CGFloat = 0
        
        let lineConstraint: CGFloat
        
        switch scrollDirection
        {
        case .horizontal:
            lineConstraint = collectionView.bounds.height - (sectionInset.top + sectionInset.bottom)
            
        case .vertical:
            lineConstraint = collectionView.bounds.width - (sectionInset.left + sectionInset.right)
        }

        var sectionAttributes: [UICollectionViewLayoutAttributes] = []

        var lineAttributes: [UICollectionViewLayoutAttributes] = []
        
        func centerLineAttributes()
        {
            func lineSpacing() -> CGFloat
            {
                return sectionAttributes.isEmpty ? 0 : minimumLineSpacing
            }
            
            lineOffset += lineSpacing()
            
            switch scrollDirection
            {
            case .horizontal:
                let lineLength = lineAttributes.map{max($0.frame.top, $0.frame.bottom)}.max() ?? 0
                let centeringOffset = (lineConstraint - lineLength) / 2
                
                lineAttributes.forEach { $0.frame.origin += CGPoint(x: sectionInset.left + lineOffset + offset.x, y: sectionInset.top + centeringOffset)}
                
                lineOffset += (lineAttributes.map{$0.frame.width}.max() ?? 0)
                
            case .vertical:
                let lineLength = lineAttributes.map{$0.frame.right}.max() ?? 0
                let centeringOffset = (lineConstraint - lineLength) / 2
                
                lineAttributes.forEach { $0.frame.origin += CGPoint(x: sectionInset.left + centeringOffset, y: sectionInset.top + lineOffset + offset.y)}
                
                lineOffset += (lineAttributes.map{$0.frame.height}.max() ?? 0) 
            }
            
            itemOffset = 0
            
            sectionAttributes += lineAttributes
            lineAttributes.removeAll()
        }

        for item in 0 ..< collectionView.numberOfItems(inSection: section)
        {
            let path = IndexPath(item: item, section: section)
        
            let attrs = UICollectionViewLayoutAttributes(forCellWith: path)
            
            let size = findSizeForItem(at: path)
            attrs.size = size

            func interItemSpace() -> CGFloat
            { return lineAttributes.isEmpty ? 0 : minimumInteritemSpacing }

            switch scrollDirection
            {
            case .horizontal:
                
                if size.height + itemOffset + interItemSpace() > lineConstraint
                {
                    centerLineAttributes()
                }
                
                itemOffset += interItemSpace()

                attrs.frame = CGRect(origin: CGPoint(x: 0, y: itemOffset), size: size)
                
                itemOffset += size.height
                
            case .vertical:
            
                if size.width + itemOffset + interItemSpace() > lineConstraint
                {
                    centerLineAttributes()
                }
                
                itemOffset += interItemSpace()
                
                attrs.frame = CGRect(origin: CGPoint(x: itemOffset, y: 0), size: size)
                
                itemOffset += size.width
            }

            lineAttributes.append(attrs)
        }
        
        centerLineAttributes()
        
        cachedAttributes += sectionAttributes
        
        switch scrollDirection
        {
        case .horizontal:
            let maxX = sectionAttributes.map({$0.frame.maxX}).max() ?? 0
            return CGPoint(x:maxX + foundSectionInsets.right, y: 0)
        
        case .vertical:
            let maxY = sectionAttributes.map({$0.frame.maxY}).max() ?? 0
            return CGPoint(x: 0, y: maxY + foundSectionInsets.bottom)
        }
    }
    
    open override func prepare()
    {
        super.prepare()

        cachedAttributes.removeAll(keepingCapacity: true)

        guard let collectionView = collectionView else { return }

        var sectionOffset: CGPoint = .zero//-CGPoint(x: collectionView.contentInset.left, y: collectionView.contentInset.top)
        
        //collectionView.contentOffset
        
        for section in 0 ..< collectionView.numberOfSections
        {
            let so = prepare(section: section, offset: sectionOffset)
            
            sectionOffset = so
        }
    }
    
//    func layoutAttributesForItemsInLineWithItem(at indexPath: IndexPath) -> [UICollectionViewLayoutAttributes]?
//    {
//        guard let collectionView = collectionView else { return nil }
//
//        guard let itemAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
//        
//        let contentFrame = CGRect(origin: collectionView.contentOffset, size: collectionView.contentSize)
//        
//        var rect = itemAttributes.frame
//        
//        switch scrollDirection
//        {
//        case .horizontal:
//            rect.top = contentFrame.top
//            rect.size.height = contentFrame.height
//
//        case .vertical:
//            rect.left = contentFrame.left
//            rect.size.width = contentFrame.width
//        }
//        
//        guard let lineAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
//        
//        switch scrollDirection
//        {
//        case .horizontal:
//            let top = lineAttributes.map{ $0.frame.top }.min() ?? itemAttributes.frame.top
//            let bottom = lineAttributes.map{ $0.frame.bottom }.max() ?? itemAttributes.frame.bottom
//            
//            let span = bottom - top
//            
//            let height = contentFrame.height
//            
//            let adjustment = ( height - span ) / 2
//            
//            lineAttributes.forEach { $0.frame.top += adjustment }
//            
//        case .vertical:
//
//            let left = lineAttributes.map{ $0.frame.left }.min() ?? itemAttributes.frame.left
//            let right = lineAttributes.map{ $0.frame.right }.max() ?? itemAttributes.frame.right
//            
//            let span = right - left
//            
//            let adjustment = ( contentFrame.width - span ) / 2
//            
//            lineAttributes.forEach { $0.frame.left += adjustment }
//        }
//        
//        return lineAttributes
//    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return cachedAttributes.filter({$0.frame.intersects(rect)})
//        
//        guard let collectionView = collectionView else { return nil }
//        
//        let contentFrame = collectionView.bounds//CGRect(origin: collectionView.contentOffset, size: collectionView.contentSize)
//
//        var frame = rect
//        
//        switch scrollDirection
//        {
//        case .horizontal:
//            frame.top = contentFrame.top
//            frame.size.height = contentFrame.height
//            
//        case .vertical:
//            frame.left = contentFrame.left
//            frame.size.width = contentFrame.width
//        }
//        
//        guard let layoutAttributesList = super.layoutAttributesForElements(in: frame) else { return nil }
//
//        return layoutAttributesList.filter { $0.frame.intersects(rect) }
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return cachedAttributes.first(where: {$0.indexPath == indexPath})
        
//        guard let lineAttributes = layoutAttributesForItemsInLineWithItem(at: indexPath) else { return nil }
//        
//        return lineAttributes.first(where: {$0.indexPath == indexPath})
    }
    
    /*
    open override var collectionViewContentSize: CGSize
        {
        guard let collectionView = collectionView else { return .zero }
        
        guard let minY = cachedAttributes.map({$0.frame.minY}).min(),
        let minX = cachedAttributes.map({$0.frame.minX}).min(),
        let maxY = cachedAttributes.map({$0.frame.maxY}).min(),
            let maxX = cachedAttributes.map({$0.frame.maxX}).max() else { return .zero }
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY).size
    }
 */
}
