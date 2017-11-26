//
//  PickerViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 21/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView?
    {
        didSet
        {
            pickerView?.dataSource = self
            pickerView?.selectorColor = .clear
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}

// MARK: - UIPickerViewDataSource

extension PickerViewController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 60
    }
}

// MARK: - UIPickerViewDelegate

extension PickerViewController: UIPickerViewDelegate
{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(row)
    }
}


