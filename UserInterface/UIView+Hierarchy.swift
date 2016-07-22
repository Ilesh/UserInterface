//
//  UIView+Hierarchy.swift
//  UserInterface
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - Hierarchy

public extension UIView
{
    var superviews : [UIView]
    {
        var superviews = Array<UIView>()
        
        var view = superview
        while view != nil
        {
            superviews.append(view!)
            view = view?.superview
        }
        
        return superviews.reverse()
    }
    
    
    /**
     Ascends the superview hierarchy until a view of the specified type is encountered
     
     - parameter type: the (super)type of view to look for
     - returns: the first superview in the hierarchy encountered that is of the specified type
     */
    func closestSuperviewOfType<T>(type: T.Type) -> T?
    {
        if let t = superview as? T
        {
            return t
        }
        else
        {
            return superview?.closestSuperviewOfType(T)
        }
    }
    
    func subviewsOfType<T>(type: T.Type) -> [T]
    {
        return subviews.reduce(subviews.cast(T), combine: { $0 + $1.subviewsOfType(T) } )
    }
    
    /**
     does a breadth-first search of the subview hierarchy
     
     - parameter type: the (super)type of view to look for
     - returns: an array of views of the specified type
     */
    func closestSubviewsOfType<T>(type: T.Type) -> [T]
    {
        var views = subviews
        
        while !views.isEmpty
        {
            let Ts = views.cast(T)
            
            if !Ts.isEmpty
            {
                return Ts
            }
            
            views = views.flatMap { $0.subviews }
            //            views = views.reduce([]) { $0 + $1.subviews }
        }
        
        return []
    }
    
    /**
     does a breadth-first search of the subview hierarchy
     
     - parameter type: the type of view to look for
     - returns: first view of the specified type found
     */
    func firstSubviewOfType<T>(type: T.Type) -> T?
    {
        return closestSubviewsOfType(type).first
    }
}
