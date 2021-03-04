//
//  FavoriteViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit

class FavoriteViewController: UIViewController {

    @IBOutlet weak var favoriteTaskTableView: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favorite Task"
        todoListViewModel.showFaveriteList()
        favoriteTaskTableView.reloadData()
        setup()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        todoListViewModel.showFaveriteList()
        favoriteTaskTableView.reloadData()
    }
    
    let todoListViewModel = TodoViewModel()
}

// MARK: - Setup
extension FavoriteViewController {
    func setup() {
        favoriteTaskTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        favoriteTaskTableView.dataSource = self
        favoriteTaskTableView.delegate = self
        favoriteTaskTableView.tableFooterView = UIView()
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
            self.favoriteTaskTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.faveriteButtonHandler = { isFaverite in
            Todo.isFaverite = isFaverite
            self.todoListViewModel.updateTodo(Todo)
            self.favoriteTaskTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.deleteButtonTapHandler = {
            self.todoListViewModel.deleteTodo(Todo)
            self.favoriteTaskTableView.reloadData()
        }

        return cell
    }
}
// MARK: - Button

// MARK: - UITableViewDelegate
extension FavoriteViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todosindex = todoListViewModel.todos[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TodoDetailViewController") as! TodoDetailViewController
        vc.todo = todosindex
        present(vc, animated: true, completion: nil)
        

    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let faverite = favoriteAtcion(at: indexPath)

        return UISwipeActionsConfiguration(actions: [faverite])
    }
    
    func favoriteAtcion(at indexpath: IndexPath) -> UIContextualAction {
        var todo = todoListViewModel.todos[indexpath.row]
        let action = UIContextualAction(style: .normal, title: "faverite") { (action, view, completion) in
            todo.isFaverite = !todo.isFaverite
            self.todoListViewModel.loadTasks()
            self.todoListViewModel.updateTodo(todo)
            self.todoListViewModel.showFaveriteList()
            self.favoriteTaskTableView.reloadData()
        }
        action.backgroundColor = todo.isFaverite ? #colorLiteral(red: 0.007709213533, green: 0.4783661366, blue: 0.9984756112, alpha: 1) : .gray
        action.image = UIImage(named: "star.png")
        return action
        
    }

}
