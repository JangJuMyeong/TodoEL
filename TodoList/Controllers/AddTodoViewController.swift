//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit

protocol AddTodoDelegate: class {
    func complete()
}

class AddTodoViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var AlwaysButton: UIButton!
    @IBOutlet weak var special: UIButton!
    @IBOutlet var taskField: UITextField!
    @IBOutlet var deadLinePiker: UIDatePicker!
    @IBOutlet var detailTaskView: UITextView!
    
    weak var delegate: AddTodoDelegate?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var editTarget : Todo?
    var deadlineTime : String?
    var completion : ((Int ,String, String, Date) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        placeHolderLayer()
        deadLinePiker.addTarget(self, action: #selector(changed), for: .valueChanged)
        if let Todo = editTarget {
            navigationItem.title = "Edit Task"
            taskField.text = Todo.task
            deadLinePiker.date = changeDate(deadLine:Todo.time)
            detailTaskView.text = Todo.detail
            
            detailTaskView.becomeFirstResponder()
            

        } else {
            placeholderSetting()
            navigationItem.title = "New Task"
            taskField.text = ""
            deadLinePiker.date = Date()
        }
        
        
    }
    
    let todoListViewModel = TodoViewModel()
    
    func placeholderSetting() {
        detailTaskView.delegate = self // UITextView가 유저가 선언한 outlet
        detailTaskView.placeholder = ""
        
    }
    
}

// MARK: - Button
extension AddTodoViewController {
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        guard let Task = taskField.text, Task.isEmpty == false else {
            alert(message: "Pleace, Write down your task.")
            return }
        guard let DeadLineTime = deadlineTime else {
            alert(message: "Pleace, Set a deadline time.")
            return }
        guard let Detial = detailTaskView.text,Detial.isEmpty == false else {
            alert(message: "Pleace, Write down your task detail.")
            return }
        
        let todo = TodoManager.shared.createTodo(detail: Detial, task: Task, time: DeadLineTime)
        

        if let target = editTarget {
            todoListViewModel.updateTodo(target)
        } else {
            todoListViewModel.addTodo(todo)
        }
        
        self.dismiss(animated: true, completion: {
            self.delegate?.complete()
        })
        
        completion?(todo.id,Task, Detial, changeDate(deadLine: DeadLineTime))
    }
    
    @IBAction func alwaysButtonAction(_ sender: UIButton) {
        if special.isSelected {
            special.isSelected = false
            AlwaysButton.isSelected = true
        }
        AlwaysButton.isSelected = true
    }
    
    @IBAction func specialBUttonAction(_ sender: UIButton) {
        if AlwaysButton.isSelected {
            AlwaysButton.isSelected = false
            special.isSelected = true
        }
        
        special.isSelected = true
    }
    
    
}
//MARK:-DeadLine
extension AddTodoViewController {
    
    @objc func changed() {
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = .long
        dateformatter.timeStyle = .short
        
        let dateString = dateformatter.string(from: deadLinePiker.date)
        deadlineTime = dateString
    }
    
    func changeDate(deadLine:String) -> Date {
        let dateString = deadLine
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let date: Date = dateFormatter.date(from: dateString)!
        
        return date
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
