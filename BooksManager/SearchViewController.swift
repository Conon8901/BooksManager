//
//  SearchViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/10/18.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var searchText = ""
    
    var booksList = [[String]]()
    
    var totalItems = 0
    var nThTime = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        
        cancelButton.title = "CANCEL".localized
        
        searchText = variables.shared.searchText
        
        booksList = getNewList(nTh: nThTime)
        
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")!
        
        cell.textLabel?.text = booksList[indexPath.row][0]
        cell.detailTextLabel?.text = booksList[indexPath.row][1]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        variables.shared.gottenTitle = booksList[indexPath.row][0]
        variables.shared.gottenAuthor = booksList[indexPath.row][1]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //下についたら
        let reachedBottom = table.contentOffset.y >= table.contentSize.height - table.bounds.size.height
        //let thisqu = scrollView.contentSize.height - scrollView.frame.height - scrollView.contentOffset.y < 500 //下まで500
        
        if reachedBottom && table.isDragging { //isDraggingは必要(らしい) //一部のみ更新したい //滑らかに
            if booksList.count < totalItems {
                let new = getNewList(nTh: nThTime)
                
                booksList = booksList + new
                
                table.reloadData()
            }
        }
    }
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getNewList(nTh: Int) -> [[String]] {//限る千件
        let URLString = "https://www.googleapis.com/books/v1/volumes?q=intitle:\(searchText)&startIndex=\(variables.shared.resultsNumber*nTh)&maxResults=\(variables.shared.resultsNumber)"
        
        let url = URL(string: URLString)!
        
        var booksArray = [[String]]()
        
        //情報の抽出
        do {
            //データ取得
            let jsonData = try Data(contentsOf: url)
            
            //JSONに変換
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: AnyObject]
            
            //該当件数取得
            if let number = json["totalItems"] as? Int {
                totalItems = number
            }
            
            //題名・著者の取得
            if let items = json["items"] as? [[String: AnyObject]] {
                for item in items {
                    if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                        var booktitle = ""
                        
                        if let titleString = volumeInfo["title"] as? String {
                            booktitle = titleString
                        } else {
                            booktitle = ""
                        }
                        
                        if let authorsArray = volumeInfo["authors"] as? [String] {
                            let author = authorsArray.joined(separator: ", ")
                            booksArray.append([booktitle, author])
                        } else {
                            booksArray.append([booktitle, ""])
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        
        nThTime += 1
        
        return booksArray
    }
}
