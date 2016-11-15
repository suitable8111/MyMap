//
//  TravelMapViewController.swift
//  MyTravel
//
//  Created by Daeho on 2016. 7. 25..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class TravelMapViewController : UIViewController, UISearchDisplayDelegate, GMSMapViewDelegate , GMSAutocompleteTableDataSourceDelegate {
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapTitle: UILabel!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var sideTableView: TravelMapViewSideTableView!
    @IBOutlet weak var newCateView: UIView!
    @IBOutlet weak var cateTitleTF: UITextField!
    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var naviView: UIView!
    

    
    ////CORE DATA
    var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var contextA : NSManagedObjectContext?
    var sideViewSW = false
    
    //UID NUM에 따른 Categroy 호출
    var categorys : Array<Category>!
    //CoreData.sqlite의 저장된 Entity를 배열화 시켜 뿌려주는 배열
    var pins : Array<FavorPin>!
    var googleMapView : GMSMapView?
    let fetchRequest = NSFetchRequest()
    //var searchBar : UISearchBar?
    var tableDataSource : GMSAutocompleteTableDataSource?
    var srchDisplayController : UISearchDisplayController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //지도를 초기화 시켜주는 뷰, CoreData를 불러와 저장되었던 핀들을 보여준다.
        initMapView()
        
        
        //PRIME_NUM 은 Enitiy의 가장 마지막 배열의 번호를 가진다.
        MyTravelTag.TYPE_NUM_CATE = getCateNum()
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self
        
        srchDisplayController = UISearchDisplayController(searchBar: searchBar!, contentsController: self)
        srchDisplayController?.searchResultsDataSource = tableDataSource
        srchDisplayController?.searchResultsDelegate = tableDataSource
        srchDisplayController?.delegate = self
        
        //SET BACKGROUND
        naviView.backgroundColor = MyTravelTag.hexStringToUIColor(MyTravelTag.BACKGROUND_MAIN)
        
    }
    override func viewWillAppear(animated: Bool) {
        //CoreData에 있는 Data를 뿌려주는 곳
        
        googleMapView?.clear()
        print("NOW YOUR MAP UID NUM : "+String(MyTravelTag.UID_NUM))
        
                //Category 거름
        let entitiy = NSEntityDescription.entityForName("Category", inManagedObjectContext: contextA!)!
        fetchRequest.entity = entitiy
        let predicate = NSPredicate(format: "(uid=%@)",String(MyTravelTag.UID_NUM))
        fetchRequest.predicate = predicate
        
        categorys = (try! contextA!.executeFetchRequest(fetchRequest) as! [Category])
        
        setMarker()
        
        MyTravelTag.PRIME_NUM = getPrimeKey()
        mapTitle.text = MyTravelTag.UID_TITLE
        
    }
    func setMarker() {
        let entitiy : NSEntityDescription = NSEntityDescription.entityForName("FavorPin", inManagedObjectContext: contextA!)!
        
        
        fetchRequest.entity = entitiy
        let predicate = NSPredicate(format: "(uid=%@)",String(MyTravelTag.UID_NUM))
        fetchRequest.predicate = predicate
        pins = (try! contextA!.executeFetchRequest(fetchRequest) as! [FavorPin])
        
        if pins.count != 0 {
            //화면에 내가 저장항 마크를 모두 보여주독하는 bounds
            var bounds = GMSCoordinateBounds()
            for pin in pins {
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(pin.lat, pin.long)
                marker.snippet = pin.pos
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.title = pin.title
                marker.zIndex = Int32(pin.type)
                switch pin.type {
                case 2378:
                    marker.icon = UIImage(named: "green.png")
                    break
                default:
                    marker.icon = UIImage(named: "green.png")
                    break
                }
                marker.map = googleMapView
                bounds = bounds.includingCoordinate(CLLocationCoordinate2DMake(pin.lat, pin.long))
            }
            googleMapView?.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 80.0))
        }else {
            //처음 메모를 등록할경우 위치값을 기본으로 정함 (서울, 대구, 대전)
            googleMapView?.animateToLocation(CLLocationCoordinate2D(latitude: 37.5609615, longitude: 126.9757965))
            googleMapView?.animateToZoom(10)
        }
        
    }
    func getPrimeKey() -> Int64 {
        if pins.count != 0 {
            return pins[pins.count-1].primekey
        }else {
            return 0;
        }
    }
    func getCateNum() -> Int64 {
        
        if categorys != nil {
            if categorys.count != 0 {
                return categorys[categorys.count-1].typenum;
            }else {
                return 0;
            }
        }else {
            return 0;
        }
        
        
    }
    func initMapView() {
        googleMapView = GMSMapView(frame: self.view.bounds)
        googleMapView!.delegate = self
        self.mapView.addSubview(googleMapView!)
        
        //COREDATA INIT
        contextA = appDel.managedObjectContext
    }
    
    func didUpdateAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        // Reload table data.
        srchDisplayController?.searchResultsTableView.reloadData()
    }
    
    func didRequestAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        // Reload table data.
        srchDisplayController?.searchResultsTableView.reloadData()
    }
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWithPlace place: GMSPlace) {
        srchDisplayController?.active = false
        
        //검색한 부분에 카메라를 이동하고 마크를 찍어준다
        
        let position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        let marker = GMSMarker()
        marker.position = position
        marker.snippet = place.formattedAddress
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.title = place.name
        marker.zIndex = 2378
        marker.icon = UIImage(named: "green.png")
        marker.map = googleMapView
        
        //카메라 이동
        googleMapView?.animateToLocation(CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude))
        
    }
    
    //MARK ::MarkerView Event
    
    //Custom MarkerWindow 마커를 클릭했을 때 뜨는 정보창을 커스텀을 만든돠아아아
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = NSBundle.mainBundle().loadNibNamed("CustomMarkerWindow", owner: self, options: nil).first! as! CustomMarkerWindow
        infoWindow.userInteractionEnabled = true
        infoWindow.titleLb.text = marker.title
        infoWindow.placeLb.text = marker.snippet
        
        if marker.zIndex == 2378 {
            infoWindow.typeLb.text = "새로운 핀"
            infoWindow.addLb.text = "등록하기"
        }else {
            for category in categorys {
                if Int(marker.zIndex) == Int(category.typenum){
                     infoWindow.typeLb.text = category.title
                }
            }
            infoWindow.addLb.text = "수정하기"
        }
        
        return infoWindow
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        tableDataSource?.sourceTextHasChanged(searchString)
        return false
    }
    
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: NSError) {
        // TODO: Handle the error.
        print("Error: \(error.description)")
    }
    
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didSelectPrediction prediction: GMSAutocompletePrediction) -> Bool {
        
        return true
    }
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        //새로운 마커인 경우..
        var setControl : SetPlaceViewController?
        var alert : UIAlertController?
        var action : UIAlertAction?
        
        if marker.zIndex == 2378 {
            
            alert = UIAlertController(title: "새로운 마커 생성", message:"정보를 추가하시겠습니까?", preferredStyle: .Alert)
            action = UIAlertAction(title: "추가하기", style: .Default) { _ in
                setControl = self.storyboard?.instantiateViewControllerWithIdentifier("SetPlaceViewController") as? SetPlaceViewController
                setControl!.marker = marker
                setControl!.setType = MyTravelTag.SET_PIN_ADD
                setControl!.categorys = self.categorys
                marker.zIndex = 0
                self.navigationController?.pushViewController(setControl!, animated: true)
            }
        //업데이트 할 마커인 경우...
        } else {
            alert = UIAlertController(title: "지도 수정", message:"이 부분을 수정하시겠습니까?", preferredStyle: .Alert)
            action = UIAlertAction(title: "수정하기", style: .Default) { _ in
                setControl = self.storyboard?.instantiateViewControllerWithIdentifier("SetPlaceViewController") as? SetPlaceViewController
                setControl!.setType = MyTravelTag.SET_PIN_UPDATE
                setControl!.marker = marker
                setControl!.categorys = self.categorys
                self.navigationController?.pushViewController(setControl!, animated: true)
            }
        }
        
        let cancel = UIAlertAction(title: "취소하기", style: .Cancel, handler: { _ in
            if marker.zIndex == 2378 {
                marker.map = nil
            }else {
                
            }
            
        })
        alert!.addAction(action!)
        alert!.addAction(cancel)
        self.presentViewController(alert!, animated: true){}

    }
    
    //MARK :: IBACTION
    
    //카테고리 추가, 사이드뷰를 백
    @IBAction func actCancelHamberger(sender: AnyObject) {
        sideViewSW = false
        
        UIView.animateWithDuration(0.5, animations: {
            self.hiddenView.hidden = true
            self.sideView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            self.newCateView.transform = CGAffineTransformMakeTranslation(0.0,0.0);
            }, completion: nil)
    }
    @IBAction func actHamberger(sender: AnyObject) {
        sideViewSW = true
        
        UIView.animateWithDuration(0.5, animations: {
            self.hiddenView.hidden = false
            self.sideView.transform = CGAffineTransformMakeTranslation(-self.sideView.frame.width, 0.0)
            }, completion: nil)
        
        sideTableView.showData(self.pins, categorys: categorys,  sTableView: self.sideTableView, tmvControl : self);
        
    }
    //뒤로가기 버튼
    @IBAction func actBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //UID 기준으로 카테고리를 생성하는 뷰 띄움
    @IBAction func actAddCategory(sender: AnyObject) {
        UIView.animateWithDuration(1.0, animations: {
            self.newCateView.transform = CGAffineTransformMakeTranslation(0.0, -self.view.frame.height/2);
        })
    }
    
    //카테고리 저장
    @IBAction func actSaveCategory(sender: AnyObject) {
        let cate : Category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: contextA!) as! Category
        cate.uid = MyTravelTag.UID_NUM
        cate.title = cateTitleTF.text!
        cate.typenum = MyTravelTag.TYPE_NUM_CATE
        MyTravelTag.TYPE_NUM_CATE = MyTravelTag.TYPE_NUM_CATE + 1
        appDel.saveContext()
        let entitiy = NSEntityDescription.entityForName("Category", inManagedObjectContext: contextA!)!
        fetchRequest.entity = entitiy
        let predicate = NSPredicate(format: "(uid=%@)",String(MyTravelTag.UID_NUM))
        fetchRequest.predicate = predicate
        
        categorys = (try! contextA!.executeFetchRequest(fetchRequest) as! [Category])

        sideTableView.showData(self.pins, categorys: categorys,  sTableView: self.sideTableView, tmvControl : self);
        
    }
    @IBAction func actCancelCategory(sender: AnyObject) {
        UIView.animateWithDuration(1.0, animations: {
            self.newCateView.transform = CGAffineTransformMakeTranslation(0.0,0.0);
        })
    }
    
    @IBAction func actUpdateCate(sender: AnyObject) {
        sideTableView.setEditing(true, animated: true)
    }
    
    
    //TOUCH EVENT
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if sideViewSW {
            //사이드뷰가 올라와 있는 경우,
            let touch = touches.first! as UITouch
            let touchLocation = touch.locationInView(self.hiddenView)
                print(touchLocation.x-self.view.frame.width)
                let pos = touchLocation.x-self.sideView.frame.width
            
            if pos > -20.0 {
                UIView.animateWithDuration(0.1, animations: {
                    self.sideView.transform = CGAffineTransformMakeTranslation(0.0,0.0)
                    self.hiddenView.hidden = true
                })
                sideViewSW = false
                
            }else {
                UIView.animateWithDuration(0.1, animations: {
                    self.sideView.transform = CGAffineTransformMakeTranslation(pos,0.0)
                })
            }
            
        }
    }

}
