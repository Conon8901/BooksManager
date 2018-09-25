//
//  AddViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/09/09.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - 宣言
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleTF: UITextField!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var authorTF: UITextField!
    @IBOutlet var noteLabel: UILabel!
    @IBOutlet var noteTV: UITextView!
    @IBOutlet var continuouslyLabel: UILabel!
    @IBOutlet var continuouslySwitch: UISwitch!
    
    @IBOutlet var addButton: UIButton! {
        didSet {
            addButton.setTitle("ADD".localized, for: .normal)
            addButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
            addButton.layer.cornerRadius = 5.0
            addButton.layer.borderColor = variables.shared.themeColor.cgColor
            addButton.layer.borderWidth = 1.0
            addButton.backgroundColor = variables.shared.themeColor
            addButton.tintColor = .white
        }
    }
    
    let saveData = UserDefaults.standard
    
    var titleByBarcode: String?
    var authorByBarcode: String?
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ADD_VCTITLE".localized
        backButton.title = "BACK".localized
        titleLabel.text = "ADD_TITLE".localized
        authorLabel.text = "ADD_AUTHOR".localized
        noteLabel.text = "ADD_NOTE".localized
        continuouslyLabel.text = "ADD_CONTINUE".localized
        
        titleTF.font = .systemFont(ofSize: 20)
        authorTF.font = .systemFont(ofSize: 20)
        noteTV.font = .systemFont(ofSize: 17)
        
        titleTF.clearButtonMode = .whileEditing
        authorTF.clearButtonMode = .whileEditing
        
        titleTF.delegate = self
        authorTF.delegate = self
        
        titleTF.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let title = titleByBarcode {
            titleTF.text = title
            titleByBarcode = nil
            
            if let author = authorByBarcode {
                authorTF.text = author
                authorByBarcode = nil
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        variables.shared.isFromAddView = true
    }
    
    //MARK: - NavigationBar
    
    @IBAction func cancelTapped() {
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - BookAddtion
    
    @IBAction func addTapped() {
        let title = titleTF.text!
        let author = authorTF.text!
        let note = noteTV.text!
        
        if title.characterExists() {
            var exists = false
            for categoryName in variables.shared.categories {
                for book in variables.shared.booksData[categoryName]! {
                    if Array(book[0...1]) == [title, author] {
                        exists = true
                        break
                    }
                }
            }
            
            if !exists {
                if author.characterExists() {
                    variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.append([title, author, note])
                    
                    saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
                    
                    self.continuouslyCheck()
                } else {
                    let alert = UIAlertController(
                        title: "ADD_EMPTY".localized,
                        message: nil,
                        preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "ADD_OK".localized, style: .default) { (action: UIAlertAction!) -> Void in
                        
                        variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]!.append([title, "", note])
                        
                        self.saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
                        
                        self.continuouslyCheck()
                    }
                    
                    let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(
                    title: "ADD_ALREADY".localized,
                    message: nil,
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "CLOSE".localized, style: .default))
                
                self.present(alert, animated: true, completion: nil)
                
                titleTF.text = ""
                authorTF.text = ""
                
                titleTF.becomeFirstResponder()
            }
        } else {
            let alert = UIAlertController(
                title: "ADD_FILLIN".localized,
                message: nil,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "CLOSE".localized, style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func continuouslyCheck() {
        addButton.setTitle("ADDSUCCESSED".localized, for: .normal)
        
        if continuouslySwitch.isOn {
            titleTF.text = ""
            authorTF.text = ""
            noteTV.text = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.addButton.setTitle("ADD".localized, for: .normal)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.titleTF.becomeFirstResponder()
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {//応急
        let BarcodeVC = segue.destination as! BarCodeViewController
        BarcodeVC.addVC = self
    }
}
