//
//  ViewController.swift
//  UserInterfaceDemo
//
//  Created by Christian Otkjær on 31/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

class TableViewController: UITableViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (section + 1) * 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel?.text = "\(indexPath.section) x \(indexPath.row)"
        
        return cell
    }
    
    @IBOutlet weak var pathLabel: UILabel!
    
    @IBAction func handleTap(gesture: UITapGestureRecognizer)
    {
        switch gesture.state
        {
        case .Began, .Changed, .Ended:
            
            let location = gesture.locationInView(tableView)
            
            debugPrint("location: \(location)")
            
            if let indexPath = tableView.indexPathForLocation(location)
            {
            debugPrint("indexPath: \(indexPath)")
            pathLabel.text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            }
            else
            {
                pathLabel.text = "?"
            }
            
            debugPrint("view : \(gesture.view)")
            
        default:
            debugPrint("state: \(gesture.state)")
        }
        
    }
}

