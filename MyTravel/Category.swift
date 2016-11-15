//
//  Category.swift
//  MyTravel
//
//  Created by Daeho on 2016. 10. 9..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import Foundation
import CoreData

@objc(Category)

class Category:NSManagedObject {

    //제목
    @NSManaged var title: String
    
    //고유 번호(그룹 번호의 카테고리를 가져옴)
    @NSManaged var uid: Int64
    
    //DateView 의 고유 번호를 심음(그룹 번호의 카테고리를 가져옴)
    @NSManaged var typenum: Int64
}