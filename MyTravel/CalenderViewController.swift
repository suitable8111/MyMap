//
//  CalenderViewController.swift
//  MyTravel
//
//  Created by Daeho on 2016. 10. 4..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalenderViewController : UIViewController {
    
    var type : String = "";
    var myDate : NSDate?
    
    @IBOutlet weak var naviView: UIView!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(fileName: "CalenderCellView")
        self.automaticallyAdjustsScrollViewInsets = false
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.stringFromDate(myDate!)
        self.dateLB.text = date
        
        naviView.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
    }
    
    
    //MARK ::JTAppleDelegate
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as! CalenderCellView).setupCellBeforeDisplay(cellState, date: date, startdate : self.myDate!)
    }
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
//        (cell as! CalenderCellView).selectCell()
        //Select한후 뷰 빠져나옴 ActionEnd
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        if type == "START" || type == "END" {
            let travelTVC = self.navigationController?.viewControllers[0] as! TravelTableViewController
            if type == "START" {
                travelTVC.startTF.text = formatter.stringFromDate(date)
            }else if type == "END" {
                travelTVC.endTF.text = formatter.stringFromDate(date)
            }
        }else if type == "SETDATE" {
            let setTVC = self.navigationController?.viewControllers[2] as! SetPlaceViewController
            setTVC.savedDateTF.text = formatter.stringFromDate(date)
        }
        
        
        
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.stringFromDate(startDate)
        self.dateLB.text = date
    }
    
    //MAKR : IBActions
    @IBAction func actCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func actRight(sender: AnyObject) {
        self.calendarView.scrollToNextSegment()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.stringFromDate(self.calendarView.currentCalendarDateSegment().endDate)
        self.dateLB.text = date
        
    }
    @IBAction func actLeft(sender: AnyObject) {
        self.calendarView.scrollToPreviousSegment()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.stringFromDate(self.calendarView.currentCalendarDateSegment().startDate)
        self.dateLB.text = date
    }
    
}

extension CalenderViewController : JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate  {
    // Setting up manditory protocol method
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        // You can set your date using NSDate() or NSDateFormatter. Your choice.
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let secondDate = formatter.dateFromString("2026 10 04")
        let numberOfRows = 6
        let aCalendar = NSCalendar.currentCalendar() // Properly configure your calendar to your time zone here
        
        return (startDate: myDate!, endDate: secondDate!, numberOfRows: numberOfRows, calendar: aCalendar)
    }
}