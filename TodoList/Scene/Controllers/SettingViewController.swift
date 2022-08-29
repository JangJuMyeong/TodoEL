//
//  SettingViewController.swift
//  TodoList
//
//  Created by 장주명 on 2021/03/17.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var settingCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Setting"
        settingCollectionView.delegate = self
        settingCollectionView.dataSource = self
        settingCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CollectionViewCell")
        NotificationCenter.default.addObserver(self,selector: #selector(didRecieveTestNotification(_:)), name: SettingHaedarView.complete,object: nil)
    }
    
    
    let todoListViewModel = TodoViewModel()
    
    @objc func didRecieveTestNotification(_ notification: Notification) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SettingViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SettingHaedarView", for: indexPath) as? SettingHaedarView else {
                return UICollectionReusableView()
                
            }
            
            guard let section = TodoViewModel.SettingSection(rawValue: indexPath.section) else {
                return UICollectionReusableView()
            }
            
            header.headerLabel.text = section.title
            
            if section.rawValue == 1 {
                header.dismissButtonState.isHidden = true
            }
            
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        cell.DoneState.isHidden = true
        cell.dateLabel.isHidden = true
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.layer.cornerRadius = 15
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                cell.titleLabel.text = "FSCalendar"
            } else {
                cell.titleLabel.text = "SwipeCellKit"
            }
        } else {
            cell.titleLabel.text = "Remove Data"
            
        }
        
        return cell
    }
    
    
    
}

extension SettingViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                let storyBoard = UIStoryboard(name: "SettingView", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "FSViewController") as! FSViewController
                self.present(vc, animated: true, completion: nil)
            } else {
                let storyBoard = UIStoryboard(name: "SettingView", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "SwipeViewController") as! SwipeViewController
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            for i in todoListViewModel.todos {
                todoListViewModel.deleteTodo(i)
            }
        }
    }
}

extension SettingViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let itemSpacing : CGFloat = 10 // 각 아이템끼리의 간격
        let width = (collectionView.bounds.width - itemSpacing * 2)
        
        return CGSize(width: width, height: 60)
    }
}

class SettingHaedarView : UICollectionReusableView {
    
    @IBOutlet weak var dismissButtonState: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func dismissButton(_ sender: Any) {
        NotificationCenter.default.post(name: SettingHaedarView.complete, object: nil)
    }
    static let complete = Notification.Name(rawValue: "complete")
}
