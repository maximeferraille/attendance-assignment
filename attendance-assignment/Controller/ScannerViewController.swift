//
//  ScannerViewController.swift
//  attendance-assignment
//
//  Created by Maxime Ferraille on 26/04/2018.
//  Copyright © 2018 Maxime Ferraille. All rights reserved.
//
// This file is based from the tutorial : https://www.appcoda.com/barcode-reader-swift/
// Because it's compatible with the last ios version & swift 4

import UIKit
import AVFoundation

// For the test we didn't have acces to an ios device, so we used a little "hack" : simulate the video preview layer with a static image from image gallery
class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var messageLabel:UILabel!
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var beaconsArray : Array<Int>?
    
    private let qrCodeTypes = AVMetadataObject.ObjectType.qr // We just use 1 AVMetadataObject type : Qr code
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func postQrCode(data: String) {
        let u = URL(string: "http://localhost/api/checkIn")
        var request = URLRequest(url: u!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let userToken   = appDelegate?.userToken
        
        let bodyObject = [
            "QRCodeData" : data,
            "date": "",
            "beaconCollection": beaconsArray!, // At this case we are sure beacons array is not empty
            "Token": String(describing: userToken)
            ] as [String : Any]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])

        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            if error != nil {
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
                let alert = UIAlertController(title: "Succes", message: "You have done well", preferredStyle:   UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    appDelegate?.isPresent = true
                    self.navigationController?.popViewController(animated: true) // Return to precedent view when user accept the alert
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        task.resume()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if qrCodeTypes == metadataObj.type {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let qrCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = qrCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                if beaconsArray != nil { // just in case, if a bug occured with InformationViewController who push scannerviewcontroller without beaconsArray
                    postQrCode(data: metadataObj.stringValue!)
                }
            }
        }
    }
}

