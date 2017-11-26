//
//  UIFont.swift
//  Silverback
//
//  Created by Christian Otkjær on 30/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - UIFont

// MARK: - Size

extension UIFont
{
    public func pointSize(toFit text: String,
                          inSize size: CGSize,
                          lineBreakMode: NSLineBreakMode,
                          minSize: CGFloat = 1,
                          maxSize: CGFloat = 512) -> CGFloat
    {
        let fontSize = pointSize
        
        guard minSize < maxSize - 1 else { return minSize }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attributes = [
            NSAttributedStringKey.paragraphStyle:paragraphStyle,
            NSAttributedStringKey.font: self
        ]
        
        let aText = NSAttributedString(string: text, attributes: attributes)
        
        let expectedSize = aText.boundingRect(with: size, options: [ NSStringDrawingOptions.usesLineFragmentOrigin ], context: nil).size
        
        debugPrint("sizeToFit: \(size), expectedSize: \(expectedSize)")
        
        if expectedSize.width > size.width || expectedSize.height > size.height
        {
            if fontSize == minSize
            {
                return fontSize
            }
            else if fontSize < minSize
            {
                return minSize
            }
            
            let newFontSize = floor((fontSize + minSize) / 2)
            
            return withSize(newFontSize).pointSize(toFit: text, inSize: size, lineBreakMode: lineBreakMode, minSize: minSize, maxSize: fontSize)
        }
        else if size.fits(expectedSize)
        {
            if fontSize >= maxSize
            {
                return maxSize
            }
            
            let newFontSize = ceil((fontSize + maxSize) / 2)

            return withSize(newFontSize).pointSize(toFit: text, inSize: size, lineBreakMode: lineBreakMode, minSize: fontSize, maxSize: maxSize)
        }
        else
        {
            return fontSize
        }
    }
}


extension String
{
    public func fontToFitSize(
        _ sizeToFit: CGSize,
        font: UIFont,
        lineBreakMode: NSLineBreakMode,
        minSize: CGFloat = 1,
        maxSize: CGFloat = 512) -> UIFont
    {
        let fontSize = font.pointSize
        
        guard minSize < maxSize - 1 else { return font.withSize(minSize) }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attributes = [ NSAttributedStringKey.paragraphStyle:paragraphStyle, NSAttributedStringKey.font:font]
        
        let aText = NSAttributedString(string: self, attributes: attributes)
        
        let expectedSize = aText.boundingRect(with: sizeToFit, options: [ NSStringDrawingOptions.usesLineFragmentOrigin ], context: nil).size
        
        debugPrint("sizeToFit: \(sizeToFit), expectedSize: \(expectedSize)")
        
        if expectedSize.width > sizeToFit.width || expectedSize.height > sizeToFit.height
        {
            if fontSize == minSize
            {
                return font
            }
            else if fontSize < minSize
            {
                return font.withSize(minSize)
            }
            
            let newFontSize = floor((fontSize + minSize) / 2)
            
            return fontToFitSize(sizeToFit, font: font.withSize(newFontSize), lineBreakMode: lineBreakMode, minSize: minSize, maxSize: fontSize)
        }
        else if sizeToFit.fits(expectedSize)
        {
            if fontSize >= maxSize
            {
                return font.withSize(maxSize)
            }
            
            let newFontSize = ceil((fontSize + maxSize) / 2)
            
            return fontToFitSize(sizeToFit, font: font.withSize(newFontSize), lineBreakMode: lineBreakMode, minSize: fontSize, maxSize: maxSize)
        }
        else
        {
            return font
        }
    }
}

