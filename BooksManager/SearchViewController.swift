//
//  SearchViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/10/18.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//本の検索をするVC
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
        
        navigationItem.title = "SEARCH_VCTITLE".localized
        
        cancelButton.title = "CANCEL".localized
        
        //TODO: タイトルのAND検索
//        let replaced = variables.shared.searchText.components(separatedBy: .whitespaces).joined(separator: "+")
//        let replaced_encoded = replaced.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//        searchText = replaced_encoded
        
        searchText = Variables.shared.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        booksList = fetchNewList(nTh: nThTime)
        
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
        Variables.shared.gottenTitle = booksList[indexPath.row][0]
        Variables.shared.gottenAuthor = booksList[indexPath.row][1]
        Variables.shared.gottenThumbnailStr = booksList[indexPath.row][2]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if nThTime < 24 { //1000件で止める
            //下についたら
            let reachedBottom = table.contentOffset.y >= table.contentSize.height - table.bounds.size.height
            //TODO: 少し前に読み込むパターン
            //let thisqu = scrollView.contentSize.height - scrollView.frame.height - scrollView.contentOffset.y < 500 //下まで500
            
            //TODO: isDraggingは必要、滑らかにするために一部のみ更新できるとなお良し
            if reachedBottom && table.isDragging {
                if booksList.count < totalItems {
                    let new = fetchNewList(nTh: nThTime)
                    
                    booksList = booksList + new
                    
                    table.reloadData()
                }
            }
        }
    }
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchNewList(nTh: Int) -> [[String]] {
        let URLString = "https://www.googleapis.com/books/v1/volumes?q=intitle:\(searchText)&startIndex=\(Variables.shared.resultsNumber*nTh)&maxResults=\(Variables.shared.resultsNumber)"
        
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
                totalItems = number //FIXME: 取得の時々で値が変わる
            }
            
            //題名・著者の取得
            if let items = json["items"] as? [[String: AnyObject]] {
                for item in items {
                    if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                        var booktitle = ""
                        var author = ""
                        
                        if let titleString = volumeInfo["title"] as? String {
                            booktitle = titleString
                        } else {
                            booktitle = ""
                        }
                        
                        if let authorsArray = volumeInfo["authors"] as? [String] {
                            author = authorsArray.joined(separator: ", ")
                        } else {
                            author = ""
                        }
                        
                        if let imageLinks = volumeInfo["imageLinks"] as? [String: String] {
                            let thumbnailStr = imageLinks["thumbnail"]!
                            booksArray.append([booktitle, author, thumbnailStr])
                        } else {
                            booksArray.append([booktitle, author, ""])
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
