//
//  SearchViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/10/18.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//本の検索をするVC
class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, XMLParserDelegate {
    
    //MARK: - 宣言
    
    @IBOutlet var collection: UICollectionView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var attentionLabel1: UILabel!
    @IBOutlet var attentionLabel2: UILabel!
    
    var searchText = ""
    
    var booksList = [[String: String]]()
    var imageList = [Int: UIImage]()
    
    var totalItems = 0
    var nThTime = 0
    
    var windowWidth: CGFloat = 0
    var space: CGFloat = 0
    var cellSize: CGSize = CGSize(width: 0, height: 0)
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        collection.decelerationRate = .init(rawValue: 0.2)
        
        windowWidth = UIApplication.shared.keyWindow!.bounds.width
        space = round(windowWidth / 34)
        
        navigationItem.title = "SEARCH_VCTITLE".localized
        cancelButton.title = "CANCEL".localized
        
        attentionLabel1.isHidden = true
        attentionLabel2.isHidden = true
        
        searchText = Variables.shared.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //画面サイズに応じて
        let cellWidth = (windowWidth - (space * 3)) / 2
        let cellHeight = cellWidth * 1.3
        cellSize = CGSize(width: cellWidth, height: cellHeight)
        
        fetchNewList(nTh: nThTime)
        
        if booksList.count != 0 {
            attentionLabel1.isHidden = true
            attentionLabel2.isHidden = true
            
            collection.reloadData()
        } else {
            attentionLabel1.text = "SEARCH_ATTENTION1".localized
            attentionLabel2.text = "SEARCH_ATTENTION2".localized
        }
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
        
        titleLabel.text = booksList[indexPath.row]["title"]
        authorLabel.text = booksList[indexPath.row]["author"]
        
