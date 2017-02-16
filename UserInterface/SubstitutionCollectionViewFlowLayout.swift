//
//  SubstitutionCollectionViewFlowLayout.swift
//  UserInterface
//
//  Created by Christian Otkjær on 15/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit

open class SubstitutionCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    public init(flowLayout: UICollectionViewFlowLayout?)
    {
        super.init()
        
        let flowLayout = flowLayout ?? UICollectionViewFlowLayout()
        
        scrollDirection = flowLayout.scrollDirection
        
        minimumLineSpacing = flowLayout.minimumLineSpacing
        
        minimumInteritemSpacing = flowLayout.minimumInteritemSpacing
        
        itemSize = flowLayout.itemSize
        
        estimatedItemSize = flowLayout.estimatedItemSize
        
        sectionInset = flowLayout.sectionInset
        
        headerReferenceSize = flowLayout.headerReferenceSize
        
        footerReferenceSize = flowLayout.footerReferenceSize
        
        sectionHeadersPinToVisibleBounds = flowLayout.sectionHeadersPinToVisibleBounds
        
        sectionFootersPinToVisibleBounds = flowLayout.sectionFootersPinToVisibleBounds
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder:aDecoder)
    }
    
    
}
