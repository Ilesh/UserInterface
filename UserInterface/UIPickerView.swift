//
//  UIPickerView.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

extension UIPickerView
{
    public func maxSizeForRowsInComponent(_ component: Int) -> CGSize
    {
        var size = CGSize.zero
        
        if let delegate = self.delegate, let dataSource = self.dataSource, let widthToFit = delegate.pickerView?(self, widthForComponent: component)
        {
            let sizeToFit = CGSize(width: widthToFit , height: 10000)
            
            for row in 0..<dataSource.pickerView(self, numberOfRowsInComponent: component)
            {
                guard let view = delegate.pickerView?(self, viewForRow: row, forComponent: component, reusing: nil) else { continue }
                
                let wantedSize = view.sizeThatFits(sizeToFit)
                
                size.width = max(size.width, wantedSize.width)
                size.height = max(size.height, wantedSize.height)
            }
        }
        
        return size
    }
}

private var selectorColorAssociationKey: UInt8 = 0

extension UIPickerView
{
    @IBInspectable
    open var selectorColor: UIColor?
        {
        get
        {
            return objc_getAssociatedObject(self, &selectorColorAssociationKey) as? UIColor
        }
        set
        {
            objc_setAssociatedObject(self, &selectorColorAssociationKey, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
//    override open func didAddSubview(_ subview: UIView)
//    {
//        super.didAddSubview(subview)
//    
//        updateSelectorLine(subview)
//    }
//    
//    func updateSelectorLine(_ subview: UIView)
//    {
//        guard subview.bounds.height < 1 else { return }
//        
//        subview.backgroundColor = selectorColor ?? subview.backgroundColor
//    }
//    
//    override open func didMoveToWindow()
//    {
//        super.didMoveToWindow()
//        
//        subviews.forEach { updateSelectorLine($0) }
//    }
}
