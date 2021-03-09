//
//  ViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//
import SwipeCellKit
import UserNotifications
import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var taskCollectionVeiw: UICollectionView!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        navigationItem.title = "Task"
        todoListViewModel.loadTasks()
        taskCollectionVeiw.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success,error in
            if let error = error{
                print("error = \(error)")
            }
        })
        setup()
    }
    
    let todoListViewModel = TodoViewModel()
    
    func changeDate(deadLine:String) -> Date {
        let dateString = deadLine
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
        let date: Date = dateFormatter.date(from: dateString)!
        
        return date
    }
    
}

// MARK: - Setup
extension ListViewController {
    func setup() {
        taskCollectionVeiw.dataSource = self
        taskCollectionVeiw.delegate = self
        todoListViewModel.loadTasks()
    }
}

// MARK: - Button
extension ListViewController {
    
    @IBAction func addTaskButton(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "AddTodo", bundle: nil)
        let addTodoVC = storyBoard.instantiateViewController(withIdentifier: "AddTodoViewController") as! AddTodoViewController
        addTodoVC.delegate = self
    
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

// MARK: - AddTodoDelegate
extension ListViewController: AddTodoDelegate {
    func complete() {
        taskCollectionVeiw.reloadData()
        print("complete")
    }
}

// MARK: - UICollectionViewDataSource
extension ListViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return todoListViewModel.numOfTaskSection
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TodoListHeaderView", for: indexPath) as? TodoListHeaderView else {
                return UICollectionReusableView()
            }
            
            guard let section = TodoViewModel.TaskSection(rawValue: indexPath.section) else {
                return UICollectionReusableView()
            }
            
            header.headerLabel.text = section.title
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return todoListViewModel.filterTodayTodos.count
        } else {
            return todoListViewModel.filterUpcomingTodos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCell", for: indexPath) as? TaskCollectionViewCell else { return UICollectionViewCell() }
        var todo: Todo
        if indexPath.section == 0 {
            todo = todoListViewModel.filterTodayTodos[indexPath.item]
        } else {
            todo = todoListViewModel.filterUpcomingTodos[indexPath.item]
        }
        cell.updateUI(todo: todo)
        cell.titleLabel.text = todo.task
        cell.dateLabel.text = todo.time
        cell.layer.cornerRadius = 15
        cell.delegate = self

        if todo.isAlways {
            cell.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else if todo.isImportant {
            cell.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.532776773, green: 0.7595240474, blue: 0.9884788394, alpha: 1)
        }
        
        
        return cell
    }
    
    
}
// MARK: - UICollectionViewDelegate
extension ListViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let todosindex = todoListViewModel.todos[indexPath.item]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TodoDetailViewController") as! TodoDetailViewController
        vc.todo = todosindex
        present(vc, animated: true, completion: nil)
    }
    
}

extension ListViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let itemSpacing : CGFloat = 10 // 각 아이템끼리의 간격
        let width = (collectionView.bounds.width - itemSpacing * 2)
        
        return CGSize(width: width, height: 60)
    }
}


extension ListViewController : SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var todo : Todo!
        if indexPath.section == 0 {
           todo = todoListViewModel.filterTodayTodos[indexPath.item]
        } else {
            todo = todoListViewModel.filterUpcomingTodos[indexPath.item]
        }

        
        
        switch orientation {
        case .left :
            
            let isDoneAction = SwipeAction(style: .default, title: nil, handler: {action, indexPath in
                todo.isDone = !todo.isDone
                self.todoListViewModel.updateTodo(todo)
                self.taskCollectionVeiw.reloadData()
                if todo.isDone {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(todo.id)"])
                } else if todo.isDone == false {
                    let content = UNMutableNotificationContent()
                    content.title = todo.task
                    content.sound = .default
                    content.body = todo.detail
                    
                    let targetTime = self.changeDate(deadLine: todo.time)
                    let tigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day,.hour,.minute, .second], from: targetTime), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "\(todo.id)", content: content, trigger: tigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        print("error")
                    })
                }
                print("click letf")
            })
            isDoneAction.image = UIImage(systemName: "checkmark.circle")
            isDoneAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            
            return [isDoneAction]
        case .right :
            let DeleteAction = SwipeAction(style: .default, title: nil, handler: {action, indexPath in
                
                self.todoListViewModel.deleteTodo(todo)
                self.taskCollectionVeiw.reloadData()
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
