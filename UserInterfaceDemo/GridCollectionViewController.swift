//
//  GridCollectionViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 16/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

private let reuseIdentifier = "Cell"

class GridCollectionViewController: UICollectionViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let numberOfDivisions = 5
        
        let gridLayout = CollectionViewGridLayout()
        gridLayout.numberOfDivisions = numberOfDivisions // Columns for .vertical, rows for .horizontal
        gridLayout.itemSpacing = 10
        
        collectionView?.collectionViewLayout = gridLayout
        
        for _ in 0..<100
        {
            data.append(Array(repeating: { 1 + Int(arc4random_uniform(UInt32(numberOfDivisions/2)))}, count: 100))
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Data
    
    var data: [[Int]] = []
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return data.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return data.get(section)?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        cell.firstSubview(ofType: UILabel.self)?.text = String(indexPath.item)
        
        return cell
    }
}

// MARK: - CollectionViewGridLayoutDelegate

extension GridCollectionViewController: CollectionViewGridLayoutDelegate
{
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, spanForItemAt indexPath: IndexPath) -> Int
    {
        return data.get(indexPath.section)?.get(indexPath.item) ?? 1
    }
}

