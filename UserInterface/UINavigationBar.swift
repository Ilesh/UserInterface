//
//  UINavigationBar.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - Title Color

extension UINavigationBar
{
    fileprivate func updateTitleTextAttributesFor(_ key: String, value: Any?)
    {
        updateTitleTextAttributesFor(NSAttributedStringKey(rawValue: key), value: value)
    }
    
    fileprivate func updateTitleTextAttributesFor(_ key: NSAttributedStringKey, value: Any?)
    {
        var newTitleTextAttributes = titleTextAttributes ?? [:]
        
        newTitleTextAttributes[key] = value
        
        titleTextAttributes = newTitleTextAttributes.isEmpty ? nil : newTitleTextAttributes
    }
    
    public var titleColor: UIColor?
        {
        get
        {
            return titleTextAttributes?[NSAttributedStringKey.foregroundColor] as? UIColor
        }
        
        set
        {
            updateTitleTextAttributesFor(NSAttributedStringKey.foregroundColor, value: newValue)
        }
    }
    
    public var titleFont: UIFont?
        {
        get
        {
            return titleTextAttributes?[NSAttributedStringKey.font] as? UIFont
        }
        
        set
        {
            updateTitleTextAttributesFor(NSAttributedStringKey.font, value: newValue)
        }
    }
}
