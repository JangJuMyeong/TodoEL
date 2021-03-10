

import UIKit
import JTAppleCalendar
import SwipeCellKit

class CalendarViewController: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!
    @IBOutlet weak var todayCollectionView: UICollectionView!
    
    let todoListViewModel = TodoViewModel()
    
    var calendarDataSource: [String:String] = [:]
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
        todayCollectionView.reloadData()
    }
    
    func changeDate(deadLine:String) -> Date {
        let dateString = deadLine
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let date: Date = dateFormatter.date(from: dateString)!
        
        return date
    }
    
    func setup() {
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        todayCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CollectionViewCell")
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        populateDataSource()
        navigationItem.title = "Home"
        todoListViewModel.loadTasks()
    }
    
    func populateDataSource() {
        // You can get the data from a server.
        // Then convert that data into a form that can be used by the calendar.
        calendarDataSource = [
            "07-Jan-2018": "SomeData",
            "15-Jan-2018": "SomeMoreData",
            "15-Feb-2018": "MoreData",
            "21-Feb-2018": "onlyData",
        ]
        // update the calendar
        calendarView.reloadData()
    }
    
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    
    
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
    }
    
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        let dateString = formatter.string(from: cellState.date)
        if calendarDataSource[dateString] == nil {
            cell.eventDot.isHidden = true
        } else {
            cell.eventDot.isHidden = false
        }
    }
    
}
extension CalendarViewController : JTACMonthViewDataSource {
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let formatter = DateFormatter()  // Declare this outside, to avoid instancing this heavy class multiple times.
        formatter.dateFormat = "YYYY MMM"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthLabel.text = formatter.string(from: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let startDate = formatter.date(from: "01-jan-2018")!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    
    
}
extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
}

extension CalendarViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CalendarViewViewHeaderView", for: indexPath) as? CalendarViewViewHeaderView else {
            return UICollectionReusableView()
        }
        
        
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoListViewModel.filterTodayTodos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell()
        }
        
        var todo: Todo
        if indexPath.section == 0 {
            todo = todoListViewModel.filterTodayTodos[indexPath.item]
        } else {
            todo = todoListViewModel.filterUpcomingTodos[indexPath.item]
        }
        cell.updateUI(todo: todo)
        cell.titleLabel.text = todo.task
        cell.dateLabel.text = todoListViewModel.dataGap(todo)
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

extension CalendarViewController : UICollectionViewDelegate {
    
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
                self.todayCollectionView.reloadData()
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

class CalendarViewViewHeaderView : UICollectionReusableView {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
