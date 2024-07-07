//
//  JTAppleCalendarDelegates.swift
//  Pods
//
//  Created by Jay Thomas on 2016-05-12.
//
//


// MARK: scrollViewDelegates
extension JTAppleCalendarView: UIScrollViewDelegate {
    /// Tells the delegate when the user finishes scrolling the content.
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Update the date when user lifts finger
        delayRunOnGlobalThread(0.0, qos: DispatchQoS.QoSClass.userInitiated) { 
            let currentSegmentDates = self.currentCalendarDateSegment()
            delayRunOnMainThread(0.0, closure: { 
                self.delegate?.calendar(self, didScrollToDateSegmentStartingWithdate: currentSegmentDates.startDate, endingWithDate: currentSegmentDates.endDate)
            })
        }

        if pagingEnabled || !cellSnapsToEdge { return }
        // Snap to grid setup
        var contentOffset: CGFloat = 0,
        theTargetContentOffset: CGFloat = 0,
        directionVelocity: CGFloat = 0,
        contentSize: CGFloat = 0,
        frameSize: CGFloat = 0

        if direction == .horizontal {
            contentOffset = scrollView.contentOffset.x
            theTargetContentOffset = targetContentOffset.pointee.x
            directionVelocity = velocity.x
            contentSize = scrollView.contentSize.width
            frameSize = scrollView.frame.size.width
        } else {
            contentOffset = scrollView.contentOffset.y
            theTargetContentOffset = targetContentOffset.pointee.y
            directionVelocity = velocity.y
            contentSize = scrollView.contentSize.height
            frameSize = scrollView.frame.size.height
        }
        
        let diff = abs(theTargetContentOffset - contentOffset)
        
        let calcTestPoint = {(velocity: CGFloat) -> CGPoint in
            var recalcOffset: CGFloat
            if velocity >= 0 {
                recalcOffset = theTargetContentOffset - (diff * self.scrollResistance)
            } else {
                recalcOffset = theTargetContentOffset + (diff * self.scrollResistance)
            }
            
            let retval: CGPoint
            if self.direction == .vertical {
                retval = CGPoint(x: 0, y: recalcOffset)
            } else {
                if headerViewXibs.count < 1 {
                    retval = CGPoint(x: recalcOffset, y: 0)
                } else {
                    let targetSection =  Int(recalcOffset / self.calendarView.frame.size.width)
                    let headerSize = self.referenceSizeForHeaderInSection(targetSection)
                    retval = CGPoint(x: recalcOffset, y: headerSize.height)
                }
            }
            
            return retval
        }
        
        let setTestPoint = {(testPoint: CGPoint) in
            if let indexPath = self.calendarView.indexPathForItem(at: testPoint) {
                if let attributes = self.calendarView.layoutAttributesForItem(at: indexPath) {
                    
                    if self.direction == .vertical {
                        let targetOffset = attributes.frame.origin.y
                        targetContentOffset.pointee = CGPoint(x: 0, y: targetOffset)
                    } else {
                        let targetOffset = attributes.frame.origin.x
                        targetContentOffset.pointee = CGPoint(x: targetOffset, y: 0)
                    }
                }
            }
        }
        
        if (directionVelocity == 0) {
            guard let
                    indexPath = calendarView.indexPathForItem(at: calcTestPoint(directionVelocity)),
                    let attributes = calendarView.layoutAttributesForItem(at: indexPath) else {
                        return //                            print("Landed on a header")
            }
            
            if self.direction == .vertical {
                if theTargetContentOffset <= attributes.frame.origin.y + (attributes.frame.height / 2)  {
                    let targetOffset = attributes.frame.origin.y
                    targetContentOffset.pointee = CGPoint(x: 0, y: targetOffset)
                } else {
                    let targetOffset = attributes.frame.origin.y + attributes.frame.height
                    targetContentOffset.pointee = CGPoint(x: 0, y: targetOffset)
                }
            } else {
                if theTargetContentOffset <= attributes.frame.origin.x + (attributes.frame.width / 2)  {
                    let targetOffset = attributes.frame.origin.x
                    targetContentOffset.pointee = CGPoint(x: targetOffset, y: 0)
                } else {
                    let targetOffset = attributes.frame.origin.x + attributes.frame.width
                    targetContentOffset.pointee = CGPoint(x: targetOffset, y: 0)
                }
            }
        } else if (directionVelocity > 0) { // scrolling down or left
            if contentOffset > (contentSize - frameSize) { return }
            setTestPoint(calcTestPoint(directionVelocity))
        } else { // Scrolling back up
            if contentOffset >= 1 {
                setTestPoint(calcTestPoint(directionVelocity))
            }
        }
    }
    
    /// Tells the delegate when a scrolling animation in the scroll view concludes.
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let shouldTrigger = triggerScrollToDateDelegate, shouldTrigger == true {
            scrollViewDidEndDecelerating(scrollView)
            triggerScrollToDateDelegate = nil
        }
        executeDelayedTasks()
        
        // A scroll was just completed.
        scrollInProgress = false
    }
    
    /// Tells the delegate that the scroll view has ended decelerating the scrolling movement.
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentSegmentDates = currentCalendarDateSegment()
        self.delegate?.calendar(self, didScrollToDateSegmentStartingWithdate: currentSegmentDates.startDate, endingWithDate: currentSegmentDates.endDate)
    }
}

