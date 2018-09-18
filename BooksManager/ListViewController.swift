//
//  ListoViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/09/08.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//本の一覧を見るVC
class ListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - 宣言
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBOutlet var savedBooksButton: UIBarButtonItem!
    @IBOutlet var tabs: UICollectionView!
    @IBOutlet var table: UITableView!
    @IBOutlet var booksEmptyView: UIView!
    @IBOutlet var nobooksLabel1: UILabel!
    @IBOutlet var nobooksLabel2: UILabel!
    
    let saveData = UserDefaults.standard
    
    var saveRecognizer = UILongPressGestureRecognizer()
    var openCSRecognizer = UILongPressGestureRecognizer()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "LIST_VCTITLE".localized
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        editButtonItem.title = "EDIT".localized
        savedBooksButton.title = "SAVED".localized
        
        nobooksLabel1.text = "LIST_NOBOOKS1".localized
        nobooksLabel1.textColor = variables.shared.empryLabelColor
        nobooksLabel2.text = "LIST_NOBOOKS2".localized
        nobooksLabel2.textColor = variables.shared.empryLabelColor
        
        saveRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.saveBook))
        openCSRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.openCS))
        
        //開いているカテゴリ
        variables.shared.currentCategory = 0
        
//        saveData.register(defaults: [variables.shared.alKey: ["NEW": []], variables.shared.categoryKey: "NEW", variables.shared.saveKey: []])
        
        if let dic = saveData.object(forKey: variables.shared.alKey) as? [String: [[String]]] {
            variables.shared.booksData = dic
        } else {
            variables.shared.booksData["NEW"] = []
        }
        
        if let arr = saveData.object(forKey: variables.shared.categoryKey) as? [String] {
            variables.shared.categories = arr
        } else {
            variables.shared.categories.append("NEW")
        }
        
        if let arr = saveData.object(forKey: variables.shared.saveKey) as? [[String]] {
            variables.shared.savedBooks = arr
        }
        
        tabs.delegate = self
        tabs.dataSource = self
        tabs.showsHorizontalScrollIndicator = false
        
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.allowsSelection = true
        
        table.addGestureRecognizer(saveRecognizer)
        tabs.addGestureRecognizer(openCSRecognizer)
        
        tabs.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        
        checkTableState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = table.indexPathForSelectedRow {
            table.deselectRow(at: index, animated: true)
        }
        
        if variables.shared.isFromAddView {
            variables.shared.isFromAddView = false
            
            checkTableState()
        }
        
        if variables.shared.isFromCS {
            variables.shared.isFromCS = false
            
            tabs.scrollToItem(at: IndexPath(row: variables.shared.categories.count, section: 0), at: .right, animated: false)
            
            tabs.reloadData()
        }
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return variables.shared.categories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = tabs.dequeueReusableCell(withReuseIdentifier: "LCategoryCell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        let selectingCellBottomBar = cell.contentView.viewWithTag(2)!
        let tabsBottomBar = cell.contentView.viewWithTag(3)!
        
        tabsBottomBar.backgroundColor = UIColor(white: 200/255, alpha: 1)
        tabsBottomBar.isUserInteractionEnabled = false
        
        cell.isUserInteractionEnabled = !table.isEditing
        
        selectingCellBottomBar.backgroundColor = variables.shared.themeColor
        selectingCellBottomBar.alpha = 0
        
        if indexPath.row == variables.shared.categories.count {
            label.text = "LIST_SETTING".localized
            label.textColor = .white
            cell.backgroundColor = variables.shared.complementaryColor
        } else {
            label.text = variables.shared.categories[indexPath.row]
            label.textColor = .black
            cell.backgroundColor = .white
            
            if indexPath == IndexPath(row: variables.shared.currentCategory, section: 0) {
                selectingCellBottomBar.alpha = 1
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.size.width / 3
        let height: CGFloat = navigationController!.navigationBar.frame.size.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == variables.shared.categories.count {
            setNotEditing()
            
            let next = storyboard!.instantiateViewController(withIdentifier: "CSNavView")
            self.present(next, animated: true, completion: nil)
        } else {
            variables.shared.currentCategory = indexPath.row
            
            tabs.reloadData()
            
            checkTableState()
            
            DispatchQueue.main.async {
                self.tabs.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            }
        }
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")!
        
        cell.textLabel?.text = variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![indexPath.row][0]
        
        if variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![indexPath.row][1] == "" {
            cell.detailTextLabel?.text = " "
        } else {
            cell.detailTextLabel?.text = variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![indexPath.row][1]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEditing {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
        
        saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
        
        if variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.count == 0 {
            setNotEditing()
            
            booksEmptyView.alpha = 0.0
            
            setParts(isTableEmpty: false)
            
            UIView.animate(withDuration: 1, animations: { () -> Void in
                self.booksEmptyView.alpha = 1.0
            })
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![sourceIndexPath.row]
        
        variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.remove(at: sourceIndexPath.row)
        
        variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.insert(movingItem, at: destinationIndexPath.row)
        
        saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        variables.shared.currentBookIndex = indexPath.row
        
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "NoteView") as! NoteViewController
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        table.setEditing(editing, animated: true)
        
        composeButton.isEnabled = !editing
        savedBooksButton.isEnabled = !editing
        
        tabs.reloadData()
    }
    
    @objc func saveBook(recognizer: UILongPressGestureRecognizer) {
        if let indexPath = table.indexPathForRow(at: recognizer.location(in: table)) {
            if recognizer.state == .began  {
                let savotaBook = Array(variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![indexPath.row][0...1])
                
                var isSameBookExists = false
                for book in variables.shared.savedBooks {
                    if Array(book[0...1]) == savotaBook {
                        isSameBookExists = true
                        break
                    }
                }
                
                if isSameBookExists {
                    let alert = UIAlertController(
                        title: String(format: "LIST_ALREADY".localized, variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![indexPath.row][0]),
                        message: nil,
                        preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "CLOSE".localized, style: .default))
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(
                        title: String(format: "LIST_SAVECHECK".localized, variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![indexPath.row][0]),
                        message: nil,
                        preferredStyle: .alert)
                    
                    let saveAction = UIAlertAction(title: "LIST_SAVE".localized, style: .default) { (action: UIAlertAction!) -> Void in
                        
                        variables.shared.savedBooks.append(savotaBook)
                        
                        self.saveData.set(variables.shared.savedBooks, forKey: variables.shared.saveKey)
                    }
                    
                    let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(saveAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setNotEditing() {
        super.setEditing(false, animated: false)
        table.setEditing(false, animated: false)
        
        editButtonItem.title = "EDIT".localized
        editButtonItem.style = .plain
        
        composeButton.isEnabled = true
        savedBooksButton.isEnabled = true
    }
    
    func setParts(isTableEmpty: Bool) {
        if isTableEmpty {
            booksEmptyView.isHidden = false
            editButtonItem.isEnabled = false
        } else {
            booksEmptyView.isHidden = true
            editButtonItem.isEnabled = true
        }
    }
    
    func checkTableState() {
        if variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.count == 0 {
            setParts(isTableEmpty: true)
        } else {
            setParts(isTableEmpty: false)
            
            table.reloadData()
        }
    }
    
    @objc func openCS() {
        setNotEditing()
        
        let next = storyboard!.instantiateViewController(withIdentifier: "CSNavView")
        self.present(next, animated: true, completion: nil)
    }
}
