//
//  CollectionViewCell.swift
//  TodoList
//
//  Created by 장주명 on 2021/03/05.
//

import UIKit
import SwipeCellKit

class CollectionViewCell: SwipeCollectionViewCell {
    
    @IBOutlet weak var DoneState: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        DoneState.isHidden = false

    }

}
