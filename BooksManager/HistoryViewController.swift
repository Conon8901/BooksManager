//
//  SavedViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/08/24.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//削除した本の履歴を見るVC
class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - 宣言
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var table: UITableView!
    @IBOutlet var noHistoryView: UIView!
    @IBOutlet var noSavedBooksLabel: UILabel!
    
    let saveData = UserDefaults.standard
    
    var returnRecognizer = UILongPressGestureRecognizer()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "HISTORY".localized
        
        cancelButton.title = "CANCEL".localized
        
        noSavedBooksLabel.text = "HISTORY_NO".localized
        
        noSavedBooksLabel.textColor = Variables.shared.empryLabelColor
        
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        
        returnRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(returnTo))
        
        table.addGestureRecognizer(returnRecognizer)
        
        let isEmpty = Variables.shared.deletedBooks.count != 0
        noHistoryView.isHidden = isEmpty
    }
    
    @objc func returnTo(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("longpressed")
            //TODO: 削除時に元のカテゴリを保存するようにしてそれを読み込んで戻す
        }
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Variables.shared.deletedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeletedCell")
        
        cell?.textLabel?.text = Variables.shared.deletedBooks[indexPath.row][0]
        cell?.detailTextLabel?.text = Variables.shared.deletedBooks[indexPath.row][1]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Variables.shared.deletedBooks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            
            saveData.set(Variables.shared.deletedBooks, forKey: Variables.shared.deletedKey)
            
            if Variables.shared.deletedBooks.count == 0 {
                noHistoryView.isHidden = false
                
                noHistoryView.alpha = 0.0
                UIView.animate(withDuration: 0.75, animations: { () -> Void in
                    self.noHistoryView.alpha = 1.0
                })
            }
        }
    }
    
    //MARK: - Navi
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteTapped() {
        let alert = UIAlertController(title: "全削除", message: "履歴を全て削除します。", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "OK".localized, style: .default) { (action: UIAlertAction!) -> Void in
            Variables.shared.deletedBooks.removeAll()
            
            self.saveData.set(Variables.shared.deletedBooks, forKey: Variables.shared.deletedKey)
            
            self.table.reloadData()
            
            self.noHistoryView.isHidden = false
            
            self.noHistoryView.alpha = 0.0
            UIView.animate(withDuration: 0.75, animations: { () -> Void in
                self.noHistoryView.alpha = 1.0
            })
        }
        
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

