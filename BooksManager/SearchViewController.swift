//
//  SearchViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/10/18.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//本の検索をするVC
class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - 宣言
    
    @IBOutlet var collection: UICollectionView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var searchText = ""
    
    var booksList = [[String]]()
    var imageList = [Int: UIImage]()
    
    var totalItems = 0
    var nThTime = 0
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        navigationItem.title = "SEARCH_VCTITLE".localized
        
        cancelButton.title = "CANCEL".localized
        
        //TODO: タイトルのAND検索
        //        let replaced = variables.shared.searchText.components(separatedBy: .whitespaces).joined(separator: "+")
        //        let replaced_encoded = replaced.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        //        searchText = replaced_encoded
        
        searchText = Variables.shared.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        booksList = fetchNewList(nTh: nThTime)
        
        collection.reloadData()
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return booksList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath)
        let titleLabel = cell.contentView.viewWithTag(1) as! UILabel
        let authorLabel = cell.contentView.viewWithTag(2) as! UILabel
        let coverimageView = cell.contentView.viewWithTag(3) as! UIImageView
        
        titleLabel.text = booksList[indexPath.row][0]
        authorLabel.text = booksList[indexPath.row][1]
        
        //非同期処理単一スレッド: 動作が重いが確実に表示される
//        let queue = DispatchQueue(label: "imagesDownload", qos: .utility, target: .main)
//        queue.async {
//            if let thumbnailURL = URL(string: self.booksList[indexPath.row][2]) {
//                let imageData = try? Data(contentsOf: thumbnailURL)
//                coverimageView.image = UIImage(data: imageData!)
//            } else {
//                coverimageView.image = UIImage(named: "noimage.png")
//            }
//        }
        
        //非同期処理複数スレッド: 動作は軽いが表示が入れ替わる
//        let dispatchGroup = DispatchGroup()
//        let dispatchQueue = DispatchQueue(label: "imagesDownload")
//
//        var image = UIImage(named: "NEEKZISTAS")
//        coverimageView.image = image
//
//        dispatchGroup.enter()
//        dispatchQueue.async(group: dispatchGroup) {
//            if let thumbnailURL = URL(string: self.booksList[indexPath.row][2]) {
//                let imageData = try? Data(contentsOf: thumbnailURL)
//                image = UIImage(data: imageData!)
//            } else {
//                image = UIImage(named: "noimage.png")
//            }
//        }
//        dispatchGroup.leave()
//
//        dispatchGroup.notify(queue: .main) {
//            coverimageView.image = image
//        }
        
        //非同期処理別スレッドで順にダウンロード //TODO: 通信が重いときの対応
        if let image = imageList[indexPath.row] {
            coverimageView.image = image
        } else {
            var image: UIImage!
            image = UIImage(named: "noimage.png")
            coverimageView.image = image
            
            DispatchQueue(label: "imagesDownload").async {
                if let thumbnailURL = URL(string: self.booksList[indexPath.row][2]) {
                    let imageData = try? Data(contentsOf: thumbnailURL)
                    image = UIImage(data: imageData!)
                } else {
                    image = UIImage(named: "noimage.png")
                }
                
                DispatchQueue.main.async {
                    self.imageList.updateValue(image, forKey: indexPath.row)
                    coverimageView.image = image//mainに戻って代入
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Variables.shared.gottenTitle = booksList[indexPath.row][0]
        Variables.shared.gottenAuthor = booksList[indexPath.row][1]
        Variables.shared.gottenThumbnailStr = booksList[indexPath.row][2]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //1000件で止める
        if nThTime < 24 {
            //下についたら
            let reachedBottom = collection.contentOffset.y >= collection.contentSize.height - collection.bounds.size.height
            
            //isDraggingは必要
            if reachedBottom && collection.isDragging {
                if booksList.count < totalItems {
                    let new = fetchNewList(nTh: nThTime)
                    
                    booksList = booksList + new
                    
                    collection.reloadData()
                }
            }
        }
    }
    
    //MARK: - Method
    
    func fetchNewList(nTh: Int) -> [[String]] {
        let URLString = "https://www.googleapis.com/books/v1/volumes?q=intitle:\(searchText)&startIndex=\(Variables.shared.resultsNumber*nTh)&maxResults=\(Variables.shared.resultsNumber)"
        
        let url = URL(string: URLString)!
        
        var booksArray = [[String]]()
        
        //情報の抽出
        do {
            //データ取得 //TODO: 通信が重いときの対応
            let jsonData = try Data(contentsOf: url)
            
            //JSONに変換
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: AnyObject]
            
            //該当件数取得
            if let number = json["totalItems"] as? Int {
                totalItems = number //TODO: 取得の時々で値が変わることへの対応（仕様？）
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
                            var thumbnailStr = imageLinks["thumbnail"]!
                            if let range = thumbnailStr.range(of: "&edge=curl") {
                                thumbnailStr.replaceSubrange(range, with: "")
                            }
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
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
