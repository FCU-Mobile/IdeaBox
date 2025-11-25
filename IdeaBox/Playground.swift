//
//  Playground.swift
//  IdeaBox
//
//  Created by Harry Ng on 11/25/25.
//

import Foundation
import Playgrounds
import SwiftDate

#Playground {
    let calendar = Calendar.current
    let fastMidnight = calendar.dateComponents([.year, .month], from: Date())

    let date = DateInRegion().dateAt(.startOfDay).date
    date + 1.hours

    /// 1. 如何使用 SwiftDate 取得今天的日期並格式化為 'yyyy-MM-dd 格式？"
    Date().toFormat("yyyy-MM-dd")

    /// 2. 如何計算兩個日期之間的天數差異？
    let date1 = Date(timeIntervalSince1970: 1_764_036_000)
    let date2 = Date(timeIntervalSince1970: 1_764_043_200)
    let diff = (date2 - date1).in(.hour)

    /// 3. 如何將一個日期加上 3 天並取得新的日期？
    date1 + 3.days
    
    /// 4. 如何判斷一個日期是否在本週內？
    date1.compare(.isThisWeek)

    /// 5. 如何使用 SwiftDate 時間區功能取得當前時區？
    DateInRegion().region

    /// 6. 如何將一個日期轉換為不同的時區？
    let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaTokyo, locale: Locales.englishUnitedStates)
    DateInRegion().convertTo(region: region).toFormat("H:m")

    /// 7. 如何使用 SwiftDate 取得本月的第一天和最後一天？
    Date().dateAt(.startOfMonth)
    Date().dateAt(.endOfMonth)

    /// 8. 如何比較兩個日期並判斷哪一個較早？
    date1 < date2

    /// 9. 如何使用 SwiftDate 取得昨天的日期？
    (DateInRegion() - 1.days).toFormat("yyyy-MM-dd")

    /// 10. 如何將一個日期格式化為 'EEEE, MMM d, yyyy' 的字串？
    Date().toFormat("EEEE, MMM d, yyyy")
}
