//
//  NSError.swift
//  UserInterface
//
//  Created by Christian Otkjær on 18/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

public extension NSError
{
    func presentAsAlert(handler:((UIAlertAction) -> ())? = nil)
    {
        UIApplication.topViewController()?.presentErrorAsAlert(self, animated: true, handler: handler)
    }
}
