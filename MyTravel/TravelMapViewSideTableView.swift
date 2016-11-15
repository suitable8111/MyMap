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
    var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    func showData(pins : [FavorPin], categorys : [Category], sTableView : TravelMapViewSideTableView ,tmvControl : TravelMapViewController){
        
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
                        temp.addObject(pin)
                    }else {
                        
                    }
                }
                count = count + 1
                self.pins?.addObject(temp)
            }
            //COREDATA INIT
            contextA = appDel.managedObjectContext
        
        self.sTableView!.reloadData()
    }
    
    func actDeleteUpdateRow(sender: AnyObject) {
        let alert = UIAlertController(title: "지도 수정", message:"이 부분을 삭제하기?", preferredStyle: .Alert)
        let action = UIAlertAction(title: "삭제하기", style: .Default) { _ in
            //Section 쪽 ROW 삭제
            for pin in (self.pins!.objectAtIndex(sender.tag) as! NSMutableArray) {
                print(pin)
                self.contextA?.deleteObject(pin as! NSManagedObject)
                self.pins?.objectAtIndex(sender.tag).removeObject(pin)
                self.appDel.saveContext()
            }
            //self.contextA?.deleteObject(pins!.objectAtIndex(indexPath.section).objectAtIndex(indexPath.row) as! NSManagedObject)
            self.contextA?.deleteObject(self.categorys![sender.tag])
            self.appDel.saveContext()
//            self.categorys?.removeAtIndex(sender.tag)
            
         
        
//            self.sTableView?.reloadData()
//            self.sTableView?.reloadInputViews()
            self.sTableView?.reloadSections(NSIndexSet(index : sender.tag), withRowAnimation: UITableViewRowAnimation.Left)
            //Reload MapView...
            self.tmvControl?.setMarker()
        }
        
        let cancel = UIAlertAction(title: "취소하기", style: .Cancel, handler: { _ in
            //DELETE SECTION
            
        })
        
        alert.addAction(action)
        alert.addAction(cancel)
        self.window?.rootViewController!.presentViewController(alert, animated: true){}
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.sTableView!.dequeueReusableCellWithIdentifier("TravelMapViewSideTableViewCell", forIndexPath: indexPath) as! TravelMapViewSideTableViewCell
            cell.titleLB.text = self.pins!.objectAtIndex(indexPath.section).objectAtIndex(indexPath.row).title
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins!.objectAtIndex(section).count
    }
    //커스텀 Header뷰를 생성하는 부분
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            
            let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
            let label = UILabel()
            let button   = UIButton(type: UIButtonType.System)
            
            label.text = categorys![section].title
            button.setTitle("삭제", forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            print("SECTION : "+String(section))
            button.tag =  NSInteger(section)
            button.addTarget(self, action: #selector(TravelMapViewSideTableView.actDeleteUpdateRow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            view.addSubview(label)
            view.addSubview(button)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.whiteColor()
            button.translatesAutoresizingMaskIntoConstraints = false
            let views = ["label": label, "button": button, "view": view]
            
            let horizontallayoutContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[label]-60-[button]-10-|", options: .AlignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontallayoutContraints)
            
            let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
        
            view.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
            return view
        
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categorys!.count
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //CoreData ROW 제거 부분
            contextA?.deleteObject(pins!.objectAtIndex(indexPath.section).objectAtIndex(indexPath.row) as! NSManagedObject)
            appDel.saveContext()
            self.pins?.objectAtIndex(indexPath.section).removeObjectAtIndex(indexPath.row)
            self.sTableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.sTableView?.reloadData()
            
            //Reload MapView...
            self.tmvControl?.setMarker()
        }
    }
}
