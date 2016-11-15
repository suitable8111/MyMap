//
//  PinTitle.swift
//  MyTravel
//
//  Created by Daeho on 2016. 7. 31..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import Foundation
import CoreData

@objc(PinTitle)

class PinTitle:NSManagedObject {
    
    
    //필수
    @NSManaged var title: String
    @NSManaged var uid: Int64
    @NSManaged var startdate: String
    @NSManaged var enddate: String
    
    //옵션
    @NSManaged var nation: String
    @NSManaged var triptype: String
    
}
    