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
    
    var isbnTenized: String {
        let picked = String(self[self.index(self.startIndex, offsetBy: 3)...self.index(self.startIndex, offsetBy: 11)])
        
        var sum = 0
        var index = 0
        var times = 10
        while index <= 8 {
            let i = String(picked[picked.index(picked.startIndex, offsetBy: index)])
            sum += Int(i)! * times
            
            index += 1
            times -= 1
        }
        
        let checkDigit = 11 - (sum % 11)
        let str = checkDigit == 10 ? "X" : String(checkDigit)
        return picked + str
    }
    
    var isbnThirteenized: String {
        var str = "978" + self
        
        str = String(str.prefix(str.count - 1))
        
        var sum = 0
        var index = 0
        var hoge = true
        
        while index <= 11 {
            let i = String(str[str.index(str.startIndex, offsetBy: index)])
            
            if hoge {
                sum += Int(i)! * 1
            } else {
                sum += Int(i)! * 3
            }
            
            hoge = !hoge
            index += 1
        }
        
        let checkDigit = (10 - (sum % 10)) % 10
        return str + String(checkDigit)
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

typealias Bookshelf = [String: [Book]]

class Variables {
    static let shared = Variables()
    
    let themeColor = UIColor(red: 129/255, green: 153/255, blue: 88/255, alpha: 1)
    let empryLabelColor = UIColor(white: 67/255, alpha: 1)
    
    let alKey = "booksData"
    let deletedKey = "deletedBooksData"
    let categoryKey = "categoryData"
    
    let resultsNumber = 40
    
    var booksData = Bookshelf()
    
    var categories = [String]()
    
    var deletedBooks = [Book]()
    
    var currentCategory = 0
    
    var searchText = "" //add -> search
    var gottenTitle: String? //search -> add
    var gottenAuthor: String? //search -> add
    var gottenThumbnailStr: String? //search -> add
    
    var isFromAddVC = false
}

struct Book: Codable {
    var title = ""
    var author = ""
    var isbn_10 = ""
    var isbn_13 = ""
    var publisher = ""
    var price = ""
    var image = ""
    var note = ""
}
