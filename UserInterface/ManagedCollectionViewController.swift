//
//  ManagedCollectionViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 23/06/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

public class Section
{
    let name: String
    
    var elements: [Any]
    
    init(name: String)
    {
        self.name = name
        elements = [Any]()
    }
    
    func addRecord(element: Any)
    {
        elements.append(element)
    }
    
    func elementAtIndex(index: Int) -> Any?
    {
        guard index < elements.endIndex && index >= 0 else { return nil }
        
        return elements[index]
    }
    
    var numberOfRecords: Int { return elements.count }
}


public class SectionedElementsManager
{
    var delegate : SectionedElementsManagerDelegate?
    
    var sections : [Section]?
    
    func elementAtIndexPath<Element>(indexPath: NSIndexPath?) -> Element?
    {
        guard let sectionIndex = indexPath?.section, let elementIndex = indexPath?.item else { return nil }
        
        guard sectionIndex >= 0 && elementIndex >= 0 else { return nil }
        
        guard let sections = self.sections else { return nil }
        
        guard sectionIndex < sections.endIndex else { return nil }
        
        return sections[sectionIndex].elementAtIndex(elementIndex) as? Element
    }
    
    func indexPathForRecord(element: Any?, comparator: (Any, Any) -> Bool) -> NSIndexPath?
    {
        guard let element = element else { return nil }
                
        for (sectionIndex, sectionInfo) in (sections ?? []).enumerate()
        {
            for (elementIndex, elementToTest) in (sectionInfo.elements ?? []).enumerate()
            {
                if comparator(elementToTest, element)
                {
                    return NSIndexPath(forItem: elementIndex, inSection: sectionIndex)
                }
            }
        }
        
        return nil
    }

}

public protocol SectionedElementsManagerDelegate : class // : NSObjectProtocol
{
    /**
     Notifies the delegate that a new element has been inserted.
     - parameter manager: manager instance that noticed the change
     - parameter indexPath: new indexPath of the element
     - note: Only the inserted element is reported. It is assumed that all elements that come after the affected element in the section are moved accordingly, but these moves are not reported.
     */
    func manager(manager:SectionedElementsManager, didInsertElementAtIndexPath indexPath: NSIndexPath)
    
    /**
     Notifies the delegate that a element has been deleted from the fetched elements.
     - parameter manager: manager instance that noticed the change on its fetched elements
     - parameter indexPath: indexPath where the element used to reside
     - note: Only the deleted element is reported. It is assumed that all elements that come after the affected element in the section are moved accordingly, but these moves are not reported.
     */
    func manager(manager:SectionedElementsManager, didDeleteElementAtIndexPath indexPath: NSIndexPath)
    
    /**
     Notifies the delegate that an alerady fetched element has been moved from one indexpath to another.
     - parameter manager: manager instance that noticed the change on its fetched elements
     - parameter atIndexPath: indexPath where the element used to reside
     - parameter toIndexPath: indexPath where the element now resides
     - note: The Move element is reported when the changed attribute on the element is one of the sort descriptors used in the fetch request. An update of the element is assumed; no separate update message is reported to the delegate.
     */
    func manager(manager: SectionedElementsManager, didMoveElementAtIndexPath atIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    
    /**
     Notifies the delegate that an already fetched element has been updated.
     - parameter manager: manager instance that noticed the change on its fetched elements
     - parameter element: element that was updated
     - parameter indexPath: indexPath of the updated element
     - note: The Update element is reported when a elements state changes, and the changed attributes are NOT part of the sort keys.
     */
    func manager(manager: SectionedElementsManager, didUpdateElementAtIndexPath indexPath: NSIndexPath)
    
    /**
     Notifies the delegate of inserted sections
     
     - parameter manager: manager instance that noticed the change on its sections
     - parameter section: the inserted empty section
     - parameter sectionIndex: the index at which the section was inserted
     - note: Changes on sections are reported before changes on elements
     */
    func manager(manager: SectionedElementsManager, didInsertSectionAtIndex sectionIndex: Int)
    
    /**
     Notifies the delegate of deleted sections
     - parameter manager: manager instance that noticed the change on its sections
     - parameter sectionIndex: the index where the section used to reside
     - note: Changes on sections are reported before changes on elements
     */
    func manager(manager: SectionedElementsManager, didDeleteSectionAtIndex sectionIndex: Int)
    
    /**
     Notifies the delegate that section and element changes are about to be processed and notifications will be sent
     */
    func managerWillChangeContent(manager: SectionedElementsManager)
    
    /**
     Notifies the delegate that all section and element changes have been sent.
     */
    func managerDidChangeContent(manager: SectionedElementsManager)
    
    /* Asks the delegate to return the corresponding section index entry for a given section name.	Does not enable NSFetchedResultsController change tracking.
     If this method isn't implemented by the delegate, the default implementation returns the capitalized first letter of the section name (seee NSFetchedResultsController sectionIndexTitleForSectionName:)
     Only needed if a section index is used.
     
     func manager(manager: SectionedElementsManager, sectionIndexTitleForSectionName sectionName: String) -> String?
     */
}


private let CellReuseIdentifier = "Cell"

public class ManagedCollectionViewController: UICollectionViewController
{
    public var elementsManager : SectionedElementsManager?
    {
        didSet { updateSectionedElementsManager(oldValue) }
    }
    
