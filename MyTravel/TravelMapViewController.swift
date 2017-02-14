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
    var appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var contextA : NSManagedObjectContext?
    var sideViewSW = false
    
    //UID NUM에 따른 Categroy 호출
    var categorys : Array<Category>!
    //CoreData.sqlite의 저장된 Entity를 배열화 시켜 뿌려주는 배열
    var pins : Array<FavorPin>!
    var googleMapView : GMSMapView?
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
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
    override func viewWillAppear(_ animated: Bool) {
        //CoreData에 있는 Data를 뿌려주는 곳
        
        googleMapView?.clear()
        print("NOW YOUR MAP UID NUM : "+String(MyTravelTag.UID_NUM))
        
                //Category 거름
        let entitiy = NSEntityDescription.entity(forEntityName: "Category", in: contextA!)!
        fetchRequest.entity = entitiy
        let predicate = NSPredicate(format: "(uid=%@)",String(MyTravelTag.UID_NUM))
        fetchRequest.predicate = predicate
        
        categorys = (try! contextA!.fetch(fetchRequest) as! [Category])
        
        setMarker()
        
        MyTravelTag.PRIME_NUM = getPrimeKey()
        mapTitle.text = MyTravelTag.UID_TITLE
        
    }
    func setMarker() {
        let entitiy : NSEntityDescription = NSEntityDescription.entity(forEntityName: "FavorPin", in: contextA!)!
        
        
        fetchRequest.entity = entitiy
        let predicate = NSPredicate(format: "(uid=%@)",String(MyTravelTag.UID_NUM))
        fetchRequest.predicate = predicate
        pins = (try! contextA!.fetch(fetchRequest) as! [FavorPin])
        
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
            googleMapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 80.0))
        }else {
            //처음 메모를 등록할경우 위치값을 기본으로 정함 (서울, 대구, 대전)
            googleMapView?.animate(toLocation: CLLocationCoordinate2D(latitude: 37.5609615, longitude: 126.9757965))
            googleMapView?.animate(toZoom: 10)
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
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        srchDisplayController?.searchResultsTableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        srchDisplayController?.searchResultsTableView.reloadData()
    }
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        srchDisplayController?.isActive = false
        
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
        googleMapView?.animate(toLocation: CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude))
        
    }
    
    //MARK ::MarkerView Event
    
    //Custom MarkerWindow 마커를 클릭했을 때 뜨는 정보창을 커스텀을 만든돠아아아
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = Bundle.main.loadNibNamed("CustomMarkerWindow", owner: self, options: nil)?.first! as! CustomMarkerWindow
        infoWindow.isUserInteractionEnabled = true
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
    
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        tableDataSource?.sourceTextHasChanged(searchString)
        return false
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: NSError) {
        // TODO: Handle the error.
        print("Error: \(error.description)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        
        return true
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        //새로운 마커인 경우..
        var setControl : SetPlaceViewController?
        var alert : UIAlertController?
        var action : UIAlertAction?
        
        if marker.zIndex == 2378 {
            
            alert = UIAlertController(title: "새로운 마커 생성", message:"정보를 추가하시겠습니까?", preferredStyle: .alert)
            action = UIAlertAction(title: "추가하기", style: .default) { _ in
                setControl = self.storyboard?.instantiateViewController(withIdentifier: "SetPlaceViewController") as? SetPlaceViewController
                setControl!.marker = marker
                setControl!.setType = MyTravelTag.SET_PIN_ADD
                setControl!.categorys = self.categorys
                marker.zIndex = 0
                self.navigationController?.pushViewController(setControl!, animated: true)
            }
        //업데이트 할 마커인 경우...
        } else {
            alert = UIAlertController(title: "지도 수정", message:"이 부분을 수정하시겠습니까?", preferredStyle: .alert)
            action = UIAlertAction(title: "수정하기", style: .default) { _ in
                setControl = self.storyboard?.instantiateViewController(withIdentifier: "SetPlaceViewController") as? SetPlaceViewController
                setControl!.setType = MyTravelTag.SET_PIN_UPDATE
                setControl!.marker = marker
                setControl!.categorys = self.categorys
                self.navigationController?.pushViewController(setControl!, animated: true)
            }
        }
        
        let cancel = UIAlertAction(title: "취소하기", style: .cancel, handler: { _ in
            if marker.zIndex == 2378 {
                marker.map = nil
            }else {
                
            }
            
        })
        alert!.addAction(action!)
        alert!.addAction(cancel)
        self.present(alert!, animated: true){}

    }
    
    //MARK :: IBACTION
    
    //카테고리 추가, 사이드뷰를 백
    @IBAction func actCancelHamberger(_ sender: AnyObject) {
        sideViewSW = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.hiddenView.isHidden = true
            self.sideView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            self.newCateView.transform = CGAffineTransform(translationX: 0.0,y: 0.0);
            }, completion: nil)
    }
    @IBAction func actHamberger(_ sender: AnyObject) {
        sideViewSW = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.hiddenView.isHidden = false
            self.sideView.transform = CGAffineTransform(translationX: -self.sideView.frame.width, y: 0.0)
            }, completion: nil)
        
        sideTableView.showData(self.pins, categorys: categorys,  sTableView: self.sideTableView, tmvControl : self);
        
    }
    //뒤로가기 버튼
    @IBAction func actBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    //UID 기준으로 카테고리를 생성하는 뷰 띄움
    @IBAction func actAddCategory(_ sender: AnyObject) {
        UIView.animate(withDuration: 1.0, animations: {
            self.newCateView.transform = CGAffineTransform(translationX: 0.0, y: -self.view.frame.height/2);
        })
    }
    
    //카테고리 저장
    @IBAction func actSaveCategory(_ sender: AnyObject) {
        let cate : Category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: contextA!) as! Category
        cate.uid = MyTravelTag.UID_NUM
        cate.title = cateTitleTF.text!
        cate.typenum = MyTravelTag.TYPE_NUM_CATE
        MyTravelTag.TYPE_NUM_CATE = MyTravelTag.TYPE_NUM_CATE + 1
        appDel.saveContext()
        let entitiy = NSEntityDescription.entity(forEntityName: "Category", in: contextA!)!
        fetchRequest.entity = entitiy
        let predicate = NSPredicate(format: "(uid=%@)",String(MyTravelTag.UID_NUM))
        fetchRequest.predicate = predicate
        
        categorys = (try! contextA!.fetch(fetchRequest) as! [Category])

        sideTableView.showData(self.pins, categorys: categorys,  sTableView: self.sideTableView, tmvControl : self);
        
    }
    @IBAction func actCancelCategory(_ sender: AnyObject) {
        UIView.animate(withDuration: 1.0, animations: {
            self.newCateView.transform = CGAffineTransform(translationX: 0.0,y: 0.0);
        })
    }
    
    @IBAction func actUpdateCate(_ sender: AnyObject) {
        sideTableView.setEditing(true, animated: true)
    }
    
    
    //TOUCH EVENT
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sideViewSW {
            //사이드뷰가 올라와 있는 경우,
            let touch = touches.first! as UITouch
            let touchLocation = touch.location(in: self.hiddenView)
                print(touchLocation.x-self.view.frame.width)
                let pos = touchLocation.x-self.sideView.frame.width
            
            if pos > -20.0 {
                UIView.animate(withDuration: 0.1, animations: {
                    self.sideView.transform = CGAffineTransform(translationX: 0.0,y: 0.0)
                    self.hiddenView.isHidden = true
                })
                sideViewSW = false
                
            }else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.sideView.transform = CGAffineTransform(translationX: pos,y: 0.0)
                })
            }
            
        }
    }

}
