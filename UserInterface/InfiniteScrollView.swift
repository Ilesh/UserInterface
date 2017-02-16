//
//  InfiniteScrollView.swift
//  UserInterface
//
//  Created by Christian Otkjær on 15/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit

open class InfiniteScrollView: UIScrollView, UIScrollViewDelegate
{
    var visibleLabels: [UILabel] = []
    
    var labelContainerView = UIView()
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override open func awakeFromNib()
    {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup()
    {
        contentSize = CGSize(width: 5000, height: frame.size.height)
        
        labelContainerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height/2)
        
        labelContainerView.isUserInteractionEnabled = false
        
        addSubview(labelContainerView)
        // hide horizontal scroll indicator so our recentering trick is not revealed
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
   
    // recenter content periodically to achieve impression of infinite scrolling
    func recenterIfNecessary()
    {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        
        let centerOffsetX = contentWidth -  bounds.size.width / 2
        
        let distanceFromCenter = abs(currentOffset.x - centerOffsetX)
        
        guard distanceFromCenter > (contentWidth / 4) else { return }
        
        contentOffset = CGPoint(x:centerOffsetX, y: currentOffset.y)
        
        // move content by the same amount so it appears to stay still
        for label in visibleLabels
        {
            var center = labelContainerView.convert(label.center, to: self)
            
            center.x += centerOffsetX - currentOffset.x
            
            label.center = convert(center, to:labelContainerView)
        }
    }
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        
        recenterIfNecessary()
        
        // tile content in visible bounds
        let visibleBounds = convert(bounds, to:labelContainerView)
        
        let minimumVisibleX = visibleBounds.minX
        
        let maximumVisibleX = visibleBounds.maxX
        
        tileLabelsFromMinX(minimumVisibleX: minimumVisibleX, toMaxX:maximumVisibleX)
    }
    
    // MARK: - Label Tiling
    
    func insertLabel() -> UILabel
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 80))
        
        label.numberOfLines = 3
        label.text = "1024 Block Street\nShaffer, CA\n95014"
        labelContainerView.addSubview(label)
        
        return label
    }
    
    @discardableResult
    func placeNewLabelOnRight(rightEdge: CGFloat) -> CGFloat
    {
        let label = insertLabel()
        visibleLabels.append(label) // add rightmost label at the end of the array
        
        var frame = label.frame
        frame.origin.x = rightEdge
        frame.origin.y = labelContainerView.bounds.size.height - frame.size.height
        label.frame = frame
        
        return frame.maxX
    }
    
    @discardableResult
    func placeNewLabelOnLeft(leftEdge: CGFloat) -> CGFloat
    {
        let label = insertLabel()
        visibleLabels.insert(label, at: 0) // add leftmost label at the beginning of the array
        
        var frame = label.frame
        frame.origin.x = leftEdge - frame.size.width
        frame.origin.y = labelContainerView.bounds.size.height - frame.size.height
        label.frame = frame
        
        return frame.minX
    }
    
    func tileLabelsFromMinX(minimumVisibleX: CGFloat, toMaxX maximumVisibleX: CGFloat)
    {
        // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
        // to kick off the tiling we need to make sure there's at least one label
        if visibleLabels.isEmpty
        {
            placeNewLabelOnRight(rightEdge: minimumVisibleX)
        }
        
        // add labels that are missing on right side
        if var rightEdge = visibleLabels.last?.frame.maxX
        {
            while rightEdge < maximumVisibleX
            {
                rightEdge = placeNewLabelOnRight(rightEdge: rightEdge)
            }
        }
        
        // add labels that are missing on left side
        if var leftEdge = visibleLabels.first?.frame.minX
        {
            while leftEdge > minimumVisibleX
            {
                leftEdge = placeNewLabelOnLeft(leftEdge: leftEdge)
            }
        }

        // remove labels that have fallen off right edge
        while let lastLabel = visibleLabels.last, lastLabel.frame.origin.x > maximumVisibleX
        {
            lastLabel.removeFromSuperview()
            visibleLabels.removeLast()
        }
        
        // remove labels that have fallen off left edge
        while let firstLabel = visibleLabels.first, firstLabel.frame.maxX < minimumVisibleX
        {
            firstLabel.removeFromSuperview()
            visibleLabels.removeFirst()
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return labelContainerView
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
    }
}
