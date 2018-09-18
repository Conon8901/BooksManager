//
//  TabViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/09/04.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

class CSViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var newLabel: UILabel!
    @IBOutlet var listLabel: UILabel!
    @IBOutlet var newTF: UITextField!
    @IBOutlet var categoryTable: UITableView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var viewOnScroll: UIView!
    
    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var viewHeight: NSLayoutConstraint!
    @IBOutlet var viewWidth: NSLayoutConstraint!
    
    var outsideTappedRecognizer = UITapGestureRecognizer()
    
    let cellHeight: CGFloat = 44
    
    let saveData = UserDefaults.standard
    
    @IBOutlet var addButton: UIButton! {
        didSet {
            addButton.setTitle("ADD".localized, for: .normal)
            addButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            addButton.layer.cornerRadius = 5.0
            addButton.layer.borderColor = variables.shared.themeColor.cgColor
            addButton.layer.borderWidth = 1.0
            addButton.backgroundColor = variables.shared.themeColor
            addButton.tintColor = .white
        }
    }
    
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
        viewOnScroll.addGestureRecognizer(outsideTappedRecognizer)
        
        viewWidth.constant = view.frame.size.width
        viewSet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(categoryTable.allowsSelectionDuringEditing)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        variables.shared.isFromCS = true
    }
    
    @IBAction func backTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.shared.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTable.dequeueReusableCell(withIdentifier: "CSCell")
        
        cell?.textLabel?.text = variables.shared.categories[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if variables.shared.categories.count == 1 {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let target = variables.shared.categories[sourceIndexPath.row]
        
        variables.shared.categories.remove(at: sourceIndexPath.row)
        variables.shared.categories.insert(target, at: destinationIndexPath.row)
        
        saveData.set(variables.shared.categories, forKey: variables.shared.categoryKey)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            variables.shared.booksData.removeValue(forKey: variables.shared.categories[indexPath.row])
            
            variables.shared.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            
            saveData.set(variables.shared.categories, forKey: variables.shared.categoryKey)
            saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
            
            DispatchQueue.main.async {
                self.viewSet()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select")
        let alert = UIAlertController(
            title: "CS_CHANGE".localized,
            message: nil,
            preferredStyle: .alert)
        
        let changeAction = UIAlertAction(title: "ALERT_BUTTON_ADD".localized, style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let newName = textField.text!
            
            if newName.characterExists() {
                if variables.shared.categories.index(of: newName) == nil {
                    let contents = variables.shared.booksData[variables.shared.categories[indexPath.row]]
                    
                    variables.shared.booksData[newName] = contents
                    
                    variables.shared.booksData.removeValue(forKey: variables.shared.categories[indexPath.row])
                    
                    variables.shared.categories[indexPath.row] = newName
                    
                    self.saveData.set(variables.shared.categories, forKey: variables.shared.categoryKey)
                    self.saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
                } else {
                    
                }
            } else {
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in }
        
        alert.addTextField { (textField: UITextField!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(changeAction)
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addTapped() {
        if newTF.text!.characterExists() {
            if variables.shared.categories.index(of: newTF.text!) == nil {
                variables.shared.categories.append(newTF.text!)
                variables.shared.booksData[newTF.text!] = []
                
                saveData.set(variables.shared.categories, forKey: variables.shared.categoryKey)

                saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
                
                categoryTable.reloadData()
                
                viewSet()
                
                newTF.text = ""
                
                newTF.resignFirstResponder()
                
                addButton.setTitle("ADDSUCCESSED".localized, for: .normal)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.addButton.setTitle("ADD".localized, for: .normal)
                }
            } else {
                let alert = UIAlertController(
                    title: "CS_ALREADY".localized,
                    message: nil,
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "CLOSE".localized, style: .default))
                
                self.present(alert, animated: true, completion: nil)
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
        tableHeight.constant = cellHeight * CGFloat(variables.shared.categories.count)
        
        let screenHeight = UIScreen.main.bounds.size.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        
        let wholeHeight = screenHeight - statusBarHeight - navBarHeight
        
        let height = categoryTable.frame.origin.y + tableHeight.constant + 15
        
        viewHeight.constant = height <= wholeHeight ? wholeHeight : height
    }
    
    @objc func closeKeyboard() {
        newTF.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newTF.resignFirstResponder()
        
        return true
    }
}
