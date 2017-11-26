//
//  CollectionViewTimelineLayout.swift
//  UserInterface
//
//  Created by Christian Otkjær on 16/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import Arithmetic

public enum CollectionViewTimelineLayoutScale
{
    case second, minute, hour, day, week
    
    var scale: TimeInterval
        {
        switch self
        {
        case .second:
            return 1
            
        case .minute:
            return 60
            
        case .hour:
            return 3600 // 60 * 60
            
        case .day:
            return 3600 * 24
            
        case .week:
            return 3600 * 24 * 7
        }
    }
}

public typealias TimeSpan = (begin: TimeInterval?, end: TimeInterval?)

public protocol CollectionViewTimelineLayoutDelegate: class
{
    /// Asks the delegate for the timescale to use during layout
    func timeScaleFor(collectionView: UICollectionView, layout: UICollectionViewLayout) -> CollectionViewTimelineLayoutScale

    /// Asks the delegate for the number of points to represent one time-unit in at the given scale
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, timeUnitLengthForTimeScale: CollectionViewTimelineLayoutScale) -> CGFloat

    /// Asks the delegate for the timespan of an item/event at a given indexPath
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, timeSpanForItemAt indexPath: IndexPath) -> TimeSpan
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, alignmentForItemAt indexPath: IndexPath) -> CGFloat
}

// MARK: - Defaults

private let DefaultItemSize = CGSize(width: 60, height: 60)
private let DefaultTimeUnitLength: CGFloat = 60
private let DefaultItemAlignment: CGFloat = 0.5
private let DefaultTimelineScale: CollectionViewTimelineLayoutScale = .second
private let CollectionViewTimelineSupp: String = "TimelineSupp"

public extension CollectionViewTimelineLayoutDelegate
{
    func timeScaleFor(collectionView: UICollectionView, layout: UICollectionViewLayout) -> CollectionViewTimelineLayoutScale
    {
        return DefaultTimelineScale
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, timeSpanForItemAt indexPath: IndexPath) -> TimeSpan
    {
        return (0,0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, timeUnitLengthForTimeScale: CollectionViewTimelineLayoutScale) -> CGFloat
    {
        return DefaultTimeUnitLength
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return DefaultItemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, alignmentForItemAt indexPath: IndexPath) -> CGFloat
    {
        return DefaultItemAlignment
    }
}

open class CollectionViewTimelineLayout: UICollectionViewLayout
{
    // MARK: - delegate
    
    open weak var delegate: CollectionViewTimelineLayoutDelegate?
    
    private var actualDelegate: CollectionViewTimelineLayoutDelegate { return delegate ?? (collectionView?.delegate as? CollectionViewTimelineLayoutDelegate) ?? self }

    // MARK: - Item Size
    
    /// The size of an item
    open var itemSize: CGSize = DefaultItemSize

    /// Align item in its time-span; 0: at the beginning, 1: at the end, 0.5: centered
    open var itemAlignment: CGFloat = DefaultItemAlignment
    
    // MARK: - Scroll-direction
    
    open var scrollDirection: UICollectionViewScrollDirection = .vertical
    
    // MARK: - Time-scale
    
    var timeScale: CollectionViewTimelineLayoutScale = .minute
    
    func timeSpan(for rect: CGRect) -> TimeSpan
    {
        guard let collectionView = collectionView else { return (0,0) }
        
        let timeScale = actualDelegate.timeScaleFor(collectionView: collectionView, layout: self)
        
        let pointsPerTimeUnit = actualDelegate.collectionView(collectionView, layout: self, timeUnitLengthForTimeScale: timeScale)
    
        switch scrollDirection
        {
        case .horizontal:
            
            return (Double(rect.minX / pointsPerTimeUnit), Double(rect.maxX / pointsPerTimeUnit))

        case .vertical:
            
            return (Double(rect.minY / pointsPerTimeUnit), Double(rect.maxY / pointsPerTimeUnit))
        }
    }
    
    func points(for time: TimeInterval?, timeScale: CollectionViewTimelineLayoutScale, pointsPerTimeUnit: CGFloat) -> CGFloat
    {
        let time = time ?? 0
        
        return CGFloat(time) * pointsPerTimeUnit / CGFloat(timeScale.scale)
    }
    
    // MARK: Caches
    
    var cachedItemAttributes: [UICollectionViewLayoutAttributes] = []
    var cachedSupplementaryViewAttributes: [UICollectionViewLayoutAttributes] = []

    // MARK: - UICollectionViewLayout

    var contentBounds: CGRect? = nil
    
    override open var collectionViewContentSize: CGSize
    {
        let size = (contentBounds ?? .zero).size
        
        guard let collectionViewSize = collectionView?.bounds.size else { return size }
        
        switch scrollDirection
        {
        case .horizontal:
            return CGSize(width: size.width, height: collectionViewSize.height)
            
        case .vertical:
            return CGSize(width: collectionViewSize.width, height: size.height)
        }
    }
    
