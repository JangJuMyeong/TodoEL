

import UIKit
import SwipeCellKit
import FSCalendar

class CalendarViewController: UIViewController {
    @IBOutlet weak var todayCollectionView: UICollectionView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    
    let todoListViewModel = TodoViewModel()
    var todoTodayList : [Todo] {
        return todoListViewModel.filterTodayTodos
    }
    
    
    
    var calendarDataSource: [String:String] = [:]
    var calendarDataSource2 : [String : [Todo]] = [:]
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        todoListViewModel.loadTasks()
        todayCollectionView.reloadData()
        calendar.reloadData()
    }
    
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
    
    func setup() {
        self.calendar.dataSource = self
        self.calendar.delegate = self
        todayLabel.text = "Today"
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        todayCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CollectionViewCell")
        navigationItem.title = "Home"
        todoListViewModel.loadTasks()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.appearance.titleWeekendColor = #colorLiteral(red: 1, green: 0.4586423039, blue: 0.5876399875, alpha: 1)
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerMinimumDissolvedAlpha = 0
    }
    
    
}


extension CalendarViewController : UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoTodayList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell()
        }
        
        var todo: Todo
        todo = todoTodayList[indexPath.item]
        cell.updateUI(todo: todo)
        cell.titleLabel.text = todo.task
        cell.dateLabel.text = todoListViewModel.dataGap(todo)
        cell.layer.cornerRadius = 15
        
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

extension CalendarViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var todo: Todo
        todo = todoTodayList[indexPath.item]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TodoDetailViewController") as! TodoDetailViewController
        vc.todo = todo
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CalendarViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let itemSpacing : CGFloat = 10 // 각 아이템끼리의 간격
        let width = (collectionView.bounds.width - itemSpacing * 2)
        
        return CGSize(width: width, height: 60)
    }
}

extension CalendarViewController : SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var todo : Todo
        todo = todoTodayList[indexPath.item]
        
        
        
        
        switch orientation {
        case .left :
            
            let isDoneAction = SwipeAction(style: .default, title: nil, handler: {action, indexPath in
                todo.isDone = !todo.isDone
                self.todoListViewModel.updateTodo(todo)
                self.todayCollectionView.reloadData()
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
                print("click letf")
            })
            isDoneAction.image = UIImage(systemName: "checkmark.circle")
            isDoneAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            
            return [isDoneAction]
        case .right :
            let DeleteAction = SwipeAction(style: .default, title: nil, handler: {action, indexPath in
                
                self.todayCollectionView.delete(todo)
                self.todayCollectionView.reloadData()
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


extension CalendarViewController : FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let dateTodos = todoListViewModel.checkDate(todoListViewModel.todos, date)
        var event = 0
        let isimportant = dateTodos.first{ $0.isImportant == true}
        for i in dateTodos {
            if i == isimportant {
                event = 2
            } else if isimportant == nil {
                event = 1
            }
        }
        return event
    }
    
        
    
    
}
extension CalendarViewController : FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        
        
        let storyBoard = UIStoryboard(name: "CalendarDetail", bundle: nil)
        guard let VC = storyBoard.instantiateViewController(withIdentifier: "CalendarDetail") as? CalendarDetailCollectionView else { return }
        
        VC.calendarDate = date
        
        self.navigationController?.pushViewController(VC, animated: true)
        
        
    }

    
    
    
    
}

