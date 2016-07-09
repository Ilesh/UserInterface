//
//  NSError.swift
//  UserInterface
//
//  Created by Christian Otkjær on 18/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

extension ErrorType
{
    public func presentAsAlert(handler:((UIAlertAction) -> ())? = nil)
    {
        UIApplication.topViewController()?.presentErrorAsAlert(self, animated: true, handler: handler)
    }
}

// MARK: - Error

public extension UIViewController
{
    func presentErrorAsAlert<E:ErrorType>(error: E?, animated: Bool = true, handler: ((UIAlertAction) -> ())? = nil)
    {
        guard let error = error else { return }
        
        let alertController = UIAlertController(title: UIKitLocalizedString("Error"), message: String(error), preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Done"), style: .Default, handler: handler))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: animated) { debugPrint("Showing error: \(self)") } } )
    }

    func presentErrorAsAlert(error: NSError?, animated: Bool = true, handler: ((UIAlertAction) -> ())? = nil)
    {
        guard let error = error else { return }
        
        let alertController = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Done"), style: .Default, handler: handler))
        
        //TODO: localizedRecoveryOptions
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: animated) { debugPrint("Showing error: \(self)") } } )
    }

}
