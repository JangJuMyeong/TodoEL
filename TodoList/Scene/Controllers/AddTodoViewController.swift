//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit

protocol AddTodoDelegate: AnyObject {
    func complete()
}

class AddTodoViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var AlwaysButton: UIButton!
    @IBOutlet weak var importantButton: UIButton!
    @IBOutlet var taskField: UITextField!
    @IBOutlet var deadLinePiker: UIDatePicker!
    @IBOutlet var detailTaskView: UITextView!
    @IBOutlet weak var viewButtom: NSLayoutConstraint!
    
    weak var delegate: AddTodoDelegate?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var subView: UIView!
    
    func defualtDateStirng() -> String {
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = .none
        dateformatter.timeStyle = .short
        
        return dateformatter.string(from: Date())
        
    }
    var calendarDate : Date?
    var editTarget : Todo?
    var deadlineTime : String?
    var isAlways = false
    var isImportant = false
    var completion : ((Int ,String, String, Date) -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.addSubview(subView)
        self.subView.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setup()
        placeHolderLayer()
    
    }
    

    let todoListViewModel = TodoViewModel()
    
    
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        detailTaskView.delegate = self //

        deadLinePiker.addTarget(self, action: #selector(changed), for: .valueChanged)
        
        if let Todo = editTarget {
            navigationItem.title = "Edit Task"
            taskField.text = Todo.task
            deadLinePiker.date = changeDate(deadLine:Todo.time)
            detailTaskView.text = Todo.detail
            deadlineTime = Todo.time
            isAlways = Todo.isAlways
            isImportant = Todo.isImportant
            
            if Todo.isAlways{
                AlwaysButton.isSelected = true
                importantButton.isEnabled = false
                self.deadLinePiker.datePickerMode = .time
                self.deadLinePiker.preferredDatePickerStyle = .wheels
            }
            
            if Todo.isImportant {
                AlwaysButton.isEnabled = false
                importantButton.isSelected = true
            }
            
            
        }else if calendarDate != nil {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .long
            dateformatter.timeStyle = .short
            
            guard let calendardate = calendarDate else { return}
            deadLinePiker.date = calendardate
            deadlineTime = dateformatter.string(from: calendardate)
        } else {
            detailTaskView.placeholder = ""
            taskField.delegate = self
            navigationItem.title = "New Task"
            taskField.text = ""
            deadLinePiker.date = Date()
        }
        
        
    }
    
}

// MARK: - Button
extension AddTodoViewController {
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        
        if editTarget != nil {
            
            guard let targetTask = taskField.text, targetTask.isEmpty == false else {
                alert(message: "Pleace, Write down your task.")
                return }
            guard let targetDeadLineTime = deadlineTime else {
                return }
            guard let targetDetial = detailTaskView.text, targetDetial.isEmpty == false else {
                alert(message: "Pleace, Write down your task detail.")
                return }
            editTarget?.task = targetTask
            editTarget?.time = targetDeadLineTime
            editTarget?.detail = targetDetial
            editTarget?.isAlways = isAlways
            editTarget?.isImportant = isImportant
            if let target = editTarget {
     
                todoListViewModel.updateTodo(target)
                completion?(target.id,targetTask, targetDetial, changeDate(deadLine: targetDeadLineTime))
            }
            
            guard let target = editTarget else { return }
            if let index = todoListViewModel.todos.firstIndex(of: target) {
                editTarget = todoListViewModel.todos[index]
            }
            
            NotificationCenter.default.post(name: AddTodoViewController.todoDidChange, object: editTarget, userInfo: nil)
        } else {
            guard let Task = taskField.text, Task.isEmpty == false else {
                alert(message: "Pleace, Write down your task.")
                return }
            guard let DeadLineTime = deadlineTime else {
                return alert(message: "The selected time and the current time are the same. Please, select another time.") }
            guard let Detial = detailTaskView.text, Detial.isEmpty == false else {
                alert(message: "Pleace, Write down your task detail.")
                return }
            
            let todo = TodoManager.shared.createTodo(detail: Detial, task: Task, time: DeadLineTime, isAlways: isAlways, isImportant : isImportant)
            todoListViewModel.addTodo(todo)
            completion?(todo.id,Task, Detial, changeDate(deadLine: DeadLineTime))
        }
        
        
        
        
        self.dismiss(animated: true, completion: {
            self.delegate?.complete()
            
        })
        isAlways = false
        isImportant = false
        
    }
    
    @IBAction func alwaysButtonAction(_ sender: UIButton) {
        
        self.deadLinePiker.datePickerMode = .time
        self.deadLinePiker.preferredDatePickerStyle = .wheels
        if AlwaysButton.isSelected {
            AlwaysButton.isSelected = false
            isAlways = false
            self.deadLinePiker.datePickerMode = .dateAndTime
            self.deadLinePiker.preferredDatePickerStyle = .inline
            
        } else {
            AlwaysButton.isSelected = true
            isAlways = true
            importantButton.isSelected = false
            isImportant = false
        }
        
        print("always = \(isAlways) : importnat = \(isImportant)")
    }
    
    @IBAction func specialBUttonAction(_ sender: UIButton) {
        if importantButton.isSelected {
            importantButton.isSelected = false
            isImportant = false
            
        } else {
            importantButton.isSelected = true
            isImportant = true
            AlwaysButton.isSelected = false
            isAlways = false
            self.deadLinePiker.datePickerMode = .dateAndTime
            self.deadLinePiker.preferredDatePickerStyle = .inline
        }
        
        print("always - \(isAlways) : importnat - \(isImportant)")
    }
    
    
    
    
}
//MARK:-DeadLine
extension AddTodoViewController {
    
