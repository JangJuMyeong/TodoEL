//
//  TodoDetailViewController.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit


class TodoDetailViewController: UIViewController {
    
    var todo : Todo?
    
    @IBOutlet var TaskLabel: UILabel!
    @IBOutlet var deadLineLabel: UILabel!
    @IBOutlet var detailTask: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail Task"
        updateUI()
    }
    
    func updateUI() {
        TaskLabel.text = todo?.task
        deadLineLabel.text = todo?.time
        detailTask.text = todo?.detail
    }
    // MARK: - composdButton
    
    @IBAction func composeButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "AddTodo", bundle: nil)
        let composeVC = storyBoard.instantiateViewController(withIdentifier: "AddTodoViewController") as! AddTodoViewController
        composeVC.delegate = self
        composeVC.editTarget = todo
        let navigationController = UINavigationController(rootViewController: composeVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
}
// MARK: - AddTodoDelegate
extension TodoDetailViewController: AddTodoDelegate {
    func complete() {
        print("complete")
    }
}

