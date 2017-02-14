//
//  SetPlaceViewController.swift
//  MyTravel
//
//  Created by Daeho on 2016. 7. 30..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class SetPlaceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var contentTF: UITextField!
    @IBOutlet weak var savedDateTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var catepicker: UIPickerView!
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet var backGroundView: UIView!
    
    
    
    ////CORE DATA
    var appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var contextA : NSManagedObjectContext?
    
    var marker : GMSMarker?
    var setType : String?
    
    var willUpdatePin : [FavorPin]?
    var categorys : [Category]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (categorys?.count == 0){
            print("ERROR NO CATEGORY")
            self.navigationController?.popViewController(animated: true)
        }
        
        contextA = appDel.managedObjectContext
        catepicker.delegate = self
        catepicker.dataSource = self
        
        
        if setType == MyTravelTag.SET_PIN_UPDATE {
            titleLB.text = (marker?.title)!+"수정하시게요?"
            let entitiy : NSEntityDescription = NSEntityDescription.entity(forEntityName: "FavorPin", in: contextA!)!
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = entitiy
            let predicate = NSPredicate(format: "(lat=%@) AND (long=%@)",argumentArray: [(marker?.position.latitude)!,(marker?.position.longitude)!])
            fetchRequest.predicate = predicate
            willUpdatePin = (try! contextA!.fetch(fetchRequest) as! [FavorPin])
            
            if willUpdatePin?.count != 0 {
//                typeTF.text = willUpdatePin![0].type
                contentTF.text = willUpdatePin![0].content
                savedDateTF.text = willUpdatePin![0].date
                addressTF.text = willUpdatePin![0].pos
                titleTF.text = willUpdatePin![0].title
            }
        } else if setType == MyTravelTag.SET_PIN_ADD {
            titleLB.text = (marker?.title)!+"에 대해 더 메모해보세요!"
            titleTF.text = marker?.title
            addressTF.text = marker?.snippet
            
        }
        
        //SET BACKGROUND
        
        backGroundView.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
    }
    //MARK :: PICKER VIEW DELEGATE
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (categorys?.count)!
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorys![row].title;
    }

    @IBAction func actSave(_ sender: AnyObject) {

        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let timeText = formatter.string(from: Date())
        
        if setType == MyTravelTag.SET_PIN_UPDATE {
            
            
            if willUpdatePin?.count != 0 {
                //willUpdatePin![0].type = typeTF.text!
                willUpdatePin![0].type = Int(categorys![catepicker.selectedRow(inComponent: 0)].typenum)
                willUpdatePin![0].content = contentTF.text!
                willUpdatePin![0].date = savedDateTF.text!
                willUpdatePin![0].pos = addressTF.text!
                willUpdatePin![0].title = titleTF.text!
                appDel.saveContext()
            }
        }else if setType == MyTravelTag.SET_PIN_ADD {
            //CoreData에 저장하는 부분
            
            let pin: FavorPin = NSEntityDescription.insertNewObject(forEntityName: "FavorPin", into: contextA!) as! FavorPin
            
            // 저장될 위치의 제목
            pin.title = titleTF.text!
            // 메모
            pin.content = contentTF.text!
            // 저장한 날짜
            pin.date = timeText
            // 위치정보
            pin.lat = (marker?.position.latitude)!
            pin.long = (marker?.position.longitude)!
            // 이름주소
            pin.pos = addressTF.text!
            // 맛집인지 볼거리인지 등..
            pin.type = Int(categorys![catepicker.selectedRow(inComponent: 0)].typenum)
            // 저장장값 이는 새로운 저장시 올라감
            pin.uid = MyTravelTag.UID_NUM
            MyTravelTag.PRIME_NUM = MyTravelTag.PRIME_NUM + 1
            pin.primekey = MyTravelTag.PRIME_NUM
            
            appDel.saveContext()
            
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBAction func actDate(_ sender: AnyObject) {
        let calControl = self.storyboard?.instantiateViewController(withIdentifier: "CalenderViewController") as? CalenderViewController
        //TAG와 현재날짜를 보내 캘린더의 오류를 줄임 또한 다시 한번 수정하고 싶은 케이스일 경우 ENDTF 초기화
        calControl!.type = "SETDATE"
        calControl!.myDate = Date()
        self.navigationController?.pushViewController(calControl!, animated: true)
    }
    
}
