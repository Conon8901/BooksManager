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

class variables {
    static let shared = variables()
    
    let themeColor = UIColor(red: 129/255, green: 153/255, blue: 88/255, alpha: 1)
    let complementaryColor = UIColor(red: 126/255, green: 102/255, blue: 167/255, alpha: 1)
    let empryLabelColor = UIColor(white: 67/255, alpha: 1)
    
    let alKey = "booksData"
    let saveKey = "savedBooksData"
    let categoryKey = "CategoryData"
    
    var booksData = [String: [[String]]]()
    
    var categories = [String]()
    
    var savedBooks = [[String]]()
    
    var isFromAddView = false
    var isFromCS = false
    
    var currentCategory = 0
    
    var currentBookIndex = 0
}
