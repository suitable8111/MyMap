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
    var myDate : Date?
    
    @IBOutlet weak var naviView: UIView!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(fileName: "CalenderCellView")
        self.automaticallyAdjustsScrollViewInsets = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.string(from: myDate!)
        self.dateLB.text = date
        
        naviView.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
    }
    
    
    //MARK ::JTAppleDelegate
    
    func calendar(_ calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        (cell as! CalenderCellView).setupCellBeforeDisplay(cellState, date: date, startdate : self.myDate!)
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
//        (cell as! CalenderCellView).selectCell()
        //Select한후 뷰 빠져나옴 ActionEnd
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        if type == "START" || type == "END" {
            let travelTVC = self.navigationController?.viewControllers[0] as! TravelTableViewController
            if type == "START" {
                travelTVC.startTF.text = formatter.string(from: date)
            }else if type == "END" {
                travelTVC.endTF.text = formatter.string(from: date)
            }
        }else if type == "SETDATE" {
            let setTVC = self.navigationController?.viewControllers[2] as! SetPlaceViewController
            setTVC.savedDateTF.text = formatter.string(from: date)
        }
        
        
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: Date, endingWithDate endDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.string(from: startDate)
        self.dateLB.text = date
    }
    
    //MAKR : IBActions
    @IBAction func actCancel(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actRight(_ sender: AnyObject) {
        self.calendarView.scrollToNextSegment()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.string(from: self.calendarView.currentCalendarDateSegment().endDate)
        self.dateLB.text = date
        
    }
    @IBAction func actLeft(_ sender: AnyObject) {
        self.calendarView.scrollToPreviousSegment()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        let date = formatter.string(from: self.calendarView.currentCalendarDateSegment().startDate)
        self.dateLB.text = date
    }
    
}

extension CalenderViewController : JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate  {
    // Setting up manditory protocol method
    func configureCalendar(_ calendar: JTAppleCalendarView) -> (startDate: Date, endDate: Date, numberOfRows: Int, calendar: Calendar) {
        // You can set your date using NSDate() or NSDateFormatter. Your choice.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let secondDate = formatter.date(from: "2026 10 04")
        let numberOfRows = 6
        let aCalendar = Calendar.current // Properly configure your calendar to your time zone here
        
        return (startDate: myDate!, endDate: secondDate!, numberOfRows: numberOfRows, calendar: aCalendar)
    }
}
