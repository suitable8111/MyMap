//
//  TravelTableViewController.swift
//  MyTravel
//
//  Created by Daeho on 2016. 7. 31..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import UIKit
import CoreData
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


//내 여행 리스트를 관리해주는 뷰, 새로운 여행을 PinTitle을 통해 추가하고 수정할 수 있습니다.
class TravelTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //내 여행 테이블 뷰 리스트
    @IBOutlet weak var myTableView: UITableView!
    //새로운 여행정보를 추가하려 할때 나타나는 뷰
    @IBOutlet weak var newTravelView: UIView!
    //새로운 여행을 추가하는 버튼
    @IBOutlet weak var addTravelBtn: UIButton!
    
    //자료입력 TextField
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var startTF: UITextField!
    @IBOutlet weak var endTF: UITextField!
    //Calender에서 받아온 NSDATE
    var startDate : Date?
    
    //adding bool 변수, 이는 추가하고 삭제하는 뷰의 스위치 역할
    var adding = false
    
    @IBOutlet weak var naviView: UIView!
    
    //// INIT /////
    //MARK : CORE DATA
    var appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var contextA : NSManagedObjectContext?
    //CORE DATA의 Array : PinTitle 의 Entity를 호출
    var pintitles : [PinTitle]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initCoreData
        contextA = appDel.managedObjectContext
        let reqA: NSFetchRequest = NSFetchRequest(entityName:"PinTitle")
        pintitles = (try! contextA!.fetch(reqA) as! [PinTitle])
        //init Delgate , DataSource
        myTableView.delegate = self
        myTableView.dataSource = self
    
        
        MyTravelTag.UID_NUM = getUidNum()
        
        
        //SET BACKGROUND
        newTravelView.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
        naviView.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
        
        //START, END는 달력만 선택하도록
//        startTF.userInteractionEnabled = false
//        endTF.userInteractionEnabled = false
    }
    
    
    ////END INIT /////
    
    
    ////FUNCS ////
    
    //최신 uid를 가져오는 함수, uid는 사용자 고유의 여행 리스트 게시물 번호임
    func getUidNum() -> Int64 {
        if pintitles!.count != 0 {
            return pintitles![pintitles!.count-1].uid
        }else {
            return 0;
        }
    }
    //필수 조건을 정확히 기입하였는지 여부
    
    func checkSave() -> Bool {
        if (startTF.text == "" || endTF.text == ""){
            print("날짜써요")
            return false
        }else {
            let startDate = startTF.text?.replacingOccurrences(of: ".", with: "")
            let endDate = endTF.text?.replacingOccurrences(of: ".", with: "")
            
            if titleTF.text == "" {
                print("써줭")
                return false
            }else if Int(startDate!) > Int(endDate!) {
                print("시작이 먼저일리가 없잖아!")
                return false
            }
            return true
        }
        
    }
    func daysBetweenDates(_ startDate: Date, endDate: Date) -> String
    {
        let calendar = Calendar.current
        
        let components = (calendar as NSCalendar).components([.day], from: startDate, to: endDate, options: [])
        
        return String(components.day!-1)+"박 "+String(describing: components.day)+"일"
    }
    
    ////END FUNCS ////
    
    
    
    ///MARK : TABLEVIEW DELEGATE ////
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "TravelTableViewCell", for: indexPath) as! TravelTableViewCell
        cell.titleLB.text = pintitles![indexPath.row].title
        cell.titleLB.textColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
        cell.startDateLB.text = pintitles![indexPath.row].startdate
        cell.endDateLB.text = pintitles![indexPath.row].enddate
        cell.backgroundV.layer.borderColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BOARDER_COLOR).cgColor
        
        cell.backgroundV.layer.borderWidth = 2.5
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let startDate = formatter.date(from: pintitles![indexPath.row].startdate)
        let endDate = formatter.date(from: pintitles![indexPath.row].enddate)
        
        
        cell.daysLB.text = daysBetweenDates(startDate!, endDate: endDate!)
