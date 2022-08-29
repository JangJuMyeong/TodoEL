//
//  TodoDetailViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit


class TodoDetailViewController: UIViewController {
    
    var todo : Todo?
    var string : String?
    let notiCenter = NotificationCenter.default
    @IBOutlet var TaskLabel: UILabel!
    @IBOutlet var deadLineLabel: UILabel!
    @IBOutlet weak var detailTask: UITextView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(didRecieveTestNotification(_:)), name: AddTodoViewController.todoDidChange,object: nil)
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    func changeDate(deadLine:String) -> Date {
        
        let dateString = deadLine
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        guard let date: Date = dateFormatter.date(from: dateString) else { return Date() }
        
        return date
    }
    
    func changeAlwaysDate(deadLine:String) -> Date {
        
        let dateString = deadLine
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        guard let date: Date = dateFormatter.date(from: dateString) else { return Date() }
        
        return date
    }
    
    
    
    @objc func didRecieveTestNotification(_ notification: Notification) {
        let getValue = notification.object as! Todo
        var targetTime = Date()
        let content = UNMutableNotificationContent()
        content.title = getValue.task
        content.sound = .default
        content.body = getValue.detail
        if getValue.isAlways {
            targetTime = self.changeAlwaysDate(deadLine: getValue.time)
        } else {
            targetTime = self.changeDate(deadLine: getValue.time)
        }
        let tigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day,.hour,.minute, .second], from: targetTime), repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(getValue.id)", content: content, trigger: tigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            print("error")
            
        })
        todo = getValue
    }
    func updateUI() {
        TaskLabel.text = todo?.task
        deadLineLabel.text = todo?.time
        detailTask.text = todo?.detail
    }
    // MARK: - composdButton
    
    @IBAction func composeButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "AddTodo", bundle: nil)
        let composeVC = storyBoard.instantiateViewController(withIdentifier: "AddTodoViewController") as! AddTodoViewController
        composeVC.delegate = self
        composeVC.editTarget = todo
        let navigationController = UINavigationController(rootViewController: composeVC)
        navigationController.modalPresentationStyle = .fullScreen
    
        self.present(navigationController, animated: true, completion: nil)
    }
    
}
// MARK: - AddTodoDelegate
extension TodoDetailViewController: AddTodoDelegate {
    func complete() {
        print("complete")
    }
}

