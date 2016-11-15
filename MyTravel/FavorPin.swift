//
//  FavorPin.swift
//  MyTravel
//
//  Created by Daeho on 2016. 7. 30..
//  Copyright © 2016년 Daeho. All rights reserved.
//
import Foundation
import CoreData

@objc(FavorPin)

class FavorPin:NSManagedObject {
    //내용
    @NSManaged var content: String
    //주소
    @NSManaged var pos: String
    //제목
    @NSManaged var title: String
    //타입
    @NSManaged var type: Int
    //날짜
    @NSManaged var date: String
    //위도
    @NSManaged var lat: Double
    //경도
    @NSManaged var long: Double
    //번호(그룹)
    @NSManaged var uid: Int64
    //고유번호
    @NSManaged var primekey: Int64
}