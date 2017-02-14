//
//  TravelMapViewSideTableView.swift
//  MyTravel
//
//  Created by Daeho on 2016. 9. 12..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import UIKit
import CoreData

//햄버거 메뉴에 배치된 사이드 테이블뷰를 생성
class TravelMapViewSideTableView : UITableView , UITableViewDelegate, UITableViewDataSource {
    
    
    ////CORE DATA
    var appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var contextA : NSManagedObjectContext?
    
    
    var sTableView : TravelMapViewSideTableView?
    var tmvControl : TravelMapViewController?
    var count = 0;
    var pins :  NSMutableArray?
    var categorys : [Category]?
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showData(_ pins : [FavorPin], categorys : [Category], sTableView : TravelMapViewSideTableView ,tmvControl : TravelMapViewController){
        
        if self.sTableView == nil {
            self.sTableView = TravelMapViewSideTableView()
            self.tmvControl = TravelMapViewController()
            self.tmvControl = tmvControl
            self.sTableView = sTableView
            self.sTableView?.delegate = self
            self.sTableView?.dataSource = self
        }
            self.pins = NSMutableArray()
            self.categorys = categorys
        
            for category in self.categorys! {
                let temp = NSMutableArray()
                for pin in pins {
                    print(pin.type)
                    if pin.type == Int(category.typenum) {
                        print(pin.type)
                        temp.add(pin)
                    }else {
                        
                    }
                }
                count = count + 1
                self.pins?.add(temp)
            }
            //COREDATA INIT
            contextA = appDel.managedObjectContext
        
        self.sTableView!.reloadData()
    }
    
    func actDeleteUpdateRow(_ sender: AnyObject) {
        let alert = UIAlertController(title: "지도 수정", message:"이 부분을 삭제하기?", preferredStyle: .alert)
        let action = UIAlertAction(title: "삭제하기", style: .default) { _ in
            //Section 쪽 ROW 삭제
            for pin in (self.pins!.object(at: sender.tag) as! NSMutableArray) {
                print(pin)
                self.contextA?.delete(pin as! NSManagedObject)
                (self.pins?.object(at: sender.tag) as AnyObject).remove(pin)
                self.appDel.saveContext()
            }
            //self.contextA?.deleteObject(pins!.objectAtIndex(indexPath.section).objectAtIndex(indexPath.row) as! NSManagedObject)
            self.contextA?.delete(self.categorys![sender.tag])
            self.appDel.saveContext()
//            self.categorys?.removeAtIndex(sender.tag)
            
         
        
//            self.sTableView?.reloadData()
//            self.sTableView?.reloadInputViews()
            self.sTableView?.reloadSections(IndexSet(integer : sender.tag), with: UITableViewRowAnimation.left)
            //Reload MapView...
            self.tmvControl?.setMarker()
        }
        
        let cancel = UIAlertAction(title: "취소하기", style: .cancel, handler: { _ in
            //DELETE SECTION
            
        })
        
        alert.addAction(action)
        alert.addAction(cancel)
        self.window?.rootViewController!.present(alert, animated: true){}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.sTableView!.dequeueReusableCell(withIdentifier: "TravelMapViewSideTableViewCell", for: indexPath) as! TravelMapViewSideTableViewCell
            cell.titleLB.text = (self.pins!.object(at: indexPath.section) as AnyObject).objectAtIndex(indexPath.row).title
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (pins!.object(at: section) as AnyObject).count
    }
    //커스텀 Header뷰를 생성하는 부분
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            
            let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
            let label = UILabel()
            let button   = UIButton(type: UIButtonType.system)
            
            label.text = categorys![section].title
            button.setTitle("삭제", for: UIControlState())
            button.setTitleColor(UIColor.white, for: UIControlState())
            print("SECTION : "+String(section))
            button.tag =  NSInteger(section)
            button.addTarget(self, action: #selector(TravelMapViewSideTableView.actDeleteUpdateRow(_:)), for: UIControlEvents.touchUpInside)
            
            view.addSubview(label)
            view.addSubview(button)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.white
            button.translatesAutoresizingMaskIntoConstraints = false
            let views = ["label": label, "button": button, "view": view]
            
            let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label]-60-[button]-10-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontallayoutContraints)
            
            let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
        
            view.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
            return view
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return categorys!.count
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //CoreData ROW 제거 부분
            contextA?.delete((pins!.object(at: indexPath.section) as AnyObject).object(indexPath.row) as! NSManagedObject)
            appDel.saveContext()
            (self.pins?.object(at: indexPath.section) as AnyObject).removeObject(at: indexPath.row)
            self.sTableView?.deleteRows(at: [indexPath], with: .fade)
            self.sTableView?.reloadData()
            
            //Reload MapView...
            self.tmvControl?.setMarker()
        }
    }
}
