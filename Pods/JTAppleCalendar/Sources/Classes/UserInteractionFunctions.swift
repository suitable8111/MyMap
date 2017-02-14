//
//  UserInteractionFunctions.swift
//  Pods
//
//  Created by Jay Thomas on 2016-05-12.
//
//


extension JTAppleCalendarView {
    /// Returns the cellStatus of a date that is visible on the screen. If the row and column for the date cannot be found, then nil is returned
    /// - Paramater row: Int row of the date to find
    /// - Paramater column: Int column of the date to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatusForDateAtRow(_ row: Int, column: Int) -> CellState? {
        if // the row or column falls within an invalid range
            row < 0 || row >= cachedConfiguration.numberOfRows ||
                column < 0 || column >= MAX_NUMBER_OF_DAYS_IN_WEEK {
            return nil
        }
        
        let Offset: Int
        let convertedRow: Int
        let convertedSection: Int
        if direction == .horizontal {
            Offset = Int(round(calendarView.contentOffset.x / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.width))
            convertedRow = (row * MAX_NUMBER_OF_DAYS_IN_WEEK) + ((column + Offset) % MAX_NUMBER_OF_DAYS_IN_WEEK)
            convertedSection = (Offset + column) / MAX_NUMBER_OF_DAYS_IN_WEEK
        } else {
            Offset = Int(round(calendarView.contentOffset.y / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.height))
            convertedRow = ((row * MAX_NUMBER_OF_DAYS_IN_WEEK) +  column + (Offset * MAX_NUMBER_OF_DAYS_IN_WEEK)) % (MAX_NUMBER_OF_DAYS_IN_WEEK * cachedConfiguration.numberOfRows)
            convertedSection = (Offset + row) / cachedConfiguration.numberOfRows
        }
        
