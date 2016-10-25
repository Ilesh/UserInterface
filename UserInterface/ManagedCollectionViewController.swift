//
//  ManagedCollectionViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 23/06/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

open class Section
{
    let name: String
    
    var elements: [Any]
    
    init(name: String)
    {
        self.name = name
        elements = [Any]()
    }
    
    func addRecord(_ element: Any)
    {
        elements.append(element)
    }
    
    func elementAtIndex(_ index: Int) -> Any?
    {
        guard index < elements.endIndex && index >= 0 else { return nil }
        
        return elements[index]
    }
    
    var numberOfRecords: Int { return elements.count }
}


open class SectionedElementsManager
{
    var delegate : SectionedElementsManagerDelegate?
    
    var sections : [Section]?
    
    func elementAtIndexPath<Element>(_ indexPath: IndexPath?) -> Element?
    {
        guard let sectionIndex = (indexPath as NSIndexPath?)?.section, let elementIndex = (indexPath as NSIndexPath?)?.item else { return nil }
        
        guard sectionIndex >= 0 && elementIndex >= 0 else { return nil }
        
        guard let sections = self.sections else { return nil }
        
        guard sectionIndex < sections.endIndex else { return nil }
        
        return sections[sectionIndex].elementAtIndex(elementIndex) as? Element
    }
    
    func indexPathForRecord(_ element: Any?, comparator: (Any, Any) -> Bool) -> IndexPath?
    {
        guard let element = element else { return nil }
                
        for (sectionIndex, sectionInfo) in (sections ?? []).enumerated()
        {
            for (elementIndex, elementToTest) in sectionInfo.elements.enumerated()
            {
                if comparator(elementToTest, element)
                {
                    return IndexPath(item: elementIndex, section: sectionIndex)
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
    func manager(_ manager:SectionedElementsManager, didInsertElementAtIndexPath indexPath: IndexPath)
    
    /**
     Notifies the delegate that a element has been deleted from the fetched elements.
     - parameter manager: manager instance that noticed the change on its fetched elements
     - parameter indexPath: indexPath where the element used to reside
     - note: Only the deleted element is reported. It is assumed that all elements that come after the affected element in the section are moved accordingly, but these moves are not reported.
     */
    func manager(_ manager:SectionedElementsManager, didDeleteElementAtIndexPath indexPath: IndexPath)
    
    /**
     Notifies the delegate that an alerady fetched element has been moved from one indexpath to another.
     - parameter manager: manager instance that noticed the change on its fetched elements
     - parameter atIndexPath: indexPath where the element used to reside
     - parameter toIndexPath: indexPath where the element now resides
     - note: The Move element is reported when the changed attribute on the element is one of the sort descriptors used in the fetch request. An update of the element is assumed; no separate update message is reported to the delegate.
     */
    func manager(_ manager: SectionedElementsManager, didMoveElementAtIndexPath atIndexPath: IndexPath, toIndexPath: IndexPath)
    
    /**
     Notifies the delegate that an already fetched element has been updated.
     - parameter manager: manager instance that noticed the change on its fetched elements
     - parameter element: element that was updated
     - parameter indexPath: indexPath of the updated element
     - note: The Update element is reported when a elements state changes, and the changed attributes are NOT part of the sort keys.
     */
    func manager(_ manager: SectionedElementsManager, didUpdateElementAtIndexPath indexPath: IndexPath)
    
    /**
     Notifies the delegate of inserted sections
     
     - parameter manager: manager instance that noticed the change on its sections
     - parameter section: the inserted empty section
     - parameter sectionIndex: the index at which the section was inserted
     - note: Changes on sections are reported before changes on elements
     */
    func manager(_ manager: SectionedElementsManager, didInsertSectionAtIndex sectionIndex: Int)
    
    /**
     Notifies the delegate of deleted sections
     - parameter manager: manager instance that noticed the change on its sections
     - parameter sectionIndex: the index where the section used to reside
     - note: Changes on sections are reported before changes on elements
     */
    func manager(_ manager: SectionedElementsManager, didDeleteSectionAtIndex sectionIndex: Int)
    
    /**
     Notifies the delegate that section and element changes are about to be processed and notifications will be sent
     */
    func managerWillChangeContent(_ manager: SectionedElementsManager)
    
    /**
     Notifies the delegate that all section and element changes have been sent.
     */
    func managerDidChangeContent(_ manager: SectionedElementsManager)
    
    /* Asks the delegate to return the corresponding section index entry for a given section name.	Does not enable NSFetchedResultsController change tracking.
     If this method isn't implemented by the delegate, the default implementation returns the capitalized first letter of the section name (seee NSFetchedResultsController sectionIndexTitleForSectionName:)
     Only needed if a section index is used.
     
     func manager(manager: SectionedElementsManager, sectionIndexTitleForSectionName sectionName: String) -> String?
     */
}


private let CellReuseIdentifier = "Cell"

open class ManagedCollectionViewController: UICollectionViewController
{
    open var elementsManager : SectionedElementsManager?
    {
        didSet { updateSectionedElementsManager(oldValue) }
    }
    
    func updateSectionedElementsManager(_ oldManager : SectionedElementsManager?)
    {
        guard oldManager !== elementsManager else { return }
        
        if oldManager?.delegate === self { oldManager?.delegate = nil }
        
        elementsManager?.delegate = self
    }
    
    // MARK: - Delegate helpers
    
    /// Set this if you are updating the elements "manually", e.g. when rearranging cells
    open var ignoreManagerChanges: Bool = false
    
    var blockOperation : BlockOperation?
    var shouldReloadCollectionView = false { didSet { if shouldReloadCollectionView { blockOperation = nil } } }
}

// MARK: - SectionedElementsManagerDelegate

extension ManagedCollectionViewController: SectionedElementsManagerDelegate
{
    public func managerWillChangeContent(_ manager: SectionedElementsManager)
    {
        guard !ignoreManagerChanges else { return }
        
        shouldReloadCollectionView = false
        blockOperation = BlockOperation()
    }
    
    public func managerDidChangeContent(_ manager: SectionedElementsManager)
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
    
    public func manager(_ manager: SectionedElementsManager, didInsertSectionAtIndex sectionIndex: Int)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.insert(sectionAt: sectionIndex ) }
    }
    
    public func manager(_ manager: SectionedElementsManager, didDeleteSectionAtIndex sectionIndex: Int)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.delete(sectionAt: sectionIndex) }
    }
    
