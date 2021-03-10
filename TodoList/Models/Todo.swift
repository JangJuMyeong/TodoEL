//
//  Todo.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit

struct Todo: Codable, Equatable {
    let id: Int
    var isDone: Bool
    var task: String
    var detail: String
    var time: String
    var isAlways : Bool
    var isImportant : Bool
    
    mutating func update(isDone: Bool, task: String, detail: String, time: String, isAlways: Bool, isImportant: Bool) {
        self.isDone = isDone
        self.task = task
        self.detail = detail
        self.time = time
        self.isAlways = isAlways
        self.isImportant = isImportant
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

class TodoManager {
    
    static let shared = TodoManager()
    
    static var lastId: Int = 0
    
    var todos: [Todo] = []
    
    
    
    func createTodo(detail: String, task: String,time:String, isAlways:Bool, isImportant: Bool ) -> Todo {
        let nextId = TodoManager.lastId + 1
        TodoManager.lastId = nextId
        return Todo(id: nextId, isDone: false, task: task, detail: detail, time : time, isAlways: isAlways , isImportant: isImportant)
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        saveTodo()
    }
    
    func deleteTodo(_ todo: Todo) {
        todos = todos.filter { $0.id != todo.id }
        saveTodo()
    }
    
    func showFaveriteList(){
        todos = todos.filter { $0.isAlways == true }
    }
    
    func updateTodo(_ todo: Todo) {
        guard let index = todos.firstIndex(of: todo) else { return }
        todos[index].update(isDone: todo.isDone, task: todo.task, detail: todo.detail, time: todo.time, isAlways: todo.isAlways, isImportant: todo.isImportant)
        saveTodo()
    }
    
    func saveTodo() {
        Storage.store(todos, to: .documents, as: "todos.json")
    }
    
    func retrieveTodo() {
        todos = Storage.retrive("todos.json", from: .documents, as: [Todo].self) ?? []
        
        let lastId = todos.last?.id ?? 0
        TodoManager.lastId = lastId
    }
    
    func dateGap(_ todo: Todo) -> String {
        
        var dateGap = "Late"
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let currentDate = Date()
        let calendar = Calendar.current
        let date = dateFormatter.date(from: todo.time)!
        let currentCalendarDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: currentDate)
        let todoCalendarDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: date)
        
        if currentCalendarDate.year != todoCalendarDate.year {
            if (todoCalendarDate.year! - currentCalendarDate.year!) == 1 {
                dateGap = String(todoCalendarDate.year! - currentCalendarDate.year!) + " Year"
            } else if (todoCalendarDate.year! - currentCalendarDate.year!) > 1 {
                dateGap = String(todoCalendarDate.year! - currentCalendarDate.year!) + " Years"
            }
        } else if currentCalendarDate.month != todoCalendarDate.month {
            if (todoCalendarDate.month! - currentCalendarDate.month!) == 1 {
                dateGap = String(todoCalendarDate.month! - currentCalendarDate.month!) + " Month"
            } else if (todoCalendarDate.month! - currentCalendarDate.month!) > 1 {
                dateGap = String(todoCalendarDate.month! - currentCalendarDate.month!) + " Months"
            }
        } else if currentCalendarDate.day != todoCalendarDate.day {
            if (todoCalendarDate.day! - currentCalendarDate.day!) == 1 {
                dateGap = String(todoCalendarDate.day! - currentCalendarDate.day!) + " day"
            } else if (todoCalendarDate.day! - currentCalendarDate.day!) > 1 {
                dateGap = String(todoCalendarDate.day! - currentCalendarDate.day!) + " days"
            }
        } else {
            if currentCalendarDate.hour != todoCalendarDate.hour {
                if (todoCalendarDate.hour! - currentCalendarDate.hour!) == 1 {
                    dateGap = String(todoCalendarDate.hour! - currentCalendarDate.hour!) + " hour"
                } else if (todoCalendarDate.hour! - currentCalendarDate.hour!) > 1 {
                    dateGap = String(todoCalendarDate.hour! - currentCalendarDate.hour!) + " hours"
                }
            } else if currentCalendarDate.minute != todoCalendarDate.minute {
                if (todoCalendarDate.minute! - currentCalendarDate.minute!) == 1 {
                    dateGap = String(todoCalendarDate.minute! - currentCalendarDate.minute!) + " minute"
                } else if (todoCalendarDate.minute! - currentCalendarDate.minute!) > 1 {
                    dateGap = String(todoCalendarDate.minute! - currentCalendarDate.minute!) + " minutes"
                }
            } else if currentCalendarDate.second != todoCalendarDate.second {
                if (todoCalendarDate.second! - currentCalendarDate.second!) == 1 {
                    dateGap = String(todoCalendarDate.second! - currentCalendarDate.second!) + " second"
                } else if (todoCalendarDate.second! - currentCalendarDate.second!) > 1 {
                    dateGap = String(todoCalendarDate.second! - currentCalendarDate.second!) + " seconds"
                }
            } else {
                dateGap = "Now"
            }
        }
        
        return dateGap
    }
    
    func filterToday(_ todo: Todo) -> Bool {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let currentDate = Date()
        guard let todoDeadLine = dateFormatter.date(from: todo.time) else { return false }
        let calendar = Calendar.current
        let currentCalendarDate = calendar.dateComponents([.year,.month,.day], from: currentDate)
        let todoCalendarDate = calendar.dateComponents([.year,.month,.day], from: todoDeadLine)
        
        if currentCalendarDate.year == todoCalendarDate.year && currentCalendarDate.month == todoCalendarDate.month && currentCalendarDate.day == todoCalendarDate.day {
            return true
        } else {
            return false
        }
        
        
    }
    
