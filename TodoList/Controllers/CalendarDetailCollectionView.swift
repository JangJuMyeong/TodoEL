//
//  CalendarDetailCollectionView.swift
//  TodoList
//
//  Created by 장주명 on 2021/03/13.
//

import UIKit
import SwipeCellKit

class CalendarDetailCollectionView: UIViewController {


    @IBOutlet weak var CalendarDetailCollection: UICollectionView!
    @IBOutlet weak var DateLabel: UILabel!
    var calendarDate : Date?
    

    
    override func viewDidLoad() {
        
        navigationItem.title = "Taks of Date"
        CalendarDetailCollection.dataSource = self
        CalendarDetailCollection.delegate = self
        CalendarDetailCollection.register(UINib(nibName: "CollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CollectionViewCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CalendarDetailCollection.reloadData()
    }



    let todoListViewModel = TodoViewModel()

    
    func changeDate(deadLine:String) -> Date {
        let dateString = deadLine
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let date: Date = dateFormatter.date(from: dateString)!
        
        return date
        
    }
    
    func changeAlwaysDate(deadLine:String) -> Date {
        let dateString = deadLine
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        let date: Date = dateFormatter.date(from: dateString)!
        
        return date
        
    }
    
    @IBAction func AddTodoButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "AddTodo", bundle: nil)
        let addTodoVC = storyBoard.instantiateViewController(withIdentifier: "AddTodoViewController") as! AddTodoViewController
        addTodoVC.delegate = self
        addTodoVC.calendarDate = calendarDate
    
        let navigationController = UINavigationController(rootViewController: addTodoVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true, completion: nil)
        
        addTodoVC.completion = {id ,title, body , date in
            let content = UNMutableNotificationContent()
            content.title = title
            content.sound = .default
            content.body = body
            
            let targetTime = date
            let tigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day,.hour,.minute, .second], from: targetTime), repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: tigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                print("error")
            })
        }
        
    }
    
}

extension CalendarDetailCollectionView: AddTodoDelegate {
    func complete() {
        CalendarDetailCollection.reloadData()
        print("complete")
    }
}

extension CalendarDetailCollectionView : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let date = calendarDate {
            return todoListViewModel.checkDate(todoListViewModel.todos, date).count
        } else {
            return 0
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CalendarDetailCollectionHeaderView", for: indexPath) as? CalendarDetailCollectionHeaderView else {
                return UICollectionReusableView()
            }
            if let date = calendarDate {
                let dateformatter = DateFormatter()
                
                dateformatter.timeStyle = .none
                dateformatter.dateStyle = .long
                header.headerLabel.text = dateformatter.string(from: date)
            }
            
            return header
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {


        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell()
        }

        var todo: Todo!
        if let date = calendarDate {
            todo = todoListViewModel.checkDate(todoListViewModel.todos, date)[indexPath.item]
        }
        cell.updateUI(todo: todo)
        cell.titleLabel.text = todo.task
        cell.dateLabel.text = todoListViewModel.dataGap(todo)
        cell.layer.cornerRadius = 15
        cell.delegate = self
        
        if todo.isAlways {
            cell.backgroundColor = #colorLiteral(red: 0.9162862301, green: 0.9778192639, blue: 0.9108620286, alpha: 1)
        } else if todo.isImportant {
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.7306881547, blue: 0.7135236263, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.9821832776, green: 0.9450852275, blue: 0.7653855681, alpha: 1)
        }

        return cell

    }
}

extension CalendarDetailCollectionView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var todo: Todo!
        if let date = calendarDate {
            todo = todoListViewModel.checkDate(todoListViewModel.todos, date)[indexPath.item]
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TodoDetailViewController") as! TodoDetailViewController
        vc.todo = todo
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension CalendarDetailCollectionView : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {


        let itemSpacing : CGFloat = 10 // 각 아이템끼리의 간격
        let width = (collectionView.bounds.width - itemSpacing * 2)

        return CGSize(width: width, height: 60)
    }
}

class CalendarDetailCollectionHeaderView : UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension CalendarDetailCollectionView : SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var todo : Todo!
        if let date = calendarDate {
            todo = todoListViewModel.checkDate(todoListViewModel.todos, date)[indexPath.item]
        }
        
        
        switch orientation {
        case .left :
            
            let isDoneAction = SwipeAction(style: .default, title: nil, handler: {action, indexPath in
                todo.isDone = !todo.isDone
                self.todoListViewModel.updateTodo(todo)
                self.CalendarDetailCollection.reloadData()
                var targetTime = Date()
                if todo.isDone {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(todo.id)"])
                } else if todo.isDone == false {
                    let content = UNMutableNotificationContent()
                    content.title = todo.task
                    content.sound = .default
                    content.body = todo.detail
                    
                    if todo.isAlways {
                        targetTime = self.changeAlwaysDate(deadLine: todo.time)
                    } else {
                        targetTime = self.changeDate(deadLine: todo.time)
                    }
                    let tigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day,.hour,.minute, .second], from: targetTime), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "\(todo.id)", content: content, trigger: tigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        print("error")
                        
                    })
                }
                print("\(targetTime)")
                print("click letf")
            })
            isDoneAction.image = UIImage(systemName: "checkmark.circle")
            isDoneAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            
            return [isDoneAction]
        case .right :
            let DeleteAction = SwipeAction(style: .default, title: nil, handler: {action, indexPath in
                
                self.todoListViewModel.deleteTodo(todo)
                self.CalendarDetailCollection.reloadData()
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(todo.id)"])
                print("click right")
            })
            DeleteAction.image = UIImage(systemName: "trash")
            DeleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            
            return [DeleteAction]
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        
        options.expansionStyle = .none
        options.transitionStyle = .reveal
        
        return options
        
    }
    
}
