//
//  BarCodeViewController.swift
//  BooksManager
//
//  Created by 黒岩修 on H30/08/25.
//  Copyright © 平成30年 黒岩修. All rights reserved.
//

import UIKit
import AVFoundation

//バーコードを読み取るVC
class BarCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - 宣言
    
    @IBOutlet var previewView: UIView!
    @IBOutlet var cancelButton: UIButton!
    
    let instructLabel = UILabel()
    let detectionArea = UIView()
    var isDetected = false
    
    //MARK: - CameraProcessing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //インスタンス生成
        let captureSession = AVCaptureSession()
        
        //入力準備
        let videoDevice = AVCaptureDevice.default(for: .video)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        //出力準備
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        //デリゲート設定
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        
        //対象にEANコードを指定
        metadataOutput.metadataObjectTypes = [.ean13, .ean8]
        
        //検出エリア枠の表示
        let viewHeight = view.frame.size.height
        let viewWidth = view.frame.size.width
        let areaXRatio: CGFloat = 0.05
        let areaYRatio: CGFloat = 0.3
        let areaWidthRatio: CGFloat = 1 - (areaXRatio * 2)
        let areaHeightRatio: CGFloat = 0.5 - areaYRatio
        let labelHeight: CGFloat = 21
        
        detectionArea.frame = CGRect(x: viewWidth*areaXRatio, y: viewHeight*areaYRatio, width: viewWidth*areaWidthRatio, height: viewHeight*areaHeightRatio)
        detectionArea.layer.borderColor = UIColor.red.cgColor
        detectionArea.layer.borderWidth = 3
        view.addSubview(detectionArea)
        
        //検出エリアの設定
        metadataOutput.rectOfInterest = CGRect(x: areaYRatio, y: areaXRatio, width: areaHeightRatio, height: areaWidthRatio)
        
        //撮影準備
        let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer.frame = previewView.bounds
        videoLayer.videoGravity = .resizeAspectFill
        previewView.layer.addSublayer(videoLayer)
        
        //撮影開始
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        //説明ラベルの生成
        instructLabel.frame = CGRect(x: viewWidth*areaXRatio, y: detectionArea.frame.origin.y-(labelHeight*1.5), width: viewWidth*(1-(areaXRatio*2)), height: labelHeight)
        instructLabel.text = "BARCODE_FRAME".localized
        instructLabel.font = .boldSystemFont(ofSize: 17)
        instructLabel.textAlignment = .center
        instructLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(instructLabel)
        previewView.bringSubviewToFront(instructLabel)
        
        //キャンセルボタンの生成
        cancelButton.setTitle("CANCEL".localized, for: .normal)
        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        previewView.bringSubviewToFront(cancelButton)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //一つずつ判定
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            //文字列があるかどうか
            if let readed = metadata.stringValue {
                //ISBNかどうか
                if readed.hasPrefix("978") || readed.hasPrefix("979") {
                    //判定済みかどうか
                    if !isDetected {
                        isDetected = true
                        
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        
                        let googleURLString = String(format: "https://www.googleapis.com/books/v1/volumes?q=isbn:%@", readed)

                        let googleUrl = URL(string: googleURLString)!
                        
                        var canReflect = true

                        DispatchQueue(label: "fetch").async {
                            //情報の抽出
                            do {
                                //データ取得
                                let jsonData = try Data(contentsOf: googleUrl)

                                //JSONに変換
                                let googleJson = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: AnyObject]
                                
                                if googleJson["totalItems"] as? Int == 1 {
                                    //題名・著者の取得
                                    if let items = googleJson["items"] as? [[String: AnyObject]] {
                                        for item in items {
                                            
                                            if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                                                if let title = volumeInfo["title"] as? String {
                                                    Variables.shared.gottenTitle = title
                                                }
                                                
                                                if let authorsArray = volumeInfo["authors"] as? [String] {
                                                    Variables.shared.gottenAuthor = authorsArray.joined(separator: ", ")
                                                }
                                                
                                                if let imageLinks = volumeInfo["imageLinks"] as? [String: String] {
                                                    var thumbnailStr = imageLinks["thumbnail"]!
                                                    if let range = thumbnailStr.range(of: "&edge=curl") {
                                                        thumbnailStr.replaceSubrange(range, with: "")
                                                    }
                                                    Variables.shared.gottenCover = thumbnailStr
                                                }
                                                
                                                if let saleInfo = item["saleInfo"] as? [String: AnyObject] {
                                                    if let priceDic = saleInfo["listPrice"] as? [String: AnyObject] {
                                                        let amount = priceDic["amount"] as! Double
                                                        let currency = priceDic["currencyCode"] as! String
                                                        var price = String(amount) + currency
                                                        if currency == "JPY" {
                                                            price = String(round(amount)) + "円"
                                                        }
                                                        Variables.shared.gottenTitle = price
                                                    }
                                                }
                                                
                                                if let isbns = volumeInfo["industryIdentifiers"] as? [[String: String]] {//ISBNは削除
                                                    for one in isbns {
//                                                        if one["type"] == "ISBN_10" {
//                                                            tempArray["isbn_10"] = one["identifier"]!
//                                                        }
                                                        
                                                        if one["type"] == "ISBN_13" {
//                                                            tempArray["isbn_13"] = one["identifier"]!
                                                            
                                                            let openBDURLString = "https://api.openbd.jp/v1/get?isbn=\(one["identifier"]!)"
                                                            let openBDUrl = URL(string: openBDURLString)!
                                                            
                                                            //情報の抽出
                                                            do {
                                                                //データ取得
                                                                let jsonData = try Data(contentsOf: openBDUrl)
                                                                
                                                                //JSONに変換
                                                                if let googleJson = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [[String: AnyObject]] {
                                                                    //情報取得
                                                                    if let items = googleJson[0]["summary"] as? [String: String] {
                                                                        Variables.shared.gottenTitle = items["title"]!
                                                                        Variables.shared.gottenPublisher = items["publisher"]!
                                                                        if items["cover"]! != "" {
                                                                            Variables.shared.gottenCover = items["cover"]!
                                                                        }
                                                                    }
                                                                }
                                                            } catch {
                                                                print(error)
                                                                canReflect = false
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    print("null")
                                    canReflect = false
                                }
                            } catch {
                                print(error)
                                canReflect = false
                            }
                            
                            DispatchQueue.main.sync {
                                var actionSheet = UIAlertController()
                                
                                if canReflect {
                                    actionSheet = UIAlertController(title: "BARCODE_SUCCESS".localized,
                                                                    message: "ISBN: \(readed)",
                                        preferredStyle: .actionSheet)
                                    
                                    let reflectAction = UIAlertAction(title: "BARCODE_REFLECT".localized, style: .default, handler:{
                                        (action: UIAlertAction!) -> Void in
                                        self.isDetected = false
                                        
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                    
                                    actionSheet.addAction(reflectAction)
                                    
                                    let amazonAction: UIAlertAction = UIAlertAction(title: "BARCODE_AMAZON".localized, style: .default, handler:{
                                        (action: UIAlertAction!) -> Void in
                                        self.isDetected = false
                                        
                                        let URLString = String(format: "https://www.amazon.co.jp/dp/%@", readed.isbnTenized)//amazonはISBN-10しか取らない
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        UIApplication.shared.openURL(URL(string: URLString)!)
                                    })
                                    
                                    actionSheet.addAction(amazonAction)
                                } else {
                                    actionSheet = UIAlertController(title: "BARCODE_FAILURE".localized,
                                                                    message: nil,
                                                                    preferredStyle: .actionSheet)
                                    
                                    let reflectAction = UIAlertAction(title: "BARCODE_NOTFOUND".localized, style: .default, handler: nil)
                                    
                                    reflectAction.isEnabled = false
                                    
                                    actionSheet.addAction(reflectAction)
                                    
                                    let amazonAction: UIAlertAction = UIAlertAction(title: "BARCODE_AMAZON".localized, style: .default, handler:{
                                        (action: UIAlertAction!) -> Void in
                                        self.isDetected = false
                                        
                                        let URLString = String(format: "https://www.amazon.co.jp/dp/%@", readed.isbnTenized)//amazonはISBN-10しか取らない
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        UIApplication.shared.openURL(URL(string: URLString)!)
                                    })
                                    
                                    actionSheet.addAction(amazonAction)
                                }
                                
                                let cancelAction: UIAlertAction = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler:{
                                    (action: UIAlertAction!) -> Void in
                                    self.isDetected = false
                                })
                                actionSheet.addAction(cancelAction)
                                
                                self.present(actionSheet, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    //MARK: - Method
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
