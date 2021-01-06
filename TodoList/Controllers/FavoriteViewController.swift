//
//  FavoriteViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit

class FavoriteViewController: UIViewController {

    @IBOutlet weak var taskTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        title = "Task"
        todoListViewModel.showFaveriteList()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorite Task"
        setup()
    }
    
    let todoListViewModel = TodoViewModel()
}

// MARK: - Setup
extension FavoriteViewController {
    func setup() {
        taskTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        taskTableView.dataSource = self
        taskTableView.delegate = self
        taskTableView.tableFooterView = UIView()
    }
}


// MARK: - UITableViewDataSource
extension FavoriteViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoListViewModel.todos.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }

        var Todo = todoListViewModel.todos[indexPath.item]
        cell.updateUI(todo: Todo)
        cell.titleLabel.text = Todo.task
        cell.dateLabel.text = Todo.time
        
        cell.doneButtonHandler = { isDone in
            Todo.isDone = isDone
            self.todoListViewModel.updateTodo(Todo)
            self.taskTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.faveriteButtonHandler = { isFaverite in
            Todo.isFaverite = isFaverite
            self.todoListViewModel.updateTodo(Todo)
            self.taskTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.deleteButtonTapHandler = {
            self.todoListViewModel.deleteTodo(Todo)
            self.taskTableView.reloadData()
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoriteViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todosindex = todoListViewModel.todos[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TodoDetailViewController") as! TodoDetailViewController
        vc.todo = todosindex
        present(vc, animated: true, completion: nil)
        

    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let faverite = faveriteAtcion(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [faverite])
    }
    
    func faveriteAtcion(at indexpath: IndexPath) -> UIContextualAction {
        var todo = todoListViewModel.todos[indexpath.row]
        let action = UIContextualAction(style: .normal, title: "faverite") { (action, view, completion) in
            todo.isFaverite = !todo.isFaverite
            self.todoListViewModel.updateTodo(todo)
            self.taskTableView.reloadData()
            
        }
        action.backgroundColor = todo.isFaverite ? #colorLiteral(red: 0.007709213533, green: 0.4783661366, blue: 0.9984756112, alpha: 1) : .gray
        action.image = UIImage(named: "star.png")
        return action
    }
}
