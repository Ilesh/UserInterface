//
//  UINavigationViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 02/08/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - Push and Pop

 extension UINavigationController
{
    func doInTransaction(_ block: ()->(), completion: @escaping ()->())
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        block()
        CATransaction.commit()
    }
    
    public func popViewControllerWithHandler(_ completion: @escaping ()->())
    {
        doInTransaction({ popViewController(animated: true) }, completion: completion)
        
//        CATransaction.begin()
//        CATransaction.setCompletionBlock(completion)
//        popViewControllerAnimated(true)
//        CATransaction.commit()
    }
    
    public func pushViewController(_ viewController: UIViewController, completion: @escaping ()->())
    {
        doInTransaction({pushViewController(viewController, animated: true)}, completion: completion)
        
//        CATransaction.begin()
//        CATransaction.setCompletionBlock(completion)
//        pushViewController(viewController, animated: true)
//        CATransaction.commit()
    }
}
