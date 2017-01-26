//
//  PaginationCollectionViewFlowLayout.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/11/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

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
