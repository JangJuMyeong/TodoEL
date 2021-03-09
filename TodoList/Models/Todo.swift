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
        
        var dateGap = ""
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
        let currentDate = Date()
        let calendar = Calendar.current
        let date: Date = dateFormatter.date(from: todo.time)!
        let currentCalendarDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: currentDate)
        let todoCalendarDate = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: date)
        
        
        if currentCalendarDate.year != todoCalendarDate.year {
            dateGap = String(currentCalendarDate.year! - todoCalendarDate.year!)
        } else if currentCalendarDate.month != todoCalendarDate.month {
            dateGap = String(currentCalendarDate.month! - todoCalendarDate.month!)
        } else if currentCalendarDate.day != todoCalendarDate.day {
            dateGap = String(currentCalendarDate.day! - todoCalendarDate.day!)
        }
        
        return dateGap
    }
    
    func filterToday(_ todo: Todo) -> Bool {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
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
    
    func TodayTodos(_ todos : [Todo]) -> [Todo] {
        var todaytodos : [Todo] = []
        for i in todos {
            let todayTodo = filterToday(i)
            if todayTodo {
                todaytodos.append(i)
            }
        }
        return todaytodos
    }
    
    func upcomingTodos(_ todos : [Todo]) -> [Todo] {
        var todaytodos : [Todo] = []
        for i in todos {
            let todayTodo = filterToday(i)
            if todayTodo == false {
                todaytodos.append(i)
            }
        }
        return todaytodos
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
        return todos.filter { $0.isImportant == false }
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

