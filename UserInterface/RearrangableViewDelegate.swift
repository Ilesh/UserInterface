//
//  RearrangableViewDelegate.swift
//  UserInterface
//
//  Created by Christian Otkjær on 02/08/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

public protocol RearrangableViewDelegate : class
{
    /// Called to query the delegate if rearranging should begin for the subview
    func rearrangingShouldBeginForView(_ view: UIView) -> Bool
    
    /// Called to query the delegate for an alternate center for the subview being rearranged
    func rearrangingView(_ view: UIView, centerForProposedCenter center: CGPoint) -> CGPoint?
    
    /// Called to inform delegate that rearranging will end and to query for an alternate ending center for the subview
    func rearrangingWillEndForView(_ view: UIView, withProposedCenter center: CGPoint) -> CGPoint?
    
    /// Called to inform delegate that rearranging has ended and the subview has come to a stop
    func rearrangingDidEndForView(_ view: UIView)
    
    /// Called to query the delegate for the minimum period fingers must press on any subview before rearranging begins. The default duration is is 0.25 seconds.
    func rearrangingMinimumPressDuration() -> Double
    
    /// Called to query the delegate for the number of fingers that must be pressed any subview to rearrange it. The default is 1.
    func rearrangingNumberOfTouchesRequired() -> Int
    
    /// Called to query the delegate for the maximum movement of the fingers allowed on any subview before rearranging will not begin. The default is 10
    func rearrangingAllowableMovement() -> CGFloat
    
}

public extension RearrangableViewDelegate
{
    /// Called to query the delegate if rearranging should begin for the subview
    func rearrangingShouldBeginForView(_ view: UIView) -> Bool
    {
        return true
    }
    
    /// Called to query the delegate for an alternate center for the subview being rearranged
    func rearrangingView(_ view: UIView, centerForProposedCenter center: CGPoint) -> CGPoint?
    {
        return nil
    }
    
    /// Called to inform delegate that rearranging will end and to query for an alternate ending center for the subview
    func rearrangingWillEndForView(_ view: UIView, withProposedCenter center: CGPoint) -> CGPoint?
    {
        return nil
    }
    
    /// Called to inform delegate that rearranging has ended and the subview has come to a stop
    func rearrangingDidEndForView(_ view: UIView)
    {
        //NOOP
    }
    
    /// Called to query the delegate for the minimum period fingers must press on any subview before rearranging begins. The default duration is is 0.25 seconds.
    func rearrangingMinimumPressDuration() -> Double
    {
        return 0.25
    }
    
    /// Called to query the delegate for the number of fingers that must be pressed any subview to rearrange it. The default is 1.
    func rearrangingNumberOfTouchesRequired() -> Int
    {
        return 1
    }
    
    /// Called to query the delegate for the maximum movement of the fingers allowed on any subview before rearranging will not begin. The default is 10
    func rearrangingAllowableMovement() -> CGFloat
    {
        return 10
    }
}

class DefaultRearrangableViewDelegate : RearrangableViewDelegate {}

let defaultRearrangableViewDelegate = DefaultRearrangableViewDelegate()
