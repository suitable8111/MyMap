//
//  CalenderCellView.swift
//  MyTravel
//
//  Created by Daeho on 2016. 10. 4..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import JTAppleCalendar
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class CalenderCellView : JTAppleDayCellView {
    @IBOutlet weak var dayV: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    
    var black = UIColor.black
    var clear = UIColor.clear
    
    var gray = UIColor.gray
    var white = UIColor.white
    
    func selectCell() {
        //선택되었을때 색상
        dayV.layer.cornerRadius = 23
        dayV.layer.masksToBounds = true
            
        dayV.backgroundColor = gray
        dayLabel.textColor = white
    }
    func setupCellBeforeDisplay(_ cellState: CellState, date: Date, startdate : Date) {
        // Setup Cell text
        dayLabel.text =  cellState.text
        
        // 텍스트 색 정하기
        configureTextColor(cellState, startdate: startdate)
        
    }
    
    func configureTextColor(_ cellState: CellState, startdate : Date) {
        if cellState.dateBelongsTo == .thisMonth {
            
            //오늘날짜 기준으로 이전은 회색처리
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let today = Int(formatter.string(from: startdate))
            let day = Int(formatter.string(from: cellState.date))
            
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
