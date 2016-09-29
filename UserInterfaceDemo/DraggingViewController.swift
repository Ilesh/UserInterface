//
//  DraggingViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/08/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

class DraggingViewController: UIViewController
{
    @IBOutlet var draggableViews: [UIView]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        draggableViews.forEach{$0.draggingDelegate = self}
    }
}

// MARK: - ViewDraggingDelegate

extension DraggingViewController : ViewDraggingDelegate
{
    func draggingShouldBeginForView(_ view: UIView) -> Bool
    {
        guard let superview = view.superview else { return false }

        superview.bringSubview(toFront: view)
        
       let constraints = superview.constraints.filter({$0.firstItem as? UIView == view && $0.secondItem as? UIView == superview })
        
        superview.removeConstraints(constraints)
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowRadius = 7
        view.layer.shadowOpacity = 0.4
    
        return true
    }
    
    func draggingWillEndForView(_ view: UIView, withProposedCenter center: CGPoint) -> CGPoint?
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

    func draggingDidEndForView(_ view: UIView)
    {
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 0
        view.layer.shadowOpacity = 0.0
    }
}

