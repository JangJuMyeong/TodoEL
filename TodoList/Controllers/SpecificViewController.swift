//
//  FavoriteViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit
import SwipeCellKit

class SpecificViewController: UIViewController {
    
    @IBOutlet weak var SpecificCollectionView : UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Specific Task"
        SpecificCollectionView.reloadData()
        setup()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        SpecificCollectionView.reloadData()
        todoListViewModel.loadTasks()
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
}
// MARK: - Setup
extension SpecificViewController {
    func setup() {
        SpecificCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CollectionViewCell")
        SpecificCollectionView.dataSource = self
        SpecificCollectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource
extension SpecificViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return todoListViewModel.numOfSpecificTaskSection
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SpecificViewHeaderView", for: indexPath) as? SpecificViewHeaderView else {
                return UICollectionReusableView()
            }
            
            guard let section = TodoViewModel.SpecificTaskSection(rawValue: indexPath.section) else {
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
            return todoListViewModel.filterAlwaysTodos.count
        } else {
            return todoListViewModel.filterImportantTodos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        var todo: Todo
        if indexPath.section == 0 {
            todo = todoListViewModel.filterAlwaysTodos[indexPath.item]
        } else {
            todo = todoListViewModel.filterImportantTodos[indexPath.item]
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
extension SpecificViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        let todosindex = todoListViewModel.todos[indexPath!.item]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TodoDetailViewController") as! TodoDetailViewController
        vc.todo = todosindex
        present(vc, animated: true, completion: nil)
    }
    
    
}

extension SpecificViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let itemSpacing : CGFloat = 10 // 각 아이템끼리의 간격
        let width = (collectionView.bounds.width - itemSpacing * 2)
        
        return CGSize(width: width, height: 60)
    }
}

extension SpecificViewController : SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var todo : Todo
        if indexPath.section == 0 {
           todo = todoListViewModel.filterAlwaysTodos[indexPath.item]
        } else {
            todo = todoListViewModel.filterImportantTodos[indexPath.item]
        }
        
        switch orientation {
        case .left :
            
            let isDoneAction = SwipeAction(style: .default, title: nil, handler: {action, indexPath in
                todo.isDone = !todo.isDone
                self.todoListViewModel.updateTodo(todo)
                self.SpecificCollectionView.reloadData()
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
                self.SpecificCollectionView.reloadData()
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

class SpecificViewHeaderView : UICollectionReusableView {
     
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