    func updateSectionedElementsManager(oldManager : SectionedElementsManager?)
    {
        guard oldManager !== elementsManager else { return }
        
        if oldManager?.delegate === self { oldManager?.delegate = nil }
        
        elementsManager?.delegate = self
    }
    
    // MARK: - Delegate helpers
    
    /// Set this if you are updating the elements "manually", e.g. when rearranging cells
    public var ignoreManagerChanges: Bool = false
    
    var blockOperation : NSBlockOperation?
    var shouldReloadCollectionView = false { didSet { if shouldReloadCollectionView { blockOperation = nil } } }
}

// MARK: - SectionedElementsManagerDelegate

extension ManagedCollectionViewController: SectionedElementsManagerDelegate
{
    public func managerWillChangeContent(manager: SectionedElementsManager)
    {
        guard !ignoreManagerChanges else { return }
        
        shouldReloadCollectionView = false
        blockOperation = NSBlockOperation()
    }
    
    public func managerDidChangeContent(manager: SectionedElementsManager)
    {
        // Checks if we should reload the collection view to aleviate a bug @ http://openradar.appspot.com/12954582
        if shouldReloadCollectionView
        {
            collectionView?.reloadData()
        }
        else if let blockOperation = blockOperation, let collectionView = collectionView
        {
            collectionView.performBatchUpdates(blockOperation.start, completion: nil)
        }
    }
    
    public func manager(manager: SectionedElementsManager, didInsertSectionAtIndex sectionIndex: Int)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.insertSection( sectionIndex ) }
    }
    
    public func manager(manager: SectionedElementsManager, didDeleteSectionAtIndex sectionIndex: Int)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.deleteSection( sectionIndex ) }
    }
    
    public func manager(manager: SectionedElementsManager, didInsertElementAtIndexPath indexPath: NSIndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        if collectionView.numberOfSections() > 0
        {
            if collectionView.numberOfItemsInSection( indexPath.section ) == 0
            {
                shouldReloadCollectionView = true
            }
            else
            {
                blockOperation?.addExecutionBlock { collectionView.insertItemAtIndexPath( indexPath ) }
            }
        }
        else
        {
            shouldReloadCollectionView = true
        }
    }
    
    public func manager(manager: SectionedElementsManager, didUpdateElementAtIndexPath indexPath: NSIndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.reloadItemAtIndexPath( indexPath ) }
    }
    
    public func manager(manager: SectionedElementsManager, didDeleteElementAtIndexPath indexPath: NSIndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        if collectionView.numberOfItemsInSection( indexPath.section ) == 1
        {
            shouldReloadCollectionView = true
        }
        else
        {
            blockOperation?.addExecutionBlock { collectionView.deleteItemAtIndexPath( indexPath ) }
        }
    }
    
    public func manager(manager: SectionedElementsManager, didMoveElementAtIndexPath atIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.moveItemFromIndexPath(atIndexPath, toIndexPath: toIndexPath ) }
    }
}