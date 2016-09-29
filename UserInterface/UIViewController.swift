//
//  UIViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 15/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit
import Graphics
import Collections

//MARK: - Cover View

public extension UIViewController
{
    fileprivate class CoverView : UIView
    {
        // MARK: - Init
        
        override init(frame: CGRect)
        {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            super.init(coder: aDecoder)
            setup()
        }
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        func setup()
        {
            backgroundColor = UIColor(white: 0, alpha: 0.25)
            alpha = 0
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            activityView.startAnimating()
            addSubview(activityView)
        }
        
        
        fileprivate override func layoutSubviews()
        {
            super.layoutSubviews()
            
            activityView.center = bounds.center
        }
    }
    
    func cover(_ duration: Double = 0.25, hideActivityView: Bool = false, completion: (() -> ())? = nil)
    {
        guard view.subviewsOfType(CoverView.self).isEmpty else { return }
        
        let coverView = CoverView(frame: view.bounds)

        coverView.activityView.isHidden = hideActivityView
        
        view.addSubview(coverView)
        
        UIView.animate(withDuration: duration,
            animations: {
                coverView.alpha = 1
            }, completion: { _ in completion?() }) 

    }
    
    public func uncover(_ duration: Double = 0.25, completion: (() -> ())? = nil)
    {
        let coverViews = view.subviewsOfType(CoverView.self)
        
        UIView.animate(withDuration: duration,
            animations: {
            coverViews.forEach { $0.alpha = 0 }
            }, completion: { (completed) -> Void in
                coverViews.forEach { $0.removeFromSuperview() }
                
                completion?()
        }) 
    }
}

// MARK: - On screen

extension UIViewController
{
    public func isViewLoadedAndShowing() -> Bool { return isViewLoaded && view.window != nil }
}

// MARK: - Hierarchy

extension UIViewController
{
    /**
    Ascends the parent-controller hierarchy until a controller of the specified type is encountered
    
    - parameter type: the (super)type of view-controller to look for
    - returns: the first controller in the parent-hierarchy encountered that is of the specified type
    */
    public func closestParentViewControllerOfType<T/* where T: UIViewController*/>(_ type: T.Type) -> T?
    {
        return (parent as? T) ?? parent?.closestParentViewControllerOfType(type)
    }
    
    /**
    does a breadth-first search of the child-viewControllers hierarchy
    
    - parameter type: the (super)type of controller to look for
    - returns: an array of view-controllers of the specified type
    */
    public func closestChildViewControllersOfType<T>(_ type: T.Type) -> [T]
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
    public func anyChildViewControllersOfType<T>(_ type: T.Type) -> T?
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


