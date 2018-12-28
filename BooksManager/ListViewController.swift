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
    @IBOutlet var historyButton: UIBarButtonItem!
    @IBOutlet var tabs: UICollectionView!
    @IBOutlet var table: UITableView!
    @IBOutlet var booksEmptyView: UIView!
    @IBOutlet var nobooksLabel1: UILabel!
    @IBOutlet var nobooksLabel2: UILabel!
    @IBOutlet var tabsCover: UIView!
    
    let saveData = UserDefaults.standard
    
    var openCSVCRecognizer = UILongPressGestureRecognizer()
    
    var numberBeforeGoingToAddVC = 0
    var categoriesBeforeGoingToCSVC = [String]()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "LIST_VCTITLE".localized
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        editButtonItem.title = "EDIT".localized
        historyButton.title = "HISTORY".localized
        
        nobooksLabel1.text = "LIST_NOBOOKS1".localized
        nobooksLabel1.textColor = Variables.shared.empryLabelColor
        nobooksLabel2.text = "LIST_NOBOOKS2".localized
        nobooksLabel2.textColor = Variables.shared.empryLabelColor
        
        tabsCover.isHidden = true
        
        openCSVCRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.openCSVC))
        
        Variables.shared.currentCategory = 0
        
        let initialCategory = "LIST_NEW".localized
        
        if let dic = saveData.object(forKey: Variables.shared.alKey) as? [String: [[String]]] {
            Variables.shared.booksData = dic
        } else {
            Variables.shared.booksData[initialCategory] = []
        }
        
        if let arr = saveData.object(forKey: Variables.shared.categoryKey) as? [String] {
            Variables.shared.categories = arr
        } else {
            Variables.shared.categories.append(initialCategory)
        }
        
        if let arr = saveData.object(forKey: Variables.shared.deletedKey) as? [[String]] {
            Variables.shared.deletedBooks = arr
        }
        
        tabs.delegate = self
        tabs.dataSource = self
        tabs.showsHorizontalScrollIndicator = false
        
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.allowsSelection = true
        
        tabs.addGestureRecognizer(openCSVCRecognizer)
        
        let tabsBorder = UIView()
        let viewHeight = CGFloat(1)
        let viewY = UIApplication.shared.statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height + tabs.frame.size.height - viewHeight
        tabsBorder.frame = CGRect(x: 0, y: viewY, width: view.frame.size.width, height: viewHeight)
        tabsBorder.backgroundColor = UIColor(white: 200/255, alpha: 1)
        view.addSubview(tabsBorder)
        view.bringSubviewToFront(tabsBorder)
        
        tabs.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        
        checkTableState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /* TODO: 修正
         if fromCS {
             if !カテゴリ配列が飛ぶ前と同一 {
                 if 飛ぶ前にいたフォルダがある {
                    [CollectionView再読み込み]
                    [該当フォルダにスクロール]
                    [TableView再読み込み]
                 } else {
                    [CollectionView再読み込み]
                    [[0,0]にスクロール]
                    [TableView再読み込み]
                    [ボタン等調整]
                 }
             }
         } else {
             if fromADD {
                 if 項目数が0以上 {
                     [EmptyView非表示]
                     [編集ボタン使用可]
                     [TableView再読み込み]
                 }
             } else {
                 table.deselectRow (fromNOTE)
                 //現状fromHISTORYへの対応の必要なし
             }
         }
         */
        
        //NOTEから来た場合
        if let index = table.indexPathForSelectedRow {
            table.deselectRow(at: index, animated: true)
        }
        
        //ADDから来た場合
        if Variables.shared.isFromAddVC {
            Variables.shared.isFromAddVC = false
            
            let currentNumber = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.count
            if currentNumber > numberBeforeGoingToAddVC {
                booksEmptyView.isHidden = true
                editButtonItem.isEnabled = true
                
                table.reloadData()
            }
        }
        
        //カテゴリの追加編集削除並び替え
        if categoriesBeforeGoingToCSVC != Variables.shared.categories {
            tabs.scrollToItem(at: IndexPath(row: Variables.shared.currentCategory, section: 0), at: .centeredHorizontally, animated: false)
            
            tabs.reloadData()
        }
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Variables.shared.categories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = tabs.dequeueReusableCell(withReuseIdentifier: "LCategoryCell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        let selectingCellBottomBar = cell.contentView.viewWithTag(2)!
        
        selectingCellBottomBar.backgroundColor = Variables.shared.themeColor
        selectingCellBottomBar.alpha = 0
        
        if indexPath.row == Variables.shared.categories.count {
            label.text = "LIST_SETTING".localized
            label.textColor = .white
            label.numberOfLines = 2
            cell.backgroundColor = Variables.shared.themeColor.complementary
        } else {
            label.text = Variables.shared.categories[indexPath.row]
            label.textColor = .black
            cell.backgroundColor = .white
            
            if indexPath == IndexPath(row: Variables.shared.currentCategory, section: 0) {
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
        if indexPath.row == Variables.shared.categories.count {
            setNotEditing()
            
            categoriesBeforeGoingToCSVC = Variables.shared.categories
            
            let next = storyboard!.instantiateViewController(withIdentifier: "CSNavView")
            self.present(next, animated: true, completion: nil)
        } else {
            if indexPath.row != Variables.shared.currentCategory {
                Variables.shared.currentCategory = indexPath.row
                
                tabs.reloadData()
                
                checkTableState()
                
                table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                
                DispatchQueue.main.async {
                    self.tabs.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")!
        
        cell.textLabel?.text = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![indexPath.row][0]
        cell.detailTextLabel?.text = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![indexPath.row][1]
        
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //履歴に追加
        let book = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![indexPath.row]
        Variables.shared.deletedBooks.insert(book, at: 0)
        if Variables.shared.deletedBooks.count >= 100 {
            Variables.shared.deletedBooks.removeLast()
        }
        
        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
        
        saveData.set(Variables.shared.deletedBooks, forKey: Variables.shared.deletedKey)
        saveData.set(Variables.shared.booksData, forKey: Variables.shared.alKey)
        
        if Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.count == 0 {
            setNotEditing()
            
            for cell in tabs.visibleCells {
                cell.isUserInteractionEnabled = true
            }
            
            booksEmptyView.alpha = 0.0
            
            booksEmptyView.isHidden = false
            editButtonItem.isEnabled = false
            
            UIView.animate(withDuration: 1, animations: { () -> Void in
                self.booksEmptyView.alpha = 1.0
            })
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![sourceIndexPath.row]
        
        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.remove(at: sourceIndexPath.row)
        
        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.insert(movingItem, at: destinationIndexPath.row)
        
        saveData.set(Variables.shared.booksData, forKey: Variables.shared.alKey)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "NoteView") as! NoteViewController
        nextVC.currentBookIndex = indexPath.row
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        table.setEditing(editing, animated: true)
        
        composeButton.isEnabled = !editing
        historyButton.isEnabled = !editing
        
        tabs.isScrollEnabled = !editing
        for cell in tabs.visibleCells {
            cell.isUserInteractionEnabled = !editing
        }
        
        if editing {
            tabsCover.alpha = 0.0
            tabsCover.isHidden = false
            
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.tabsCover.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                self.tabsCover.alpha = 0.0
            }, completion: { finished in
                self.tabsCover.isHidden = finished
            })
        }
        
        tabs.reloadData()
    }
    
    func setNotEditing() {
        super.setEditing(false, animated: false)
        table.setEditing(false, animated: false)
        
        editButtonItem.title = "EDIT".localized
        editButtonItem.style = .plain
        
        composeButton.isEnabled = true
        historyButton.isEnabled = true
    }
    
    func checkTableState() {
        if Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.count == 0 {
            booksEmptyView.isHidden = false
            editButtonItem.isEnabled = false
        } else {
            booksEmptyView.isHidden = true
            editButtonItem.isEnabled = true
            
            table.reloadData()
        }
    }
    
    @objc func openCSVC(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            setNotEditing()
            
            categoriesBeforeGoingToCSVC = Variables.shared.categories
            
            let next = storyboard!.instantiateViewController(withIdentifier: "CSNavView")
            self.present(next, animated: true, completion: nil)
        }
    }
    
    @IBAction func composeTapped() {
        numberBeforeGoingToAddVC = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.count
        
        let next = storyboard!.instantiateViewController(withIdentifier: "AddNavView")
        self.present(next, animated: true, completion: nil)
    }
}
