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
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (section + 1) * 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "\((indexPath as NSIndexPath).section) x \((indexPath as NSIndexPath).row)"
        
        return cell
    }
    
    @IBOutlet weak var pathLabel: UILabel!
    
    @IBAction func handleTap(_ gesture: UITapGestureRecognizer)
    {
        switch gesture.state
        {
        case .began, .changed, .ended:
            
            let location = gesture.location(in: tableView)
            
            debugPrint("location: \(location)")
            
            if let indexPath = tableView.path(forLocation: location)
            {
                debugPrint("indexPath: \(indexPath)")
                pathLabel.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
            }
            else
            {
                pathLabel.text = "?"
            }
            
            debugPrint("view : \(String(describing: gesture.view))")
            
        default:
            debugPrint("state: \(gesture.state)")
        }
        
    }
}

