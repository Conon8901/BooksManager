//
//  NoteViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/08/23.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit

//本の詳細を見るVC
class NoteViewController: UIViewController, UITextViewDelegate {
    
    //MARK: - 宣言
    
    @IBOutlet var noteTV: UITextView!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var coverImageView: UIImageView!
    
    var saveData = UserDefaults.standard
    
    var currentBookIndex: Int?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "NOTE_VCTITLE".localized
        
        noteTV.font = .systemFont(ofSize: 17)
        
        noteTV.delegate = self
        
        doneButton.hide()
    }
    
    @objc func imageTapped() {
        let alert = UIAlertController(
            title: "NOTE_MAYNO".localized,
            message: "NOTE_MAYNO_MESSAGE".localized, //TODO: 翻訳が怪しい
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let title = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][0]
        let author = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][1]
        
        titleLabel.text = title
        
        authorLabel.text = author
        if authorLabel.text == "" {
            authorLabel.text = "NOTE_NONAME".localized
        }
        
        noteTV.text = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][2]
        
        let thumbnailStr = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!][3]
        if thumbnailStr == "" {
            coverImageView.image = UIImage(named: "noimage.png")
            
            coverImageView.isUserInteractionEnabled = true
            let imagetappedGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
            coverImageView.addGestureRecognizer(imagetappedGesture)
        } else {
            let thumbnailURL = URL(string: thumbnailStr)
            let imageData = try? Data(contentsOf: thumbnailURL!)
            coverImageView.image = UIImage(data: imageData!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let coverIVBottom = coverImageView.frame.origin.y + coverImageView.frame.size.height
        let authorLBottom = authorLabel.frame.origin.y + authorLabel.frame.size.height
        
        let constraintA = NSLayoutConstraint(item: self.noteTV, attribute: .top, relatedBy: .equal, toItem: self.authorLabel, attribute: .bottom, multiplier: 1, constant: 20)
        
        let constraintC = NSLayoutConstraint(item: self.noteTV, attribute: .top, relatedBy: .equal, toItem: self.coverImageView, attribute: .bottom, multiplier: 1, constant: 20)
        
        constraintA.isActive = authorLBottom > coverIVBottom
        constraintC.isActive = !constraintA.isActive
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