    public func manager(_ manager: SectionedElementsManager, didInsertElementAtIndexPath indexPath: IndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        if collectionView.numberOfSections > 0
        {
            if collectionView.numberOfItems( inSection: (indexPath as NSIndexPath).section ) == 0
            {
                shouldReloadCollectionView = true
            }
            else
            {
                blockOperation?.addExecutionBlock { collectionView.insert(itemAt: indexPath ) }
            }
        }
        else
        {
            shouldReloadCollectionView = true
        }
    }
    
    public func manager(_ manager: SectionedElementsManager, didUpdateElementAtIndexPath indexPath: IndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.reload(itemAt: indexPath ) }
    }
    
    public func manager(_ manager: SectionedElementsManager, didDeleteElementAtIndexPath indexPath: IndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        if collectionView.numberOfItems( inSection: (indexPath as NSIndexPath).section ) == 1
        {
            shouldReloadCollectionView = true
        }
        else
        {
            blockOperation?.addExecutionBlock { collectionView.delete(itemAt: indexPath ) }
        }
    }
    
    public func manager(_ manager: SectionedElementsManager, didMoveElementAtIndexPath atIndexPath: IndexPath, toIndexPath: IndexPath)
    {
        guard !ignoreManagerChanges else { return }
        
        guard let collectionView = collectionView else { return }
        
        blockOperation?.addExecutionBlock { collectionView.moveItem(at:atIndexPath, to: toIndexPath ) }
    }
}
