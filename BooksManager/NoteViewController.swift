//
//  NoteViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/08/23.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {
    
    //MARK: - 宣言
    
    @IBOutlet var noteTV: UITextView!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    var saveData = UserDefaults.standard
    
    var currentBookIndex: Int?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "NOTE_TITLE".localized
        
        noteTV.font = .systemFont(ofSize: 17)
        
        noteTV.delegate = self
        
        doneButton.hide()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][0]//速度的に？
        
        authorLabel.text = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][1]
        
        noteTV.text = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][2]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][2] = noteTV.text
        saveData.set(Variables.shared.booksData, forKey: Variables.shared.alKey)
    }
    
    //MARK: - Navi
    
    @IBAction func doneTapped() {
        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][2] = noteTV.text
        saveData.set(Variables.shared.booksData, forKey: Variables.shared.alKey)
        
        noteTV.resignFirstResponder()
    }
    
    //MARK: - TextView
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneButton.show()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        doneButton.hide()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
