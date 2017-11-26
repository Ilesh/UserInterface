//
//  TimelineCollectionViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 16/02/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

private let reuseIdentifier = "Cell"

class TimelineCollectionViewController: UICollectionViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let timelineLayout = CollectionViewTimelineLayout()
        
        collectionView?.collectionViewLayout = timelineLayout
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 30
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        cell.firstSubview(ofType: UILabel.self)?.text = "\(indexPath.section)x\(indexPath.item)"
        
        return cell
    }
}

// MARK: - <#comment#>

extension TimelineCollectionViewController: CollectionViewTimelineLayoutDelegate
{
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, timeSpanForItemAt indexPath: IndexPath) -> TimeSpan
    {
        let begin = Double(indexPath.section * 100 + indexPath.item)
        let end = Double(indexPath.section * 100 + indexPath.item)
        return (begin, end)
    }
}
