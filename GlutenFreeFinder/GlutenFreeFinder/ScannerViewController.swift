//
//  ScannerViewController.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/7/21.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: Outlets and variables
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // Variables to create video capture
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var codeFrameView: UIView?
    
    // List of possibe metadata object types for qr and bar codes
    var codeList = [
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.qr,
        AVMetadataObject.ObjectType.upce
    ]
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set background color
        view.backgroundColor = UIColor(named: "backgroundYellowColor")
        
        // Create discovery session to access rear camera for capturing video
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        // Asign device from discovery sesion
        guard let captureDevice = deviceDiscoverySession.devices.first
        else { print("Failed to access camera"); return }
        
        // Use Do-Catch to create input to add to capture session
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Add input to capture session
            captureSession.addInput(input)
            
            // Initialize AVCaptureMetadataOutput object and set as output device to capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate as self and use default queue for callback
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Set types of metadata objects for output
            captureMetadataOutput.metadataObjectTypes = codeList
            
            // Initialize video preview layer and add as sublayer to viewPreview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Show message label in front of video
            view.bringSubviewToFront(messageView)
            view.bringSubviewToFront(messageLabel)
            
            // Initialize Code frame to highlight qr/bar code
            codeFrameView = UIView()
            if let codeFrameView = codeFrameView {
                codeFrameView.layer.borderColor = UIColor.green.cgColor
                codeFrameView.layer.borderWidth = 2
                view.addSubview(codeFrameView)
                view.bringSubviewToFront(codeFrameView)
            }
        }
        catch {
            // Print any error and end
            print(error)
            return
        }
        
        // Begin video capture
        captureSession.startRunning()
    }
    
    // Call optional protocol function metaDataOutput to process metadata input
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // If no code found present instructions in messageLabel
        if metadataObjects.count == 0 {
            codeFrameView?.frame = CGRect.zero
            messageLabel.text = "Center code on screen to scan."
            return
        }
        
        // Create metadata object as machine readable code object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Create frame around code when match found
        if codeList.contains(metadataObj.type) {
            let codeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            codeFrameView?.frame = codeObject!.bounds
            
            // Show
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}

