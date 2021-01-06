//
//  NotificationViewController.swift
//  TodoList
//
//  Created by 장주명 on 2020/11/21.
//

import UIKit

import UserNotifications

class NotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in })

        // Do any additional setup after loading the view.
    }
    

    let center = UNUserNotificationCenter.current()

}