    func prepareLayoutAttributes(forSupplementaryViewsIn rect: CGRect) -> [UICollectionViewLayoutAttributes]
    {
        var intersectingSupplementaryViewAttributes: [UICollectionViewLayoutAttributes] = []
        
        let timeSpan = self.timeSpan(for: rect)
        
        let begin = Int(floor(timeSpan.begin ?? 0))
        let end = Int(floor(timeSpan.end ?? timeSpan.begin ?? 0))
        
        for t in begin...end
        {
            // 
        }
        
        return intersectingSupplementaryViewAttributes
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        //TODO: Only calculate and cache the cells intersecting rect
     
        let intersectingItemAttributes = cachedItemAttributes.filter({$0.frame.intersects(rect)})
        
        let intersectingSupplementaryViewAttributes = prepareLayoutAttributes(forSupplementaryViewsIn: rect)
        
        return intersectingItemAttributes + intersectingSupplementaryViewAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        if let attributes = cachedItemAttributes.first(where: { $0.indexPath == indexPath })
        {
            return attributes
        }

        return prepareLayoutAttributes(forItemAt: indexPath)
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard elementKind == CollectionViewTimelineSupp else { return nil }
        
        return cachedSupplementaryViewAttributes.first(where: { $0.indexPath == indexPath })
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        guard let currentBounds = collectionView?.bounds else { return false }
        
        return currentBounds != newBounds
    }
    
    @discardableResult
    func prepareLayoutAttributes(forItemAt indexPath: IndexPath, timeScale: CollectionViewTimelineLayoutScale? = nil, pointsPerTimeUnit: CGFloat? = nil) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = collectionView else { return nil }

        let timeScale = timeScale ?? actualDelegate.timeScaleFor(collectionView: collectionView, layout: self)
        
        let pointsPerTimeUnit = pointsPerTimeUnit ?? actualDelegate.collectionView(collectionView, layout: self, timeUnitLengthForTimeScale: timeScale)
        
        func points(for time: TimeInterval?) -> CGFloat
        {
            return pointsPerTimeUnit * CGFloat(time ?? 0) / CGFloat(timeScale.scale)
        }
        
        var bounds = collectionView.bounds
        
        bounds.inset(collectionView.contentInset)
        
        let center = bounds.center
        
        let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let timeSpan = actualDelegate.collectionView(collectionView, layout: self, timeSpanForItemAt: indexPath)
        
        itemAttributes.size = actualDelegate.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
        
        let itemBegin = points(for: timeSpan.begin)
        let itemEnd = points(for: timeSpan.end)
        
        let alignment = actualDelegate.collectionView(collectionView, layout: self, alignmentForItemAt: indexPath)
        
        switch scrollDirection
        {
        case .horizontal:
            itemAttributes.center = center.with(x: (itemBegin, itemEnd) ◊ alignment)
            
        case .vertical:
            itemAttributes.center = center.with(y: (itemBegin, itemEnd) ◊ alignment)
        }
        
        cache(itemAttributes: itemAttributes)
        
        return itemAttributes
    }
    
    override open func prepare()
    {
        // On rotation, UICollectionView sometimes calls prepare without calling invalidateLayout
        guard cachedItemAttributes.isEmpty, let collectionView = collectionView else { return }

        let timeScale = actualDelegate.timeScaleFor(collectionView: collectionView, layout: self)
        
        let pointsPerTimeUnit = actualDelegate.collectionView(collectionView, layout: self, timeUnitLengthForTimeScale: timeScale)

        for section in 0..<collectionView.numberOfSections
        {
            for item in 0..<collectionView.numberOfItems(inSection: section)
            {
                let indexPath = IndexPath(item: item, section: section)
                
                prepareLayoutAttributes(forItemAt: indexPath, timeScale: timeScale, pointsPerTimeUnit: pointsPerTimeUnit)
            }
        }
    }
    
    func cache(itemAttributes: UICollectionViewLayoutAttributes?)
    {
        guard let itemAttributes = itemAttributes else { return }
        
        cachedItemAttributes.append(itemAttributes)

        updateContentBounds(for: itemAttributes)
    }
    
    func updateContentBounds(for attributes: UICollectionViewLayoutAttributes)
    {
        if let currentContentBounds = contentBounds
        {
            contentBounds = currentContentBounds.union(attributes.frame)
        }
        else
        {
            contentBounds = attributes.frame
        }
    }
    
    override open func invalidateLayout()
    {
        super.invalidateLayout()
        
        cachedItemAttributes.removeAll()
    }
}


// MARK: - Defaults

extension CollectionViewTimelineLayout: CollectionViewTimelineLayoutDelegate
{
    public func timeScaleFor(collectionView: UICollectionView, layout: UICollectionViewLayout) -> CollectionViewTimelineLayoutScale
    {
        return timeScale
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, timeSpanForItemAt indexPath: IndexPath) -> (begin: TimeInterval?, end: TimeInterval?)
    {
        return (0,0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, timeUnitLengthForTimeScale: CollectionViewTimelineLayoutScale) -> CGFloat
    {
        return 200
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return itemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, alignmentForItemAt indexPath: IndexPath) -> CGFloat
    {
        return itemAlignment
    }
}
