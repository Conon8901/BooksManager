//
//  AddViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/09/09.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//本の追加をするVC
class AddViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - 宣言
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleTF: UITextField! {
        didSet {
            titleTF.placeholder = "ADD_SEARCH".localized

            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self, selector: #selector(self.checkIfEmpty), name: UITextField.textDidChangeNotification, object: nil)
        }
    }
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var authorTF: UITextField!
    @IBOutlet var bookshopLabel: UILabel!
    @IBOutlet var bookshopTF: UITextField!
    @IBOutlet var continuouslyLabel: UILabel!
    @IBOutlet var continuouslySwitch: UISwitch!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    
    @IBOutlet var addButton: UIButton! {
        didSet {
            addButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
            addButton.titleLabel?.adjustsFontSizeToFitWidth = true
            addButton.titleLabel?.minimumScaleFactor = 0.75
            addButton.layer.cornerRadius = 5.0
            addButton.layer.borderColor = Variables.shared.themeColor.cgColor
            addButton.layer.borderWidth = 1.0
            addButton.backgroundColor = Variables.shared.themeColor
            addButton.tintColor = .white
            addButton.isEnabled = false
        }
    }
    
    let saveData = UserDefaults.standard
    
    var indicatorBGView = UIView()
    var indicatorForSearch = UIActivityIndicatorView()
    
    var searchText = ""
    
    @objc func checkIfEmpty(sender: Notification) {
        let textField = sender.object as! UITextField
        
        if textField === titleTF {
            let text = textField.text!
            
            addButton.isEnabled = text.characterExists()
            searchButton.isEnabled = text.characterExists()
            clearButton.isHidden = text.count == 0
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.setTitle(String(format: "ADD_ADD".localized, Variables.shared.categories[Variables.shared.currentCategory]), for: .normal)
        
        navigationItem.title = "ADD_VCTITLE".localized
        cancelButton.title = "CANCEL".localized
        titleLabel.text = "ADD_TITLE".localized
        authorLabel.text = "ADD_AUTHOR".localized
        bookshopLabel.text = "ADD_BOOKSHOP".localized
        continuouslyLabel.text = "ADD_CONTINUE".localized
        searchButton.isEnabled = false
        searchButton.setImage(UIImage(named: "search.png"), for: .normal)
        
        titleTF.font = .systemFont(ofSize: 20)
        authorTF.font = .systemFont(ofSize: 20)
        bookshopTF.font = .systemFont(ofSize: 20)
        
        titleTF.delegate = self
        authorTF.delegate = self
        bookshopTF.delegate = self
        
        titleTF.becomeFirstResponder()
        
        clearButton.isHidden = true
        
        indicatorBGView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        indicatorBGView.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        navigationController?.view.addSubview(indicatorBGView)
        
        indicatorBGView.isHidden = true
        
        indicatorForSearch.center = indicatorBGView.center
        indicatorForSearch.style = .whiteLarge
        indicatorForSearch.color = .black
        
        indicatorBGView.addSubview(indicatorForSearch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let title = Variables.shared.gottenTitle {
            titleTF.text = title
            
            titleTF.isEnabled = false
            
            if Variables.shared.gottenAuthor != nil {
                authorTF.isEnabled = false
            }
            
            bookshopTF.text = ""
            
            addButton.isEnabled = true
            
            clearButton.isHidden = false
        }
        
        if let author = Variables.shared.gottenAuthor {
            authorTF.text = author
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        indicatorForSearch.stopAnimating()
        
        indicatorBGView.isHidden = true
    }
    
    //MARK: - NavigationBar
    
    @IBAction func cancelTapped() {
        self.view.endEditing(true)
        
        Variables.shared.isFromAddVC = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - BookAddtion
    
    @IBAction func addTapped() {
        if authorTF.text!.characterExists() {
            var book = Book()
            book.title = titleTF.text!
            book.author = authorTF.text!
            book.bookshop = bookshopTF.text!
            
            if let publisher = Variables.shared.gottenPublisher { //TODO: 画面に表示するか？
                book.publisher = publisher
            }
            
            if let price = Variables.shared.gottenPrice {
                book.price = price
            }
            
            if let cover = Variables.shared.gottenCover {
                book.cover = cover
            }
            
            Variables.shared.gottenTitle = nil
            Variables.shared.gottenAuthor = nil
            Variables.shared.gottenPublisher = nil
            Variables.shared.gottenPrice = nil
            Variables.shared.gottenCover = nil
            
            Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
            
            let encoded_all = try! JSONEncoder().encode(Variables.shared.booksData)
            
            saveData.set(encoded_all, forKey: Variables.shared.alKey)
            
            self.continuouslyCheck()
        } else {
            let alert = UIAlertController(
                title: "ADD_AUTHOREMPTY".localized,
                message: nil,
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK".localized, style: .default) { (action: UIAlertAction!) -> Void in
                var book = Book()
                book.title = self.titleTF.text!
                book.author = self.authorTF.text!
                book.bookshop = self.bookshopTF.text!
                
                if let publisher = Variables.shared.gottenPublisher {
                    book.publisher = publisher
                }
                
                if let price = Variables.shared.gottenPrice {
                    book.price = price
                }
                
                if let cover = Variables.shared.gottenCover {
                    book.cover = cover
                }
                
                Variables.shared.gottenTitle = nil
                Variables.shared.gottenAuthor = nil
                Variables.shared.gottenPublisher = nil
                Variables.shared.gottenPrice = nil
                Variables.shared.gottenCover = nil
                
                Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
                
                let encoded_all = try! JSONEncoder().encode(Variables.shared.booksData)
                
                self.saveData.set(encoded_all, forKey: Variables.shared.alKey)
                
                self.continuouslyCheck()
            }
            
            let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func continuouslyCheck() {
        addButton.setTitle("ADDSUCCESSED".localized, for: .normal)
        
        if continuouslySwitch.isOn {
            titleTF.text = ""
            authorTF.text = ""
            bookshopTF.text = ""
            
            titleTF.isEnabled = true
            authorTF.isEnabled = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.addButton.setTitle(String(format: "ADD_ADD".localized, Variables.shared.categories[Variables.shared.currentCategory]), for: .normal)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.titleTF.becomeFirstResponder()
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                Variables.shared.isFromAddVC = true
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField === titleTF {
            authorTF.becomeFirstResponder()
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func clearText() {
        titleTF.text = ""
        authorTF.text = ""
        
        clearButton.isHidden = true
        searchButton.isEnabled = false
        
        addButton.isEnabled = false
        
        titleTF.isEnabled = true
        authorTF.isEnabled = true
        
        Variables.shared.gottenTitle = nil
        Variables.shared.gottenAuthor = nil
        Variables.shared.gottenPublisher = nil
        Variables.shared.gottenPrice = nil
        Variables.shared.gottenCover = nil
        
        titleTF.becomeFirstResponder()
    }
    
    @IBAction func searchTapped() {
        Variables.shared.searchText = titleTF.text!
        
        indicatorBGView.isHidden = false
        indicatorForSearch.startAnimating()
        
        let next = storyboard!.instantiateViewController(withIdentifier: "SearchNavView")
        self.present(next, animated: true, completion: nil)
    }
}