        let indexPathToFind = IndexPath(item: convertedRow, section: convertedSection)
        if let  date = dateFromPath(indexPathToFind) {
            let stateOfCell = cellStateFromIndexPath(indexPathToFind, withDate: date)
            return stateOfCell
        }
        return nil
    }
    /// Returns the cell status for a given date
    /// - Parameter: date Date of the cell you which to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatusForDate(_ date: Date)-> CellState? {
        // validate the path
        let paths = pathsFromDates([date])
        if paths.count < 1 { return nil }
        let cell = calendarView.cellForItem(at: paths[0]) as? JTAppleDayCell
        let stateOfCell = cellStateFromIndexPath(paths[0], withDate: date, cell: cell)
        return stateOfCell
    }
    
    /// Returns the calendar view's current section boundary dates.
    /// - returns:
    ///     - startDate: The start date of the current section
    ///     - endDate: The end date of the current section
    public func currentCalendarDateSegment() -> (startDate: Date, endDate: Date) {
        guard let dateSegment = dateFromSection(currentSectionPage) else {
            assert(false, "Error in currentCalendarDateSegment method. Report this issue to Jay on github.")
            return (Date(), Date())
        }
        return dateSegment
    }
    
    /// Let's the calendar know which cell xib to use for the displaying of it's date-cells.
    /// - Parameter name: The name of the xib of your cell design
    public func registerCellViewXib(fileName name: String) {
        cellViewSource = JTAppleCallendarCellViewSource.fromXib(name)
    }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The class name of your cell design
    public func registerCellViewClass(fileName name: String) {
        cellViewSource = JTAppleCallendarCellViewSource.fromClassName(name)
    }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The type of your cell design
    public func registerCellViewClass(cellClass: AnyClass) {
        cellViewSource = JTAppleCallendarCellViewSource.fromType(cellClass)
    }
    
    
    /// Register header views with the calender. This needs to be done before the view can be displayed
    /// - Parameter fileNames: A dictionary containing [headerViewNames:HeaderviewSizes]
    public func registerHeaderViewXibs(fileNames headerViewXibNames: [String]) {
        headerViewXibs.removeAll() // remove the already registered xib files if the user re-registers again.
        
        if headerViewXibNames.count < 1 {
            return
        }

        for headerViewXibName in headerViewXibNames {
            let viewObject = Bundle.main.loadNibNamed(headerViewXibName, owner: self, options: [:])
            assert((viewObject?.count)! > 0, "your nib file name \(headerViewXibName) could not be loaded)")
            
            guard viewObject?[0] is JTAppleHeaderView else {
                assert(false, "xib file class does not conform to the protocol<JTAppleHeaderViewProtocol>")
                return
            }
            
            headerViewXibs.append(headerViewXibName)
            
            self.calendarView.register(JTAppleCollectionReusableView.self,
                                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                            withReuseIdentifier: headerViewXibName)
        }
    }
    
    /// Reloads the data on the calendar view. Scroll delegates are not triggered with this function.
    public func reloadData(withAnchorDate date:Date? = nil, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        reloadData(checkDelegateDataSource: true, withAnchorDate: date, withAnimation: animation, completionHandler: completionHandler)
    }
    
    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified dates will be reloaded
    public func reloadDates(_ dates: [Date]) {
        batchReloadIndexPaths(pathsFromDates(dates))
    }
    
    /// Select a date-cell range
    /// - Parameter startDate: Date to start the selection from
    /// - Parameter endDate: Date to end the selection from
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    public func selectDates(from startDate:Date, to endDate:Date, triggerSelectionDelegate: Bool = true) {
        selectDates(generateDateRange(from: startDate, to: endDate), triggerSelectionDelegate: triggerSelectionDelegate)
    }
    
    /// Select a date-cells
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    public func selectDates(_ dates: [Date], triggerSelectionDelegate: Bool = true) {
        var allIndexPathsToReload: [IndexPath] = []
        var validDatesToSelect = dates
        // If user is trying to select multiple dates with multiselection disabled, then only select the last object
        if !calendarView.allowsMultipleSelection && dates.count > 0 { validDatesToSelect = [dates.last!] }
        
        for date in validDatesToSelect {
            let components = (self.calendar as NSCalendar).components([.year, .month, .day],  from: date)
            let firstDayOfDate = self.calendar.date(from: components)!
            
            // If the date is not within valid boundaries, then exit
            if !(firstDayOfDate >= self.startOfMonthCache as Date && firstDayOfDate <= self.endOfMonthCache as Date) { continue }
            let pathFromDates = self.pathsFromDates([date])
            
            // If the date path youre searching for, doesnt exist, then return
            if pathFromDates.count < 0 { continue }
            let sectionIndexPath = pathFromDates[0]
            let selectTheDate = {
                self.calendarView.selectItem(at: sectionIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
                // If triggereing is enabled, then let their delegate handle the reloading of view, else we will reload the data
                if triggerSelectionDelegate {
                    self.collectionView(self.calendarView, didSelectItemAt: sectionIndexPath)
                } else { // Although we do not want the delegate triggered, we still want counterpart cells to be selected
                    
                    // Because there is no triggering of the delegate, the cell will not be added to selection and it will not be reloaded. We need to do this here
                    self.addCellToSelectedSetIfUnselected(sectionIndexPath, date: date)
                    allIndexPathsToReload.append(sectionIndexPath)
                    let cellState = self.cellStateFromIndexPath(sectionIndexPath, withDate: date)
                    if let aSelectedCounterPartIndexPath = self.selectCounterPartCellIndexPathIfExists(sectionIndexPath, date: date, dateOwner: cellState.dateBelongsTo) {
                        // If there was a counterpart cell then it will also need to be reloaded
                        allIndexPathsToReload.append(aSelectedCounterPartIndexPath)
                    }
                }
            }
            
            let deSelectTheDate = { (oldIndexPath: IndexPath) -> Void in
                if !allIndexPathsToReload.contains(oldIndexPath) { allIndexPathsToReload.append(oldIndexPath) } // To avoid adding the  same indexPath twice.
                if let index = self.theSelectedIndexPaths.index(of: oldIndexPath) {
                    let oldDate = self.theSelectedDates[index]
                    self.calendarView.deselectItem(at: oldIndexPath, animated: false)
                    self.theSelectedIndexPaths.remove(at: index)
                    self.theSelectedDates.remove(at: index)
                    
                    // If delegate triggering is enabled, let the delegate function handle the cell
                    if triggerSelectionDelegate {
                        self.collectionView(self.calendarView, didDeselectItemAt: oldIndexPath)
                    } else { // Although we do not want the delegate triggered, we still want counterpart cells to be deselected
                        let cellState = self.cellStateFromIndexPath(oldIndexPath, withDate: oldDate)
                        if let anUnselectedCounterPartIndexPath = self.deselectCounterPartCellIndexPath(oldIndexPath, date: oldDate, dateOwner: cellState.dateBelongsTo) {
                            // If there was a counterpart cell then it will also need to be reloaded
                             allIndexPathsToReload.append(anUnselectedCounterPartIndexPath)
                        }
                    }
                }
            }
            
            // Remove old selections
            if self.calendarView.allowsMultipleSelection == false { // If single selection is ON
                let selectedIndexPaths = self.theSelectedIndexPaths // made a copy because the array is about to be mutated
                for indexPath in selectedIndexPaths {
                    if indexPath != sectionIndexPath { deSelectTheDate(indexPath as IndexPath) }
                }
                
                // Add new selections
                // Must be added here. If added in delegate didSelectItemAtIndexPath
                selectTheDate()
            } else { // If multiple selection is on. Multiple selection behaves differently to singleselection. It behaves like a toggle.
                
                if self.theSelectedIndexPaths.contains(sectionIndexPath) { // If this cell is already selected, then deselect it
                    deSelectTheDate(sectionIndexPath)
                } else {
                    // Add new selections
                    // Must be added here. If added in delegate didSelectItemAtIndexPath
                    selectTheDate()
                }
            }
        }
        
        
        // If triggering was false, although the selectDelegates weren't called, we do want the cell refreshed. Reload to call itemAtIndexPath
        if triggerSelectionDelegate == false && allIndexPathsToReload.count > 0 {
            delayRunOnMainThread(0.0) {
                self.batchReloadIndexPaths(allIndexPathsToReload)
            }
        }
    }
    
    /// Scrolls the calendar view to the next section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToNextSegment(_ triggerScrollToDateDelegate: Bool = false, animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage + 1
        if page < monthInfo.count {
            scrollToSection(page,  animateScroll: animateScroll, completionHandler: completionHandler)
        }
    }
    /// Scrolls the calendar view to the previous section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToPreviousSegment(_ triggerScrollToDateDelegate: Bool = false, animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage - 1
        if page > -1 {
            scrollToSection(page, animateScroll: animateScroll, completionHandler: completionHandler)
        }
    }

    /// Scrolls the calendar view to the start of a section view containing a specified date.
    /// - Paramater date: The calendar view will scroll to a date-cell containing this date if it exists
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Paramater preferredScrollPositionIndex: Integer indicating the end scroll position on the screen. This value indicates column number for Horizontal scrolling and row number for a vertical scrolling calendar
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToDate(_ date: Date, triggerScrollToDateDelegate: Bool = true, animateScroll: Bool = true, preferredScrollPosition: UICollectionViewScrollPosition? = nil, completionHandler:(()->Void)? = nil) {
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let components = (calendar as NSCalendar).components([.year, .month, .day],  from: date)
        let firstDayOfDate = calendar.date(from: components)!
        
        scrollInProgress = true
        delayRunOnMainThread(0.0, closure: {
            // This part should be inside the mainRunLoop
            if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) {
                self.scrollInProgress = false
                return
            }
            
            let retrievedPathsFromDates = self.pathsFromDates([date])
            
            if retrievedPathsFromDates.count > 0 {
                let sectionIndexPath =  self.pathsFromDates([date])[0]
                var position: UICollectionViewScrollPosition = self.direction == .horizontal ? .left : .top
                if !self.pagingEnabled {
                    if let validPosition:UICollectionViewScrollPosition = preferredScrollPosition {
                        if self.direction == .horizontal {
                            if validPosition == .left || validPosition == .right || validPosition == .centeredHorizontally {
                                position = validPosition
                            } else {
                                position = .left
                            }
                        } else {
                            if validPosition == .top || validPosition == .bottom || validPosition == .centeredVertically {
                                position = validPosition
                            } else {
                                position = .top
                            }
                        }
                    }
                }
                
                let scrollToIndexPath = {(iPath: IndexPath, withAnimation: Bool)-> Void in
                    if let validCompletionHandler = completionHandler { self.delayedExecutionClosure.append(validCompletionHandler) }
                     
                    // regular movement
                    self.calendarView.scrollToItem(at: iPath, at: position, animated: animateScroll)
                    
                    
                    if animateScroll {
                        if let check = self.calendarOffsetIsAlreadyAtScrollPosition(forIndexPath: iPath), check == true {
                                self.scrollViewDidEndScrollingAnimation(self.calendarView)
                                self.scrollInProgress = false
                                return
                        }
                    }
                }
                
                if self.pagingEnabled {
                    if headerViewXibs.count > 0 {
                        // If both paging and header is on, then scroll to the actual date
                        // If direction is vertical and user has a custom size that is at least the size of the collectionview. 
                        // If this check is not done, it will scroll to header, and have white space at bottom because view is smaller due to small custom user itemSize
                        if self.direction == .vertical && (self.calendarView.collectionViewLayout as! JTAppleCalendarLayout).sizeOfSection(sectionIndexPath.section) >= self.calendarView.frame.height {
                            self.scrollToHeaderInSection(sectionIndexPath.section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animateScroll, completionHandler: completionHandler)
                            return
                        } else {
                            scrollToIndexPath(IndexPath(item: 0, section: sectionIndexPath.section), animateScroll)
                        }
                    } else {
                        // If paging is on and header is off, then scroll to the start date in section
                        scrollToIndexPath(IndexPath(item: 0, section: sectionIndexPath.section), animateScroll)
                    }
                } else {
                    // If paging is off, then scroll to the actual date in the section
                    scrollToIndexPath(sectionIndexPath, animateScroll)
                }
                
                // Jt101 put this into a function to reduce code between this and the scroll to header function
                delayRunOnMainThread(0.0, closure: {
                    if  !animateScroll  {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                        self.scrollInProgress = false
                    }
                })
            }
        })
    }
    
    /// Scrolls the calendar view to the start of a section view header. If the calendar has no headers registered, then this function does nothing
    /// - Paramater date: The calendar view will scroll to the header of a this provided date
    public func scrollToHeaderForDate(_ date: Date, triggerScrollToDateDelegate: Bool = false, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        let path = pathsFromDates([date])
        // Return if date was incalid and no path was returned
        if path.count < 1 { return }
        scrollToHeaderInSection(path[0].section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animation, completionHandler: completionHandler)
    }
    
    /// Generates a range of dates from from a startDate to an endDate you provide
    /// Parameter startDate: Start date to generate dates from
    /// Parameter endDate: End date to generate dates to
    /// returns:
    ///     - An array of the successfully generated dates
    public func generateDateRange(from startDate: Date, to endDate:Date)-> [Date] {
        if startDate > endDate { return [] }
        var returnDates: [Date] = []
        var currentDate = startDate
        repeat {
            returnDates.append(currentDate)
            currentDate = (calendar as NSCalendar).date(byAdding: .day, value: 1, to: currentDate, options: NSCalendar.Options.matchNextTime)!
        } while currentDate <= endDate
        return returnDates
    }

}
