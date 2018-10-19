//
//  SavedViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/08/24.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

class SavedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - 宣言
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var table: UITableView!
    @IBOutlet var savedBooksEmptyView: UIView!
    @IBOutlet var noSavedBooksLabel1: UILabel!
    @IBOutlet var noSavedBooksLabel2: UILabel!
    
    let saveData = UserDefaults.standard
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "SAVED".localized
        
        cancelButton.title = "CANCEL".localized
        
        noSavedBooksLabel1.text = "SAVED_NOBOOKS1".localized
        noSavedBooksLabel2.text = "SAVED_NOBOOKS2".localized
        
        noSavedBooksLabel1.textColor = variables.shared.empryLabelColor
        noSavedBooksLabel2.textColor = variables.shared.empryLabelColor
        
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        
        if variables.shared.savedBooks.count != 0 {
            savedBooksEmptyView.isHidden = true
        } else {
            savedBooksEmptyView.isHidden = false
        }
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.shared.savedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedCell")
        
        cell?.textLabel?.text = variables.shared.savedBooks[indexPath.row][0]
        if variables.shared.savedBooks[indexPath.row][1] == "" {
            cell?.detailTextLabel?.text = " "
        } else {
            cell?.detailTextLabel?.text = variables.shared.savedBooks[indexPath.row][1]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            variables.shared.savedBooks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            
            saveData.set(variables.shared.savedBooks, forKey: variables.shared.saveKey)
            
            if variables.shared.savedBooks.count == 0 {
                savedBooksEmptyView.isHidden = false
                
                savedBooksEmptyView.alpha = 0.0
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    self.savedBooksEmptyView.alpha = 1.0
                })
            }
        }
    }
    
    //MARK: - Navi
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
