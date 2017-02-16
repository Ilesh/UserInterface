//
//  CenteredCollectionViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 15/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import Arithmetic
import UserInterface

private let reuseIdentifier = "Cell"

// MARK: - Random

extension CGFloat
{
    init(random lower: CGFloat, upper: CGFloat)
    {
        self = (lower, upper) ◊ (CGFloat(arc4random_uniform(1000000)) / 1000000)
    }
}


class CenteredCollectionViewController: UICollectionViewController {

    var sizeFactors: [[CGFloat]] = []

    func randomSizeFactor() -> CGFloat
    {
        return CGFloat(random: 0.5, upper: 3)
    }
    
    func createSizeFactors()
    {
        for _ in 0..<Int(arc4random_uniform(10) + 20)
        {
            sizeFactors.append(Array(repeating: 0, count: sizeFactors.count + 1))
        }

        updateSizeFactors()
    }
    
    func updateSizeFactors()
    {
        for section in 0..<sizeFactors.count
        {
            for item in 0..<sizeFactors[section].count
            {
                sizeFactors[section][item] = randomSizeFactor()
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        collectionView?.collectionViewLayout = CenteredCollectionViewFlowLayout(flowLayout: collectionViewLayout as? UICollectionViewFlowLayout)
        
        createSizeFactors()
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return sizeFactors.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return sizeFactors.get(section)?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        cell.backgroundColor = UIColor(hue: CGFloat(random: 0, upper: 1), saturation: 0.8, brightness: 0.8, alpha: 1)
        
        cell.firstSubview(ofType: UILabel.self)?.text = String(indexPath.section)
        
        return cell
    }
    @IBAction func shuffleSizes(_ sender: UIBarButtonItem)
    {
        guard let collectionView = collectionView else { return }

        sender.isEnabled = false
        
        updateSizeFactors()
        
        collectionView.performBatchUpdates({ collectionView.collectionViewLayout.invalidateLayout() }) { (completed) in
            sender.isEnabled = true
        }
    }
}

// MARK: - <#comment#>

extension CenteredCollectionViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }

        guard let factor = sizeFactors.get(indexPath.section)?.get(indexPath.item) else { return .zero }
        
        var size = flowLayout.itemSize
        
        switch flowLayout.scrollDirection
        {
        case .horizontal:
            size.height *= factor //* collectionView.contentSize.height
            
        case .vertical:
            size.width *= factor //* collectionView.contentSize.width
        }
        
        return size
    }
}

