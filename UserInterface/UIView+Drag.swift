//
//  UIView+Drag.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/08/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import Graphics

public protocol ViewDraggingDelegate : class
{
    /// Called to query the delegate if dragging should begin for the view
    func draggingShouldBeginForView(_ view: UIView) -> Bool
    
    /// Called to query the delegate for an alternate center for the view being dragged
    func draggingView(_ view: UIView, centerForProposedCenter center: CGPoint) -> CGPoint?
    
    /// Called to inform delegate that dragging will end and to query for an alternate ending center for the view
    func draggingWillEndForView(_ view: UIView, withProposedCenter center: CGPoint) -> CGPoint?
    
    /// Called to inform delegate that dragging has ended and the view has come to a stop
    func draggingDidEndForView(_ view: UIView)
    
    /// Called to query the delegate for the minimum period fingers must press on the view before dragging begins. The default duration is is 0.25 seconds.
    func draggingMinimumPressDurationForView(_ view: UIView) -> Double
    
    /// Called to query the delegate for the number of fingers that must be pressed on the view to drag it. The default is 1.
    func draggingNumberOfTouchesRequiredForView(_ view: UIView) -> Int
    
    /// Called to query the delegate for the maximum movement of the fingers on the view before dragging will not begin. The default is 10
    func draggingAllowableMovementForView(_ view: UIView) -> CGFloat
    
}

// MARK: - Defaults

public extension ViewDraggingDelegate
{
    func draggingNumberOfTouchesRequiredForView(_ view: UIView) -> Int
    {
        return 1
    }
    
    func draggingMinimumPressDurationForView(_ view: UIView) -> Double
    {
        return 0.25
    }
    
    func draggingAllowableMovementForView(_ view: UIView) -> CGFloat
    {
        return 10
    }
    
    func draggingShouldBeginForView(_ view: UIView) -> Bool
    {
        return true
    }

    func draggingView(_ view: UIView, centerForProposedCenter center: CGPoint) -> CGPoint?
    {
        return center
    }

    func draggingWillEndForView(_ view: UIView, withProposedCenter center: CGPoint) -> CGPoint?
    {
        return nil
    }
    
    func draggingDidEndForView(_ view: UIView)
    {
        //NOOP
    }
    
}

class DefaultDraggingDelegate: NSObject, ViewDraggingDelegate
{
    override init()
    {
        super.init()
    }
}

let defaultDraggingDelegate = DefaultDraggingDelegate()

class DragHandler : NSObject
{
    fileprivate weak var view : UIView?
    fileprivate weak var delegate : ViewDraggingDelegate?
    
    init(view: UIView, delegate : ViewDraggingDelegate?)
    {
        let d = delegate ?? defaultDraggingDelegate
        
        self.view = view
        self.delegate = d
        
        super.init()
        
        let dragGestureHandler = UILongPressGestureRecognizer(target: self, action: #selector(DragHandler.handleDragGesture(_:)))
        
        dragGestureHandler.allowableMovement = d.draggingAllowableMovementForView(view)
        dragGestureHandler.minimumPressDuration = d.draggingMinimumPressDurationForView(view)
        dragGestureHandler.numberOfTouchesRequired = d.draggingNumberOfTouchesRequiredForView(view)
        
        view.addGestureRecognizer(dragGestureHandler)
    }
    
    var centerOffset : CGPoint?
    
    @objc func handleDragGesture(_ gesture:UILongPressGestureRecognizer)
    {
        guard let view = view, let superview = view.superview else { return }
        
        let point = gesture.location(in: superview)
        
        switch gesture.state
        {
        case .began:
            guard delegate?.draggingShouldBeginForView(view) == true else { return }
            
            centerOffset = point - view.frame.center
            
        case .changed:
            
            guard let centerOffset = centerOffset else { return }
            
            let proposedCenter = point - centerOffset
            
            let center = delegate?.draggingView(view, centerForProposedCenter: proposedCenter) ?? proposedCenter
            
            let options : UIViewAnimationOptions = [.beginFromCurrentState, .curveEaseOut]
            
            UIView.animate(withDuration: 0.05,
                                       delay: 0,
                                       options: options,
                                       animations: { view.center = center },
                                       completion: nil)
            
        case .ended:
            
            guard let centerOffset = centerOffset else { return }
            
            let proposedCenter = point - centerOffset

            let center = delegate?.draggingWillEndForView(view, withProposedCenter: proposedCenter) ?? proposedCenter
            
            let options : UIViewAnimationOptions = .beginFromCurrentState
            
            UIView.animate(withDuration: 0.25,
                                       delay: 0,
                                       options: options,
                                       animations: { view.center = center },
                                       completion:
                {
                    _ in
                    
                    self.centerOffset = nil
                    
                    self.delegate?.draggingDidEndForView(view)
            })
            
        default:
            
            print("Ignoring \(gesture.state)")
        }
    }
}

private var dragHandlers = Array<DragHandler>()

extension UIView
{
    /// Assign a draggingDelegate to a view to make it draggable
    /// - note : To avoid memory leaks remember to set this to `nil` when the view is no longer needed or no longer should be draggable
    public var draggingDelegate : ViewDraggingDelegate?
        {
        get { return dragHandlers.find{ $0.view == self }?.delegate }
        
        set
        {
            if let index = dragHandlers.index(where: { $0.view == self})
            {
                if let delegate = newValue
                {
                    dragHandlers[index].delegate = delegate
                }
                else
                {
                    dragHandlers.remove(at: index)
                }
                
            }
            else if let delegate = newValue
            {
                dragHandlers.append(DragHandler(view: self, delegate: delegate))
            }
        }
    }
    
    /// Returns `true` if the view has a `draggingDelegate` assigned
    /// - note : the `draggingDelegate` may still prohibit the view from actually dragging
    public var draggable : Bool { get { return draggingDelegate != nil } }
}
