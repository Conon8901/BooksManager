//
//  TabViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/09/04.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//カテゴリの追加編集をするVC
class CSViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - 宣言
    
    @IBOutlet var newLabel: UILabel!
    @IBOutlet var listLabel: UILabel!
    @IBOutlet var newTF: UITextField! {
        didSet {
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self, selector: #selector(self.checkIfEmpty), name: UITextField.textDidChangeNotification, object: nil)
        }
    }
    @IBOutlet var categoryTable: UITableView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var viewHeight: NSLayoutConstraint!
    @IBOutlet var viewWidth: NSLayoutConstraint!
    
    @objc func checkIfEmpty(sender: Notification) {
        let textField = sender.object as! UITextField
        let text = textField.text!
        
        addButton.isEnabled = text.characterExists()
    }
    
    var outsideTappedRecognizer = UITapGestureRecognizer()
    
    let cellHeight: CGFloat = 44
    
    let saveData = UserDefaults.standard
    
    var selectedIndex = 0
    
    @IBOutlet var addButton: UIButton! {
        didSet {
            addButton.setTitle("CS_ADD".localized, for: .normal)
            addButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            addButton.layer.cornerRadius = 5.0
            addButton.layer.borderColor = Variables.shared.themeColor.cgColor
            addButton.layer.borderWidth = 1.0
            addButton.backgroundColor = Variables.shared.themeColor
            addButton.tintColor = .white
            addButton.isEnabled = false
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "CS_VCTITLE".localized
        backButton.title = "BACK".localized
        
        newLabel.text = "CS_NEW".localized
        listLabel.text = "CS_LIST".localized
        
        newTF.delegate = self
        categoryTable.delegate = self
        
        newTF.font = .systemFont(ofSize: 20)
        
        categoryTable.delegate = self
        categoryTable.dataSource = self
        
        categoryTable.isScrollEnabled = false
        categoryTable.allowsSelectionDuringEditing = true
        categoryTable.allowsSelection = true
        
        super.setEditing(true, animated: false)
        categoryTable.setEditing(true, animated: false)
        
        outsideTappedRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeKeyboard))
        backgroundView.addGestureRecognizer(outsideTappedRecognizer)
        
        viewWidth.constant = view.frame.size.width
        viewSet()
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Variables.shared.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTable.dequeueReusableCell(withIdentifier: "CSCell")
        
        cell?.textLabel?.text = Variables.shared.categories[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Variables.shared.categories.count == 1 {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let target = Variables.shared.categories[sourceIndexPath.row]
        
        Variables.shared.categories.remove(at: sourceIndexPath.row)
        Variables.shared.categories.insert(target, at: destinationIndexPath.row)
        
        saveData.set(Variables.shared.categories, forKey: Variables.shared.categoryKey)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Variables.shared.booksData.removeValue(forKey: Variables.shared.categories[indexPath.row])
            
            Variables.shared.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            
            saveData.set(Variables.shared.categories, forKey: Variables.shared.categoryKey)
            saveData.set(Variables.shared.booksData, forKey: Variables.shared.alKey)
            
            DispatchQueue.main.async {
                self.viewSet()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "CS_CHANGE".localized,
            message: nil,
            preferredStyle: .alert)
        
        let changeAction = UIAlertAction(title: "CS_RENAME".localized, style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let newName = textField.text!
            
            if Variables.shared.categories.index(of: newName) == nil {
                let contents = Variables.shared.booksData[Variables.shared.categories[indexPath.row]]
                
                Variables.shared.booksData[newName] = contents
                
                Variables.shared.booksData.removeValue(forKey: Variables.shared.categories[indexPath.row])
                
                Variables.shared.categories[indexPath.row] = newName
                
                self.saveData.set(Variables.shared.categories, forKey: Variables.shared.categoryKey)
                self.saveData.set(Variables.shared.booksData, forKey: Variables.shared.alKey)
                
                self.categoryTable.reloadData()
            } else {
                let alert = UIAlertController(
                    title: "CS_ALREADY".localized,
                    message: nil,
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "CLOSE".localized, style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        changeAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
        
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.text = Variables.shared.categories[indexPath.row]
            
            self.selectedIndex = indexPath.row
            
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self, selector: #selector(self.checkIfTheSame), name: UITextField.textDidChangeNotification, object: nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(changeAction)
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func checkIfTheSame(sender: Notification) {
        let alert = presentedViewController as? UIAlertController
        let action = alert?.actions.last
        
        let textField = sender.object as! UITextField
        let text = textField.text!
        
        if text == Variables.shared.categories[selectedIndex] || !text.characterExists() {
            action?.isEnabled = false
        } else {
            action?.isEnabled = true
        }
    }
    
    //MARK: - Method
    
    @IBAction func backTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTapped() {
        if Variables.shared.categories.index(of: newTF.text!) == nil {
            Variables.shared.categories.append(newTF.text!)
            Variables.shared.booksData[newTF.text!] = []
            
            saveData.set(Variables.shared.categories, forKey: Variables.shared.categoryKey)
            
            saveData.set(Variables.shared.booksData, forKey: Variables.shared.alKey)
            
            categoryTable.reloadData()
            
            viewSet()
            
            newTF.text = ""
            
            newTF.resignFirstResponder()
            
            addButton.setTitle("ADDSUCCESSED".localized, for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.addButton.setTitle("CS_ADD".localized, for: .normal)
            }
        } else {
            let alert = UIAlertController(
                title: "CS_ALREADY".localized,
                message: nil,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "CLOSE".localized, style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func viewSet() {
        tableHeight.constant = cellHeight * CGFloat(Variables.shared.categories.count)
        
        let screenHeight = UIScreen.main.bounds.size.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        
        let wholeHeight = screenHeight - statusBarHeight - navBarHeight
        
        let height = categoryTable.frame.origin.y + tableHeight.constant + 15
        
        viewHeight.constant = height <= wholeHeight ? wholeHeight : height
    }
    
    @objc func closeKeyboard(sender: UITapGestureRecognizer) {
        if sender.state == .began {
            newTF.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newTF.resignFirstResponder()
        
        return true
    }
}
