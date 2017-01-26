//
//  UIViewController+Hierarchy.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/11/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

// MARK: - Hierarchy

extension UIViewController
{
    /**
     Ascends the parent-controller hierarchy until a controller of the specified type is encountered
     
     - parameter type: the (super)type of view-controller to look for
     - returns: the first controller in the parent-hierarchy encountered that is of the specified type
     */
    public func closestParentViewController<T/* where T: UIViewController*/>(ofType type: T.Type) -> T?
    {
        return (parent as? T) ?? parent?.closestParentViewController(ofType: type)
    }
    
    /**
     does a breadth-first search of the child-viewControllers hierarchy
     
     - parameter type: the (super)type of controller to look for
     - returns: an array of view-controllers of the specified type
     */
    public func closestChildViewControllers<T>(ofType type: T.Type) -> [T]
    {
        var children = childViewControllers
        
        while !children.isEmpty
        {
            let ts = children.cast(T.self)//mapFilter({ $0 as? T})
            
            if !ts.isEmpty
            {
                return ts
            }
            
            children = children.reduce([]) { $0 + $1.childViewControllers }
        }
        
        return []
    }
    
    /**
     does a breadth-first search of the child-viewControllers hierarchy
     
     - parameter type: the (super)type of controller to look for
     - returns: an array of view-controllers of the specified type
     */
    public func anyChildViewControllers<T>(ofType type: T.Type) -> T?
    {
        var children = childViewControllers
        
        while !children.isEmpty
        {
            let ts = children.cast(T.self)
            
            if !ts.isEmpty
            {
                return ts.first
            }
            
            children = children.reduce([]) { $0 + $1.childViewControllers }
        }
        
        return nil
    }
}
