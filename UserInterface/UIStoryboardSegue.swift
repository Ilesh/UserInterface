//
//  UIStoryboardSegue.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - Typed Destination

public extension UIStoryboardSegue
{
    func destinationControllerAs<T>(_ type: T.Type) -> T?
    {
        return (destination as? T)
    }
}
