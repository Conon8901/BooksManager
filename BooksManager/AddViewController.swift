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
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self, selector: #selector(self.checkIfEmpty), name: UITextField.textDidChangeNotification, object: nil)
        }
    }
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var authorTF: UITextField!
    @IBOutlet var noteLabel: UILabel!
    @IBOutlet var noteTV: UITextView!
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
    
    var titleByBarcode: String?
    var authorByBarcode: String?
    var thumbnailByBarcode: String?
    
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
        noteLabel.text = "ADD_NOTE".localized
        continuouslyLabel.text = "ADD_CONTINUE".localized
        searchButton.isEnabled = false
        searchButton.setImage(UIImage(named: "search.png"), for: .normal)
        
        titleTF.font = .systemFont(ofSize: 20)
        authorTF.font = .systemFont(ofSize: 20)
        noteTV.font = .systemFont(ofSize: 17)
        
        titleTF.delegate = self
        authorTF.delegate = self
        
        titleTF.becomeFirstResponder()
        
        clearButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let title = titleByBarcode {
            titleTF.text = title
            titleByBarcode = nil
            
            if let author = authorByBarcode {
                authorTF.text = author
                authorByBarcode = nil
            }
            
            titleTF.isEnabled = false
            authorTF.isEnabled = false
            addButton.isEnabled = true
            
            clearButton.isHidden = false
        }
        
        if let title = Variables.shared.gottenTitle {
            titleTF.text = title
            Variables.shared.gottenTitle = nil
            
            if let author = Variables.shared.gottenAuthor {
                authorTF.text = author
                Variables.shared.gottenAuthor = nil
            }
            
            titleTF.isEnabled = false
            authorTF.isEnabled = false
            
            clearButton.isHidden = false
        }
    }
    
    //MARK: - NavigationBar
    
    @IBAction func cancelTapped() {
        self.view.endEditing(true)
        
        Variables.shared.isFromAddVC = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - BookAddtion
    
    @IBAction func addTapped() {
        let title = titleTF.text!
        let author = authorTF.text!
        let note = noteTV.text!
        
        var exists = false
        for categoryName in Variables.shared.categories {
            for book in Variables.shared.booksData[categoryName]! {
                if (book.title, book.author) == (title, author) {
                    exists = true
                    break
                }
            }
        }
        
        if !exists {
            if author.characterExists() {
                var book = Book()
                book.title = title
                book.author = author
                book.note = note
                
                if let thumbnail = Variables.shared.gottenThumbnailStr {
                    book.image = thumbnail
                    
                    Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
                    
                    Variables.shared.gottenThumbnailStr = nil
                } else if let thumbnail = thumbnailByBarcode {
                    book.image = thumbnail
                    
                    Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
                    
                    thumbnailByBarcode = nil
                } else {
                    book.image = ""
                    
                    Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
                }
                
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
                    book.title = title
                    book.author = ""
                    book.note = note
                    
                    if let thumbnail = Variables.shared.gottenThumbnailStr {
                        book.image = thumbnail
                        
                        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
                        
                        Variables.shared.gottenThumbnailStr = nil
                    } else if let thumbnail = self.thumbnailByBarcode {
                        book.image = thumbnail
                        
                        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
                        
                        self.thumbnailByBarcode = nil
                    } else {
                        book.image = ""
                        
                        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]!.append(book)
                    }
                    
                    let encoded_all = try! JSONEncoder().encode(Variables.shared.booksData)
                    
                    self.saveData.set(encoded_all, forKey: Variables.shared.alKey)
                    
                    self.continuouslyCheck()
                }
                
                let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(
                title: String(format: "ADD_ALREADY".localized, titleTF.text!),
                message: nil,
                preferredStyle: .alert)
            
            let closeAction = UIAlertAction(title: "CLOSE".localized, style: .default) { (action: UIAlertAction!) -> Void in
                self.clearText()
            }
            
            alert.addAction(closeAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func continuouslyCheck() {
        addButton.setTitle("ADDSUCCESSED".localized, for: .normal)
        
        if continuouslySwitch.isOn {
            titleTF.text = ""
            authorTF.text = ""
            noteTV.text = ""
            
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let next = segue.destination
        if let BarcodeVC = next as? BarCodeViewController {
            BarcodeVC.addVC = self
        }
    }
    
    @IBAction func clearText() {
        titleTF.text = ""
        authorTF.text = ""
        
        clearButton.isHidden = true
        searchButton.isEnabled = false
        
        addButton.isEnabled = false
        
        titleTF.isEnabled = true
        authorTF.isEnabled = true
        
        titleTF.becomeFirstResponder()
        
        thumbnailByBarcode = nil
        Variables.shared.gottenThumbnailStr = nil
    }
    
    @IBAction func searchTapped() {
        Variables.shared.searchText = titleTF.text!
        
        let next = storyboard!.instantiateViewController(withIdentifier: "SearchNavView")
        self.present(next, animated: true, completion: nil)
    }
}
