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
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let alert = UIAlertController(
                title: "NOTE_NOIMAGE".localized,
                message: "NOTE_NOIMAGE_MESSAGE".localized,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let title = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!].title
        let author = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!].author
        
        titleLabel.text = title
        
        authorLabel.text = author
        if authorLabel.text == "" {
            authorLabel.text = "NOTE_NONAME".localized
        }
        
        noteTV.text = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!].note
        
        if coverImageView.image == nil {
            let thumbnailStr = Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!].cover
            
            let frame = coverImageView.frame
            let bgView = UIView(frame: frame)
            bgView.backgroundColor = .white
            self.view.addSubview(bgView)
            
            let indicator = UIActivityIndicatorView(style: .gray)
            let x = bgView.bounds.width / 2
            let y = bgView.bounds.height / 2
            indicator.center = CGPoint(x: x, y: y)
            bgView.addSubview(indicator)
            indicator.startAnimating()
            
            coverImageView.image = UIImage(named: "noimage.png")
            
            if thumbnailStr == "" {
                coverImageView.isUserInteractionEnabled = true
                let imagetappedGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
                coverImageView.addGestureRecognizer(imagetappedGesture)
                
                bgView.removeFromSuperview()
            } else {
                let thumbnailURL = URL(string: thumbnailStr)
                
                DispatchQueue(label: "Download").async {
                    let imageData = try? Data(contentsOf: thumbnailURL!)
                    DispatchQueue.main.sync {
                        if imageData != nil {
                            self.coverImageView.image = UIImage(data: imageData!)
                        }
                        
                        bgView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!].note = noteTV.text
        
        let encoded_all = try! JSONEncoder().encode(Variables.shared.booksData)
        
        saveData.set(encoded_all, forKey: Variables.shared.alKey)
    }
    
    //MARK: - Navi
    
    @IBAction func doneTapped() {
        Variables.shared.booksData[Variables.shared.categories[Variables.shared.currentCategory]]![currentBookIndex!].note = noteTV.text
        
        let encoded_all = try! JSONEncoder().encode(Variables.shared.booksData)
        
        saveData.set(encoded_all, forKey: Variables.shared.alKey)
        
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