    func isPastday(_ todo : Todo) -> Bool {
        var isPastday = false
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let currentDate = Date()
        let calendar = Calendar.current
        let date: Date = dateFormatter.date(from: todo.time)!
        let currentCalendarDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: currentDate)
        let todoCalendarDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: date)
        
        
        if currentCalendarDate.year != todoCalendarDate.year {
            if (todoCalendarDate.year! - currentCalendarDate.year!) < 0 {
                isPastday = true
            }
        } else if currentCalendarDate.month != todoCalendarDate.month {
            if (todoCalendarDate.month! - currentCalendarDate.month!) < 0 {
                isPastday = true
            }
        } else if currentCalendarDate.day != todoCalendarDate.day {
            if (todoCalendarDate.day! - currentCalendarDate.day!) < 0 {
                isPastday =  true
            }
        }
        
        return isPastday
    }
    
    func TodayTodos(_ todos : [Todo]) -> [Todo] {
        var todaytodos : [Todo] = []
        for i in todos {
            let todayTodo = filterToday(i)
            if todayTodo && !isPastday(i) {
                todaytodos.append(i)
            }
        }
        
        todaytodos = todaytodos.sorted { (pastTodo, afterTodo) -> Bool in
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let calendar = Calendar.current
            guard let pastDeadLine = dateFormatter.date(from: pastTodo.time) else { return false }
            guard let afterDeadLine = dateFormatter.date(from: afterTodo.time) else { return false }
            
            let pastTodoDate = calendar.dateComponents([.hour, .minute, .second], from: pastDeadLine)
            let afterTodoDate = calendar.dateComponents([.hour, .minute, .second], from: afterDeadLine)
            if pastTodoDate.hour! < afterTodoDate.hour! {
                return true
            } else if pastTodoDate.hour! == afterTodoDate.hour!, pastTodoDate.minute! < afterTodoDate.minute! {
                return true
            } else if pastTodoDate.minute! == afterTodoDate.minute!, pastTodoDate.second! < afterTodoDate.second! {
                return true
            } else {
                return false
            }
            
        }
        return todaytodos
    }
    
    func upcomingTodos(_ todos : [Todo]) -> [Todo] {
        var upcomingTodos : [Todo] = []
        for i in todos {
            let todayTodo = filterToday(i)
            if todayTodo == false && !isPastday(i) {
                upcomingTodos.append(i)
            }
        }
        upcomingTodos = upcomingTodos.sorted { (pastTodo, afterTodo) -> Bool in
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let calendar = Calendar.current
            guard let pastDeadLine = dateFormatter.date(from: pastTodo.time) else { return false }
            guard let afterDeadLine = dateFormatter.date(from: afterTodo.time) else { return false }
            
            let pastTodoDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: pastDeadLine)
            let afterTodoDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: afterDeadLine)
            
            if pastTodoDate.year! < afterTodoDate.year! {
                return true
            }else if pastTodoDate.year! == afterTodoDate.year!, pastTodoDate.month! < afterTodoDate.month! {
                return true
            } else if pastTodoDate.month! == afterTodoDate.month!, pastTodoDate.day! < afterTodoDate.day! {
                return true
            } else if pastTodoDate.day! == afterTodoDate.day!,pastTodoDate.hour! < afterTodoDate.hour! {
                return true
            } else if pastTodoDate.hour! == afterTodoDate.hour!, pastTodoDate.minute! < afterTodoDate.minute! {
                return true
            } else if pastTodoDate.minute! == afterTodoDate.minute!, pastTodoDate.second! < afterTodoDate.second! {
                return true
            } else {
                return false
            }
            
        }
        return upcomingTodos
    }
    
}

class TodoViewModel {
    
    enum TaskSection: Int, CaseIterable {
        case today
        case upcoming
        
        var title: String {
            switch self {
            case .today: return "Today"
            default: return "Upcoming"
            }
        }
    }
    
    enum SpecificTaskSection: Int, CaseIterable {
        case today
        case upcoming
        
        var title: String {
            switch self {
            case .today: return "Always"
            default: return "Important"
            }
        }
    }
    
    private let manager = TodoManager.shared
    
    var todos: [Todo] {
        return manager.todos
    }
    
    var filterAlwaysTodos: [Todo] {
        return todos.filter { $0.isAlways == true }
    }
    
    var filterImportantTodos: [Todo] {
        return todos.filter { $0.isImportant == true }
    }
    
    var filterTodayTodos: [Todo] {
        return manager.TodayTodos(todos)
    }
    
    var filterUpcomingTodos: [Todo] {
        return manager.upcomingTodos(todos)
    }
    var numOfTaskSection: Int {
        return TaskSection.allCases.count
    }
    
    var numOfSpecificTaskSection: Int {
        return SpecificTaskSection.allCases.count
    }
    
    func dataGap(_ todo: Todo) -> String {
        return manager.dateGap(todo)
    }
    
    func addTodo(_ todo: Todo) {
        manager.addTodo(todo)
    }
    
    func deleteTodo(_ todo: Todo) {
        manager.deleteTodo(todo)
    }
    
    func updateTodo(_ todo: Todo) {
        manager.updateTodo(todo)
    }
    
    func loadTasks() {
        manager.retrieveTodo()
    }
    
}

