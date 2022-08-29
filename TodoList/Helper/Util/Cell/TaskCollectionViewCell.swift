//
//  TaskTableViewCell.swift
//  TodoList
//
//  Created by Gilwan Ryu on 2020/11/18.
//

import UIKit
import SwipeCellKit

class TaskCollectionViewCell: SwipeCollectionViewCell {

    @IBOutlet weak var DoneState: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
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
        DoneState.isHidden = !todo.isDone
        titleLabel.text = todo.detail
        titleLabel.alpha = todo.isDone ? 0.2 : 1
    }
    func reset() {
        titleLabel.alpha = 1
        DoneState.isHidden = true
        

    }
    

}