// MARK: CollectionView delegates
extension JTAppleCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    /// Asks your data source object to provide a supplementary view to display in the collection view.
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseIdentifier: String
        guard let date = dateFromSection(indexPath.section) else {
            assert(false, "Date could not be generated fro section. This is a bug. Contact the developer")
            return UICollectionReusableView()
        }
        
        // Get the reuse identifier
        if headerViewXibs.count == 1 {
            reuseIdentifier = headerViewXibs[0]
        } else {
            guard let identifier = delegate?.calendar(self, sectionHeaderIdentifierForDate: date), headerViewXibs.contains(identifier) else {
                assert(false, "Identifier was not registered")
                return UICollectionReusableView()
            }
            reuseIdentifier = identifier
        }
        
        currentXib = reuseIdentifier
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: reuseIdentifier,
                                                                               for: indexPath) as! JTAppleCollectionReusableView
        delegate?.calendar(self, isAboutToDisplaySectionHeader: headerView.view, date: date, identifier: reuseIdentifier)
        return headerView
    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        restoreSelectionStateForCellAtIndexPath(indexPath)
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! JTAppleDayCell
        dayCell.updateCellView(dayCell.cellView)
        dayCell.bounds.origin = CGPoint(x: 0, y: 0)
        
        let date = dateFromPath(indexPath)!
        let cellState = cellStateFromIndexPath(indexPath, withDate: date)
        
        delegate?.calendar(self, isAboutToDisplayCell: dayCell.cellView, date: date, cellState: cellState)

        return dayCell
    }
    /// Asks your data source object for the number of sections in the collection view. The number of sections in collectionView.
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if !xibFileValid() {
            return 0
        }
        
        return monthInfo.count
    }

    /// Asks your data source object for the number of items in the specified section. The number of rows in section.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  MAX_NUMBER_OF_DAYS_IN_WEEK * cachedConfiguration.numberOfRows
    }
    /// Asks the delegate if the specified item should be selected. true if the item should be selected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if let
            delegate = self.delegate,
            let dateUserSelected = dateFromPath(indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell,
            cellWasNotDisabledOrHiddenByTheUser(cell) {
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateUserSelected)
            return delegate.calendar(self, canSelectDate: dateUserSelected, cell: cell.cellView, cellState: cellState)
        }
        return false
    }
    
    func cellWasNotDisabledOrHiddenByTheUser(_ cell: JTAppleDayCell) -> Bool {
        return cell.cellView.isHidden == false && cell.cellView.isUserInteractionEnabled == true
    }
    /// Tells the delegate that the item at the specified path was deselected. The collection view calls this method when the user successfully deselects an item in the collection view. It does not call this method when you programmatically deselect items.
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let
            delegate = self.delegate,
            let dateDeselectedByUser = dateFromPath(indexPath) {
            
            // Update model
            deleteCellFromSelectedSetIfSelected(indexPath)
            
            let selectedCell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell // Cell may be nil if user switches month sections
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateDeselectedByUser, cell: selectedCell) // Although the cell may be nil, we still want to return the cellstate
            
            if let anUnselectedCounterPartIndexPath = deselectCounterPartCellIndexPath(indexPath, date: dateDeselectedByUser, dateOwner: cellState.dateBelongsTo) {
                deleteCellFromSelectedSetIfSelected(anUnselectedCounterPartIndexPath)
                // ONLY if the counterPart cell is visible, then we need to inform the delegate
                batchReloadIndexPaths([anUnselectedCounterPartIndexPath])
            }
            
            delegate.calendar(self, didDeselectDate: dateDeselectedByUser, cell: selectedCell?.cellView, cellState: cellState)
        }
    }
    
    /// Asks the delegate if the specified item should be deselected. true if the item should be deselected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let
            delegate = self.delegate,
            let dateDeSelectedByUser = dateFromPath(indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell, cellWasNotDisabledOrHiddenByTheUser(cell) {
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateDeSelectedByUser)
            return delegate.calendar(self, canDeselectDate: dateDeSelectedByUser, cell: cell.cellView, cellState:  cellState)
        }
        return false
    }
    /// Tells the delegate that the item at the specified index path was selected. The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let
            delegate = self.delegate,
            let dateSelectedByUser = dateFromPath(indexPath) {

            // Update model
            addCellToSelectedSetIfUnselected(indexPath, date:dateSelectedByUser)
            let selectedCell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell
            
            // If cell has a counterpart cell, then select it as well
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateSelectedByUser, cell: selectedCell)
            if let aSelectedCounterPartIndexPath = selectCounterPartCellIndexPathIfExists(indexPath, date: dateSelectedByUser, dateOwner: cellState.dateBelongsTo) {
                // ONLY if the counterPart cell is visible, then we need to inform the delegate
                delayRunOnMainThread(0.0, closure: {
                    self.batchReloadIndexPaths([aSelectedCounterPartIndexPath])
                })
            }
            delegate.calendar(self, didSelectDate: dateSelectedByUser, cell: selectedCell?.cellView, cellState: cellState)
        }
    }
}
