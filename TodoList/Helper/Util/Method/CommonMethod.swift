//
//  CommonMethod.swift
//  TodoList
//
//  Created by 장주명 on 2022/05/22.
//

import Foundation

public class CommonMethod {
    
    static let shared = CommonMethod()
    
    func defualtDateFormatter(date : Date) -> String {
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = .none
        dateformatter.timeStyle = .short
        
        return dateformatter.string(from: date)
    }
    
    func longStyleDayFormatter(date : Date) -> String {
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = .long
        dateformatter.timeStyle = .short
        
        return dateformatter.string(from: date)
    }
    
    private init() { }
        
}
