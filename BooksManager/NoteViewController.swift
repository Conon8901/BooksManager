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
    
    var saveData = UserDefaults.standard
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![variables.shared.currentBookIndex][0]
        
        noteTV.text = variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![variables.shared.currentBookIndex][2]
        noteTV.font = .systemFont(ofSize: 17)
        
        noteTV.delegate = self
        
        doneButton.hide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![variables.shared.currentBookIndex][2] = noteTV.text
        saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
    }
    
    //MARK: - Navi
    
    @IBAction func doneTapped() {
        variables.shared.booksData[variables.shared.categories[variables.shared.currentCategory]]![variables.shared.currentBookIndex][2] = noteTV.text
        saveData.set(variables.shared.booksData, forKey: variables.shared.alKey)
        
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
