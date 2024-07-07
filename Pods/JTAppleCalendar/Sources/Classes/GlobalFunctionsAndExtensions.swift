//
//  GlobalFunctionsAndExtensions.swift
//  Pods
//
//  Created by Jeron Thomas on 2016-06-26.
//
//

func delayRunOnMainThread(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func delayRunOnGlobalThread(_ delay:Double, qos: qos_class_t,closure:()->()) {
    DispatchQueue.global(qos: qos).asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

/// NSDates can be compared with the == and != operators
public func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .orderedSame
}
/// NSDates can be compared with the > and < operators
public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}



extension Date: Comparable { }
extension Date {
    static func startOfMonthForDate(_ date: Date, usingCalendar calendar:Calendar) -> Date? {
        let dayOneComponents = (calendar as NSCalendar).components([.era, .year, .month], from: date)
        return calendar.date(from: dayOneComponents)
    }
    
    static func endOfMonthForDate(_ date: Date, usingCalendar calendar:Calendar) -> Date? {
        var lastDayComponents = (calendar as NSCalendar).components([NSCalendar.Unit.era, NSCalendar.Unit.year, NSCalendar.Unit.month], from: date)
        lastDayComponents.month = lastDayComponents.month! + 1
        lastDayComponents.day = 0
        return calendar.date(from: lastDayComponents)
    }
}