        coverimageView.image = UIImage(named: "noimage.png")
        //非同期処理別スレッドで順にダウンロード
        if let image = imageList[indexPath.row] {
            coverimageView.image = image
        } else {
            var image: UIImage!
            image = UIImage(named: "indicatorBG.png")
            coverimageView.image = image

            let indicator = UIActivityIndicatorView(style: .gray)
            let imageViewCenterX = coverimageView.bounds.width / 2
            let imageViewCenterY = coverimageView.bounds.height / 2
            indicator.center = CGPoint(x: imageViewCenterX, y: imageViewCenterY)
            coverimageView.addSubview(indicator)
            indicator.startAnimating()

            DispatchQueue(label: "imagesDownload").async {
                if let coverURL = URL(string: self.booksList[indexPath.row]["cover"]!) {
                    let imageData = try? Data(contentsOf: coverURL)
                    image = UIImage(data: imageData!)
                } else {
                    image = UIImage(named: "noimage.png")
                }

                DispatchQueue.main.async {
                    self.imageList.updateValue(image, forKey: indexPath.row)

                    indicator.stopAnimating()

                    coverimageView.image = image//mainに戻って代入
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Variables.shared.gottenTitle = booksList[indexPath.row]["title"]
        Variables.shared.gottenAuthor = booksList[indexPath.row]["author"]
        Variables.shared.gottenPublisher = booksList[indexPath.row]["publisher"]
        Variables.shared.gottenPrice = booksList[indexPath.row]["price"]
        Variables.shared.gottenCover = booksList[indexPath.row]["cover"]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var didLoad = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //400件で止める
        if Variables.shared.resultsNumberPerLoading * nThTime < Variables.shared.maxResultsNumber {
            //下についたら
            let currentOffsetY = collection.contentOffset.y
            let allViewHeight = collection.contentSize.height
            let visibleHeight = collection.frame.height
            let maxHeight = allViewHeight - visibleHeight
            let distance = maxHeight - currentOffsetY
            
            //isDraggingは必要
            if distance < 1500 && collection.isDragging && !didLoad {
                
                didLoad = true
                
                if booksList.count < totalItems {
                    fetchNewList(nTh: nThTime)
                }
            }
        }
    }
    
    //MARK: - Method
    
    func fetchNewList(nTh: Int) {
        let googleURLString = "https://www.googleapis.com/books/v1/volumes?q=intitle:\(searchText)&startIndex=\(Variables.shared.resultsNumberPerLoading*nTh)&maxResults=\(Variables.shared.resultsNumberPerLoading)"
        
        let googleUrl = URL(string: googleURLString)!
        
        var booksArray_NOVA = [[String: String]]()
        
        DispatchQueue(label: "fetchData").async {
            //情報の抽出
            do {
                //データ取得
                let jsonData = try Data(contentsOf: googleUrl)
                
                //JSONに変換
                let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: AnyObject]
                
                //該当件数取得
                if let number = json["totalItems"] as? Int {
                    self.totalItems = number
                }
                
                //題名・著者の取得
                if let items = json["items"] as? [[String: AnyObject]] {
                    for item in items {
                        var tempArray = ["title": "", "author": "", "publisher": "", "price": "", "cover": ""]
                        
                        if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                            
                            if let titleString = volumeInfo["title"] as? String {
                                tempArray["title"] = titleString
                            }
                            
                            if let authorsArray = volumeInfo["authors"] as? [String] {
                                tempArray["author"] = authorsArray.joined(separator: ", ")
                            }
                            
                            if let imageLinks = volumeInfo["imageLinks"] as? [String: String] {
                                var thumbnailStr = imageLinks["thumbnail"]!
                                if let range = thumbnailStr.range(of: "&edge=curl") {
                                    thumbnailStr.replaceSubrange(range, with: "")
                                }
                                tempArray["cover"] = thumbnailStr
                            }
                            
                            if let saleInfo = item["saleInfo"] as? [String: AnyObject] {
                                if let priceDic = saleInfo["listPrice"] as? [String: AnyObject] {
                                    let amount = priceDic["amount"] as! Double
                                    let currency = priceDic["currencyCode"] as! String
                                    var price = ""
                                    if currency == "JPY" {
                                        price = String(Int(amount)) + "円"
                                    } else {
                                        price = String(amount) + currency
                                    }
                                    tempArray["price"] = price
                                }
                            }
                            
                            if let isbns = volumeInfo["industryIdentifiers"] as? [[String: String]] {//ISBNは削除
                                for one in isbns {
//                                    if one["type"] == "ISBN_10" {
//                                        tempArray["isbn_10"] = one["identifier"]!
//                                    }
                                    
                                    if one["type"] == "ISBN_13" {
//                                        let isbn13 = one["identifier"]!
                                        
//                                        tempArray["isbn_13"] = isbn13
                                        
                                        let openBDURLString = "https://api.openbd.jp/v1/get?isbn=\(one["identifier"]!)"
                                        let openBDUrl = URL(string: openBDURLString)!
                                        
                                        //情報の抽出
                                        do {
                                            //データ取得
                                            let jsonData = try Data(contentsOf: openBDUrl)
                                            
                                            //JSONに変換
                                            if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [[String: AnyObject]] {
                                                //情報取得
                                                if let items = json[0]["summary"] as? [String: String] {
                                                    tempArray["title"] = items["title"]!
                                                    tempArray["publisher"] = items["publisher"]!
                                                    
                                                    if items["cover"]! != "" {
                                                        tempArray["cover"] = items["cover"]!
                                                    }
                                                }
                                            }
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        }
                        
                        booksArray_NOVA.append(tempArray)
                    }
                }
            } catch {
                print(error)
            }
            
            self.nThTime += 1
            
            self.booksList = self.booksList + booksArray_NOVA
            
            DispatchQueue.main.async {
                self.collection.reloadData()
                self.didLoad = false
                
                if self.booksList.isEmpty {
                    self.attentionLabel1.isHidden = false
                    self.attentionLabel2.isHidden = false
                }
            }
        }
    }
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
