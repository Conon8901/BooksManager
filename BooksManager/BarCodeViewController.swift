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
    
    var addVC: AddViewController?
    
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
        previewView.bringSubview(toFront: instructLabel)
        
        //キャンセルボタンの生成
        cancelButton.setTitle("CANCEL".localized, for: .normal)
        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        previewView.bringSubview(toFront: cancelButton)
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
                        
                        var reflectAction = UIAlertAction()
                        
                        //GoogleBooksAPIに該当する本が登録されているか確認
                        let URLString = String(format: "https://www.googleapis.com/books/v1/volumes?q=isbn:%@", readed)
                        let url = URL(string: URLString)!
                        
                        var title: String?
                        var author: String?
                        var thumbnail: String?
                        
                        var canReflect = true
                        
                        //情報の抽出
                        do {
                            //データ取得
                            let jsonData = try Data(contentsOf: url)
                            
                            //JSONに変換
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: AnyObject]
                            
                            //題名・著者の取得
                            if let items = json["items"] as? [[String: AnyObject]] {
                                if let item = items.first {
                                    if let volumeInfo = item["volumeInfo"] as? [String: AnyObject] {
                                        if let titleString = volumeInfo["title"] as? String {
                                            title = titleString
                                        }
                                        
                                        if let authorsArray = volumeInfo["authors"] as? [String] {
                                            author = authorsArray.joined(separator: ", ")
                                        }
                                        
                                        if let imageLinks = volumeInfo["imageLinks"] as? [String: String] {
                                            thumbnail = imageLinks["thumbnail"]
                                        }
                                    }
                                }
                            } else {
                                canReflect = false
                            }
                        } catch {
                            print(error)
                            canReflect = false
                        }
                        
                        let actionSheet = UIAlertController(title: "BARCODE_SUCCESS".localized,
                                                            message: "ISBN: \(readed)",
                            preferredStyle: .actionSheet)
                        
                        if canReflect {
                            reflectAction = UIAlertAction(title: "BARCODE_REFLECT".localized, style: .default, handler:{
                                (action: UIAlertAction!) -> Void in
                                self.isDetected = false
                                
                                self.addVC?.titleByBarcode = title
                                self.addVC?.authorByBarcode = author
                                self.addVC?.thumbnailByBarcode = thumbnail
                                
                                self.dismiss(animated: true, completion: nil)
                            })
                        } else {
                            reflectAction = UIAlertAction(title: "BARCODE_UNABLE".localized, style: .default, handler: nil)
                            
                            reflectAction.isEnabled = false
                        }
                        
                        let amazonAction: UIAlertAction = UIAlertAction(title: "BARCODE_AMAZON".localized, style: .default, handler:{
                            (action: UIAlertAction!) -> Void in
                            self.isDetected = false
                            
                            let URLString = String(format: "https://www.amazon.co.jp/dp/%@", self.convertToISBNTen(readed)!)//amazonはISBN-10しか取らない
                            UIApplication.shared.openURL(URL(string: URLString)!)
                        })
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler:{
                            (action: UIAlertAction!) -> Void in
                            self.isDetected = false
                        })
                        
                        actionSheet.addAction(reflectAction)
                        actionSheet.addAction(amazonAction)
                        actionSheet.addAction(cancelAction)
                        
                        self.present(actionSheet, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //MARK: - Method
    
    func convertToISBNTen(_ value: String) -> String? {
        let picked = String(value[value.index(value.startIndex, offsetBy: 3)...value.index(value.startIndex, offsetBy: 11)])
        
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
    
    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
