//
//  MyTravelTag.swift
//  MyTravel
//
//  Created by Daeho on 2016. 7. 31..
//  Copyright © 2016년 Daeho. All rights reserved.
//

import Foundation
import UIKit

class MyTravelTag : NSObject {
    static var PRIME_NUM : Int64 = 0
    static var UID_NUM : Int64 = 0
    static var TYPE_NUM_CATE : Int64 = 0
    static var UID_TITLE : String = "TITLE"
    
    //COLOR
    static let BACKGROUND_MAIN = "6EAAFA"
    static let BOARDER_COLOR = "BEBEBE"
    
    
    static let SET_PIN_UPDATE = "UPDATE"
    static let SET_PIN_ADD = "ADD"
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
