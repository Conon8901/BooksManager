//
//  Declarations.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/08/23.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func characterExists() -> Bool {
        return !self.components(separatedBy: .whitespaces).joined().isEmpty
    }
}

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
    
    func show() {
        self.isEnabled = true
        self.tintColor = nil //defaultの色で実行される
    }
}

func getBookSearchAPIAddress(nTh: Int) -> String {
    return "https://www.googleapis.com/books/v1/volumes?q=intitle:%@&startIndex=\(variables.shared.resultsNumber*nTh)&maxResults=\(variables.shared.resultsNumber)"
}

class variables {
    static let shared = variables()
    
    let themeColor = UIColor(red: 129/255, green: 153/255, blue: 88/255, alpha: 1)
    let complementaryColor = UIColor(red: 126/255, green: 102/255, blue: 167/255, alpha: 1)
    let empryLabelColor = UIColor(white: 67/255, alpha: 1)
    
    let alKey = "booksData"
    let saveKey = "savedBooksData"
    let categoryKey = "CategoryData"
    
    let resultsNumber = 40
    
    var booksData = [String: [[String]]]()
    
    var categories = [String]()
    
    var savedBooks = [[String]]()
    
    var isFromAddView = false
    var isFromCS = false
    
    var currentCategory = 0
    
    var currentBookIndex = 0
    
    var searchText = ""
    var gottenTitle: String?
    var gottenAuthor: String?
}
