//
//  CalenderCellView.swift
//  MyTravel
//
//  Created by Daeho on 2016. 10. 4..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import JTAppleCalendar

class CalenderCellView : JTAppleDayCellView {
    @IBOutlet weak var dayV: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    
    var black = UIColor.blackColor()
    var clear = UIColor.clearColor()
    
    var gray = UIColor.grayColor()
    var white = UIColor.whiteColor()
    
    func selectCell() {
        //선택되었을때 색상
        dayV.layer.cornerRadius = 23
        dayV.layer.masksToBounds = true
            
        dayV.backgroundColor = gray
        dayLabel.textColor = white
    }
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate, startdate : NSDate) {
        // Setup Cell text
        dayLabel.text =  cellState.text
        
        // 텍스트 색 정하기
        configureTextColor(cellState, startdate: startdate)
        
    }
    
    func configureTextColor(cellState: CellState, startdate : NSDate) {
        if cellState.dateBelongsTo == .ThisMonth {
            
            //오늘날짜 기준으로 이전은 회색처리
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let today = Int(formatter.stringFromDate(startdate))
            let day = Int(formatter.stringFromDate(cellState.date))
            
            //날짜가 이전일 경우
            if  day < today{
                dayV.layer.cornerRadius = 17
                dayV.layer.masksToBounds = true
                dayV.backgroundColor = gray
                dayLabel.textColor = white
            }else {
                dayV.backgroundColor = clear
                dayLabel.textColor = black
            }
        } else {
            dayV.backgroundColor = clear
            dayLabel.textColor = gray
        }
    }
    
}
