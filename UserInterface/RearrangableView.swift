//
//  RearrangableView.swift
//  UserInterface
//
//  Created by Christian Otkjær on 02/08/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Graphics
import Collections

/// A view that allows rearraning of its subviews
open class RearrangableView: UIView
{
    fileprivate var privateDelegate : RearrangableViewDelegate { return delegate ?? defaultRearrangableViewDelegate }
    
    open weak var delegate: RearrangableViewDelegate?
    {
        didSet { updateGestureRecognizer() }
    }
    
    // MARK: - Init
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override open func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        translatesAutoresizingMaskIntoConstraints = false
        updateGestureRecognizer()
    }
    
    open override func addSubview(_ view: UIView)
    {
        super.addSubview(view)
        
        frames[view] = view.frame
    }
    
    // MARK: - Layout
    
    var frames = Dictionary<UIView, CGRect>()
    
    open override func layoutSubviews()
    {
        for subview in subviews
        {
            if let frame = frames[subview]
            {
                subview.frame = frame
            }
            
            subview.layoutSubviews()
        }
    }
    
    // MARK: - Gesture recognizer
    
    var rearrangeGestureRecognizer : UILongPressGestureRecognizer?
    
    func updateGestureRecognizer()
    {
        if let rearrangeGestureRecognizer = self.rearrangeGestureRecognizer
        {
            removeGestureRecognizer(rearrangeGestureRecognizer)
        }
        
        let rearrangeGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RearrangableView.handleRearrangeGestureRecognizer(_:)))
        
        rearrangeGestureRecognizer.allowableMovement = privateDelegate.rearrangingAllowableMovement()
        rearrangeGestureRecognizer.minimumPressDuration = privateDelegate.rearrangingMinimumPressDuration()
        rearrangeGestureRecognizer.numberOfTouchesRequired = privateDelegate.rearrangingNumberOfTouchesRequired()
        
        addGestureRecognizer(rearrangeGestureRecognizer)
        
        self.rearrangeGestureRecognizer = rearrangeGestureRecognizer
    }
    
    var centerOffset : CGPoint?
    var snapshotView : UIView?
    var viewBeingRearranged : UIView?
    
    @objc func handleRearrangeGestureRecognizer(_ gesture:UILongPressGestureRecognizer)
    {
        let point = gesture.location(in: self)
        
        switch gesture.state
        {
        case .began:
            
            guard let view = subviews.reversed().first(where: { $0.frame.contains(point) }) else { return }
            
            guard privateDelegate.rearrangingShouldBeginForView(view) else { return }
            
            viewBeingRearranged = view
            
            snapshotView = view.snapshotView(afterScreenUpdates: true)
            
            centerOffset = point - view.frame.center
            
        case .changed:
            
            guard let centerOffset = centerOffset, let view = viewBeingRearranged else { return }
            
            let proposedCenter = point - centerOffset
            
            let center = privateDelegate.rearrangingView(view, centerForProposedCenter: proposedCenter) ?? proposedCenter
            
            let options : UIViewAnimationOptions = [.beginFromCurrentState, .curveEaseOut]
            
            UIView.animate(withDuration: 0.05,
                                       delay: 0,
                                       options: options,
                                       animations: { view.center = center },
                                       completion: { completed in if completed { self.frames[view] = view.frame } })
            
        case .ended:
            
            guard let centerOffset = centerOffset, let view = viewBeingRearranged else { return }
            
            let proposedCenter = point - centerOffset
            
            let center = privateDelegate.rearrangingWillEndForView(view, withProposedCenter: proposedCenter) ?? proposedCenter
            
            let options : UIViewAnimationOptions = .beginFromCurrentState
            
            UIView.animate(withDuration: 0.25,
                                       delay: 0,
                                       options: options,
                                       animations: { view.center = center },
                                       completion:
                {
                    _ in
                    
                    self.frames[view] = view.frame
                    
                    self.centerOffset = nil
                   
                    self.privateDelegate.rearrangingDidEndForView(view)
            })
            
        default:
            
            print("Ignoring \(gesture.state)")
        }
    }
    
    // MARK: - Interface Builder
    
    override open func prepareForInterfaceBuilder()
    {
        setup()
    }
    
    override open var intrinsicContentSize : CGSize
    {
        return CGSize(width: UIViewNoIntrinsicMetric, height:  UIViewNoIntrinsicMetric)
    }
}