    @objc func changed() {
        if editTarget != nil {
            var dateDeadLine = "Unknown"
            if let target = editTarget?.isAlways{
                if target {
                    let dateformatter = DateFormatter()
                    
                    dateformatter.dateStyle = .none
                    dateformatter.timeStyle = .short
                    
                    dateDeadLine = dateformatter.string(from: deadLinePiker.date)
                    deadlineTime = dateDeadLine
                } else {
                    let dateformatter = DateFormatter()
                    
                    dateformatter.dateStyle = .long
                    dateformatter.timeStyle = .short
                    
                    dateDeadLine = dateformatter.string(from: deadLinePiker.date)
                    deadlineTime = dateDeadLine
                }
                
            }
            
        } else {
            if isAlways {
                let dateformatter = DateFormatter()
                
                dateformatter.dateStyle = .none
                dateformatter.timeStyle = .short
                
                let dateString = dateformatter.string(from: deadLinePiker.date)
                deadlineTime = dateString
            } else {
                let dateformatter = DateFormatter()
                
                dateformatter.dateStyle = .long
                dateformatter.timeStyle = .short
                
                let dateString = dateformatter.string(from: deadLinePiker.date)
                deadlineTime = dateString
            }
        }
    }
    
    func changeDate(deadLine:String) -> Date {
        let deadLinseStirng = deadLine
        if editTarget != nil {
            var targetDate = Date()
            if let target = editTarget?.isAlways {
                if target {
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateStyle = .none
                    dateFormatter.timeStyle = .short
                    
                    if let date = dateFormatter.date(from: deadLinseStirng) {
                        targetDate = date
                    }
                } else {
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateStyle = .long
                    dateFormatter.timeStyle = .short
                    
                    if let date = dateFormatter.date(from: deadLinseStirng) {
                        targetDate = date
                    }
                }
                
            }
            
            return targetDate
            
            
        } else {
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            
            
            guard let date: Date = dateFormatter.date(from: deadLinseStirng) else { return Date() }
            
            return date
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskField.resignFirstResponder()
        return true
    }
}




//MARK:-PleacHolder
extension AddTodoViewController {
    func placeHolderLayer() {
        self.detailTaskView.layer.borderColor = #colorLiteral(red: 0.7999123931, green: 0.8000506759, blue: 0.7999034524, alpha: 1)
        self.detailTaskView.layer.borderWidth = 0.5
        self.detailTaskView.layer.cornerRadius = 10
    }
}
extension UITextView : UITextViewDelegate {
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    public var placeholder: String? {
        get {
            var placeholderText: String?
            if let placeholderLbl = self.viewWithTag(50) as? UILabel {
                placeholderText = placeholderLbl.text
            }
            return placeholderText
        }
        set {
            if let placeholderLbl = self.viewWithTag(50) as! UILabel? {
                placeholderLbl.text = newValue
                placeholderLbl.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLbl = self.viewWithTag(50) as? UILabel {
            placeholderLbl.isHidden = self.text.count > 0
        }
    }
    private func resizePlaceholder() {
        if let placeholderLbl = self.viewWithTag(50) as! UILabel? {
            let x = self.textContainerInset.left + 6
            let y = self.textContainerInset.top - 2
            let width = self.frame.width - (x * 2)
            let height = placeholderLbl.frame.height
            placeholderLbl.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLbl = UILabel()
        placeholderLbl.text = "Wirte down your task detail."
        placeholderLbl.sizeToFit()
        placeholderLbl.font = self.font
        placeholderLbl.textColor = #colorLiteral(red: 0.7999123931, green: 0.8000506759, blue: 0.7999034524, alpha: 1)
        placeholderLbl.tag = 50
        placeholderLbl.isHidden = self.text.count > 0
        self.addSubview(placeholderLbl)
        self.resizePlaceholder()
        self.delegate = self
        
    }
}

extension AddTodoViewController {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // [x] TODO: 키보드 높이에 따른 인풋뷰 위치 변경
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
            viewButtom.constant = adjustmentHeight
        } else {
            viewButtom.constant = 0
        }
        
        print("---> Keyboard End Frame: \(keyboardFrame)")
    }
    static let todoDidChange = Notification.Name(rawValue: "todoDidChange")
    static let newTodoSave = Notification.Name(rawValue: "newTodoSave")
}
