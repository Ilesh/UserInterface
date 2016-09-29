//
//  RearrangeViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 02/08/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

class RearrangeViewController: UIViewController
{
    @IBOutlet weak var rearrangableView: RearrangableView!
    {
        didSet { rearrangableView.delegate = self }
    }
}

// MARK: - <#comment#>

extension RearrangeViewController : RearrangableViewDelegate
{
    func rearrangingShouldBeginForView(_ view: UIView) -> Bool
    {
        guard let superview = view.superview else { return false }
        
        superview.bringSubview(toFront: view)
        
//        view.layer.shadowColor = UIColor.blackColor().CGColor
//        view.layer.shadowOffset = CGSize(width: 5, height: 5)
//        view.layer.shadowRadius = 7
//        view.layer.shadowOpacity = 0.4
        
        return true
    }
    
    func rearrangingWillEndForView(_ view: UIView, withProposedCenter center: CGPoint) -> CGPoint?
    {
        guard let superview = view.superview else { return nil }
        
        var frame = view.frame
        frame.center = center
        
        if frame.maxX > superview.bounds.maxX
        {
            frame.origin.x -= frame.maxX - superview.bounds.maxX
        }
        
        if frame.minX < superview.bounds.minX
        {
            frame.origin.x += superview.bounds.minX - frame.minX
        }
        
        if frame.maxY > superview.bounds.maxY
        {
            frame.origin.y -= frame.maxY - superview.bounds.maxY
        }
        
        if frame.minY < superview.bounds.minY
        {
            frame.origin.y += superview.bounds.minY - frame.minY
        }
        
        return frame.center
    }
    
    func rearrangingDidEndForView(_ view: UIView)
    {
//        view.layer.shadowColor = UIColor.clearColor().CGColor
//        view.layer.shadowOffset = CGSizeZero
//        view.layer.shadowRadius = 0
//        view.layer.shadowOpacity = 0
    }
}
