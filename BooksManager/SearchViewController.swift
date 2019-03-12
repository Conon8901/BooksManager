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
    
    var booksList = [[String]]()
    var imageList = [Int: UIImage]()
    
    var totalItems = 0
    var nThTime = 0
    
    var windowWidth: CGFloat = 0
    var space: CGFloat = 0
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        windowWidth = UIApplication.shared.keyWindow!.bounds.width
        space = round(windowWidth / 34)
        
        navigationItem.title = "SEARCH_VCTITLE".localized
        
        cancelButton.title = "CANCEL".localized
        
        searchText = Variables.shared.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        booksList = fetchNewList(nTh: nThTime)
        
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
        
        titleLabel.text = booksList[indexPath.row][0]
        authorLabel.text = booksList[indexPath.row][1]
        
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
                if let thumbnailURL = URL(string: self.booksList[indexPath.row][2]) {
                    let imageData = try? Data(contentsOf: thumbnailURL)
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
        //画面サイズに応じて
        let cellWidth = (windowWidth - (space * 3)) / 2
        let cellHeight = cellWidth * 1.3
        return CGSize(width: cellWidth, height: cellHeight)
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
    
//    func loadXML() {
//        let input = ""
//        
//        let urlStr = "http://iss.ndl.go.jp/api/opensearch?title=\(input)&idx=1&cnt=10&mediatype=1"
//        
//        let url = URL(string: urlStr)
//        
//        if let parser = XMLParser(contentsOf: url!) {
//            parser.delegate = self
//            parser.parse()
//        }
//    }
//    
//    var startTag = ""
//    
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        startTag = elementName
//        
//        if elementName == "item"{
//            
//        }
//    }
//    
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        switch startTag {
//        case "title":
//            <#code#>
//        case "author":
//            <#code#>
//        case "dc:publisher":
//            <#code#>
//        case "dcndl:price":
//            <#code#>
//        default:
//            <#code#>
//        }
//    }
//    
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        print("終了タグ:" + elementName)
//    }
    
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
                totalItems = number
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
