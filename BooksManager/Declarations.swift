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

extension UIColor {
    var complementary: UIColor {
        let originRed = self.cgColor.components![0]
        let originGreen = self.cgColor.components![1]
        let originBlue = self.cgColor.components![2]
        
        let min_max_sum = [originRed, originGreen, originBlue].min()! + [originRed, originGreen, originBlue].max()!
        
        return UIColor(red: min_max_sum - originRed, green: min_max_sum - originGreen, blue: min_max_sum - originBlue, alpha: 1)
    }
}

//グローバル定数の書き方
//struct Constant {
//    static let theme = UIColor(red: 129/255, green: 153/255, blue: 88/255, alpha: 1)
//}
//public let theme = UIColor(red: 129/255, green: 153/255, blue: 88/255, alpha: 1)

class Variables {
    static let shared = Variables()
    
    let themeColor = UIColor(red: 129/255, green: 153/255, blue: 88/255, alpha: 1)
    let empryLabelColor = UIColor(white: 67/255, alpha: 1)
    
    let alKey = "booksData"
    let saveKey = "savedBooksData"
    let categoryKey = "CategoryData"
    
    let resultsNumber = 40
    
    var booksData = [String: [[String]]]()
    
    var categories = [String]()
    
    var savedBooks = [[String]]()
    
    var currentCategory = 0
    
    var searchText = "" //add -> search
    var gottenTitle: String? //search -> add
    var gottenAuthor: String? //search -> add
}
