//
//  TaskTableViewCell.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit

class TaskTableViewCell: UICollectionViewCell {

    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var stikeThroughView: UIView!
    
    @IBOutlet var strikeTroughWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    var doneButtonHandler: ((Bool) -> Void)?
    var faveriteButtonHandler : ((Bool) -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
    func updateUI(todo: Todo) {
        // [x] TODO: 셀 업데이트 하기
        stateButton.isSelected = todo.isDone
        showStrikeThrough(todo.isDone)
        titleLabel.text = todo.detail
        titleLabel.alpha = todo.isDone ? 0.2 : 1
        deleteButton.isHidden = todo.isDone == false
    }
    func reset() {
        titleLabel.alpha = 1
        deleteButton.isHidden = true
        showStrikeThrough(false)

    }
    private func showStrikeThrough(_ show: Bool) {
        if show {
            strikeTroughWidth.constant = titleLabel.bounds.width
        } else {
            strikeTroughWidth.constant = 0
        }
    }
    
    @IBAction func checkDone(_ sender: Any) {
        stateButton.isSelected = !stateButton.isSelected
        let isDone = stateButton.isSelected
        showStrikeThrough(isDone)
        titleLabel.alpha = isDone ? 0.2 : 1
        doneButtonHandler?(isDone)
        deleteButton.isHidden = !isDone
        
        doneButtonHandler?(isDone)
    }
    @IBAction func deleteButton(_ sender: Any) {
        deleteButtonTapHandler?()
    }
    

}