//        cell.timeLB.text = pintitles![indexPath.row].date
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pintitles!.count != 0 {
            return (pintitles?.count)!
        }else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MyTravelTag.UID_NUM = pintitles![indexPath.row].uid
        MyTravelTag.UID_TITLE = pintitles![indexPath.row].title
        let travelControl = self.storyboard?.instantiateViewController(withIdentifier: "TravelMapViewController") as? TravelMapViewController
        self.navigationController?.pushViewController(travelControl!, animated: true)
    }
    //내가 등록한 여행지를 삭제하는 부분, 추후 수정도 가능하게 제작해야함
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //CoreData 제거 부분
            contextA?.delete(pintitles![indexPath.row])
            appDel.saveContext()
            pintitles?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    ///END TABLEVIEW DELEGATE ////
    
    
    
    
    ///MARK :: IBACTIONS
    
    
    //새로운 여행을 추가했을 때 코드
    @IBAction func actAddTravel(_ sender: AnyObject) {
        if adding {
            //더하는 중일 때 취소 버튼을 누른것, 다시 뷰가 밑으로 내려감
            adding = false
            
            //타이틀, 날짜 모두 초기화
            startTF.text = ""
            endTF.text = ""
            titleTF.text = ""
            
            self.addTravelBtn.setTitle("+", for: UIControlState())
            UIView.animate(withDuration: 1.0, animations: {
                self.newTravelView.transform = CGAffineTransform(translationX: 0.0, y: 0.0);
                
            })
        }else {
            adding = true
            self.addTravelBtn.setTitle("x", for: UIControlState())
            UIView.animate(withDuration: 1.0, animations: {
                self.newTravelView.transform = CGAffineTransform(translationX: 0.0, y: -self.view.frame.height*0.90);
                
            })
        }
    }
 
    
    
    @IBAction func actStartDate(_ sender: AnyObject) {
        //CalenderView로 이동함 
        let calControl = self.storyboard?.instantiateViewController(withIdentifier: "CalenderViewController") as? CalenderViewController
        //TAG와 현재날짜를 보내 캘린더의 오류를 줄임 또한 다시 한번 수정하고 싶은 케이스일 경우 ENDTF 초기화
        self.endTF.text = ""
        calControl!.type = "START"
        calControl!.myDate = Date()
        self.navigationController?.pushViewController(calControl!, animated: true)
    }
    @IBAction func actEndDate(_ sender: AnyObject) {
        //STARTTF를 먼저 안정하고 클릭시 
        if startTF.text == "" {
            print("ERROR, DIDN't PUT IN START TF")
        }else {
            print("PROCEEING ACT END DATE")
            let calControl = self.storyboard?.instantiateViewController(withIdentifier: "CalenderViewController") as? CalenderViewController
            //TAG와 시작날짜를 보내 캘린더 오류 처리
            calControl!.type = "END"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            calControl!.myDate = formatter.date(from: startTF.text!)
            self.navigationController?.pushViewController(calControl!, animated: true)
        }
    }
    
    @IBAction func actAddSave(_ sender: AnyObject) {
        
        
        if checkSave() {
            adding = false
            //저장했으니 adding은 false로 취소해주세요
            //Title의 UID값을 증가시킨 후 저장함
            MyTravelTag.UID_NUM = MyTravelTag.UID_NUM + 1
            //Entitiy init
            let title : PinTitle = NSEntityDescription.insertNewObject(forEntityName: "PinTitle", into: contextA!) as! PinTitle
            title.uid = MyTravelTag.UID_NUM
            title.startdate = startTF.text!
            title.enddate = endTF.text!
            title.title = titleTF.text!
            appDel.saveContext()
            
            //저장후 객체 리로드
            let reqA: NSFetchRequest = NSFetchRequest(entityName:"PinTitle")
            pintitles = (try! contextA!.fetch(reqA) as! [PinTitle])
            myTableView.reloadData()
            //내리기
            self.addTravelBtn.setTitle("+", for: UIControlState())
            UIView.animate(withDuration: 1.0, animations: {
                self.newTravelView.transform = CGAffineTransform(translationX: 0.0, y: 0.0);
                
            })
        }else {
            
            
        }
//        let title : PinTitle = NSEntityDescription.insertNewObjectForEntityForName("PinTitle", inManagedObjectContext: contextA!) as! PinTitle
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let timeText = formatter.stringFromDate(NSDate())
//        
        
//        title.uid = MyTravelTag.UID_NUM
//        title.title = addTitleTF.text!
//        title.date = timeText
        
    }
    
    ///END IBACTIONS ////
}
