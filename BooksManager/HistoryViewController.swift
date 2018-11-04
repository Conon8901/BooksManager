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
    @IBOutlet var table: UITableView!//TODO: 長押しで戻す？
    @IBOutlet var NoHistoryView: UIView!
    @IBOutlet var noSavedBooksLabel: UILabel!
    
    let saveData = UserDefaults.standard
    
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
        
        if Variables.shared.deletedBooks.count != 0 {
            NoHistoryView.isHidden = true
        } else {
            NoHistoryView.isHidden = false
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Variables.shared.deletedBooks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            
            saveData.set(Variables.shared.deletedBooks, forKey: Variables.shared.deletedKey)
            
            if Variables.shared.deletedBooks.count == 0 {
                NoHistoryView.isHidden = false
                
                NoHistoryView.alpha = 0.0
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    self.NoHistoryView.alpha = 1.0
                })
            }
        }
    }
    
    //MARK: - Navi
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

