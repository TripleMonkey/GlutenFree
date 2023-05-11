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
    // Variable to hold scanned grocery
    var currentGrocery: Grocery?
    // Dispatch queue for session requests
    let sessionQueue = DispatchQueue(label: "session queue")
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
        AVMetadataObject.ObjectType.upce
    ]
    // History View Controller
    var historyVC = HistoryViewController.shared
   // var searchHistory = [Grocery?]()
    
    // MARK: View Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchHistory = HistoryViewController().searchHistory
        print("Starting history count: \(historyVC.searchHistory.count)")
        // Set background color
        view.backgroundColor = UIColor(named: "backgroundYellowColor")
        // Call capture session for scanner
        createSession()
        // Begin scanner
        runScan()
    }
    
    // Start scanner when returning to scan view
    override func viewWillAppear(_ animated: Bool) {
        runScan()
        //searchHistory = tabBar.searchHistory
    }
    
    // Stop scan when view covered
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    // MARK: Capture session functions
    // Function to create capture session
    func createSession() {
        // Create discovery session to access rear camera for capturing video
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: .back)
        // Asign device from discovery session
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
            // Initialize video preview
            initializeScannerView(session: captureSession)
        }
        catch {
            // Print any error and end
            //ADD: Add alert
            print(error)
            return
        }
    }
    
    func initializeScannerView(session: AVCaptureSession) {
        // Initialize video preview layer and add as sublayer to viewPreview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        // Show message label in front of video
        view.bringSubviewToFront(messageView)
        view.bringSubviewToFront(messageLabel)
    }
    
    // Call optional protocol function metaDataOutput to process metadata input
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Create metadata object as machine readable code object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        // Create string from bar code
        if codeList.contains(metadataObj.type) {
            guard let upcString = metadataObj.stringValue
            else { return }
            // Stop session if code detected
            captureSession.stopRunning()
            Task {
                await updateGrocery(from: upcString)
                // If parse successful or if grocery exists in search history perform segue to details view
                if currentGrocery != nil {
                    self.performSegue(withIdentifier: "groceryDetails", sender: self)
                    // Add to history
   //                 tabBar?.updateHistory(with: currentGrocery!)
                    // Clear currentGrocery
                    currentGrocery = nil
                    // Reset capture session
                    
                }
                else {
                    // Present alert to notify grocery not found in database
                    // Create alert
                    let notFoundAlert = UIAlertController(title: "Grocery not found", message: "Try again", preferredStyle: UIAlertController.Style.alert)
                    // Create OK button
                    let okButton = UIAlertAction(title: "OK", style: .cancel) {_ in
                        self.runScan()
                    }
                    // Add button to alert
                    notFoundAlert.addAction(okButton)
                    // Show alert
                    self.present(notFoundAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Function to start scanner
    func runScan() {
        // Capture session must run on its own queue to avoid blocking main
        sessionQueue.async {
            // Begin video capture
            self.captureSession.startRunning()
        }
    }
    
    // MARK: Update grocery
    func updateGrocery(from upcString: String) async {
        // Trim UPC for Spoonacular API
        var trimmedUPC = upcString
        trimmedUPC.removeFirst()
        // variable to track if match found in existing history
        var matched = false
        
        for i in 0..<historyVC.searchHistory.count {
            if historyVC.searchHistory[i].upc == trimmedUPC {
                // Match found in history, use that grocery
                currentGrocery = historyVC.searchHistory[i]
                matched = true
            }
        }
        // If no match or history is empty call to api
        if matched == false || historyVC.searchHistory.isEmpty {
            // Session for async task
            let session = URLSession.shared
            // Get API Key from bundle
            if let apiKey = Bundle.main.infoDictionary? ["SPOONACULAR_API_KEY"] as? String {
                // Call to Spoonacular API
                guard let upcApiCall = URL(string: "https://api.spoonacular.com/food/products/upc/\(trimmedUPC)?apiKey=\(apiKey)")
                else {
                    print(apiKey)
                    return
                }
                // Create data from api call
                do {
                    let (data, _) = try await session.data(from: upcApiCall)
                    // Create grocery from api data
                    currentGrocery = Grocery(apiData: data)
                    // Add groceery to search history
                    guard currentGrocery?.upc != "0", let grocery = currentGrocery else { return }
                        historyVC.searchHistory.append(grocery)
                        print("Grocery added to history: Count \(historyVC.searchHistory.count)")
                    
                    // Exit loop if successful
                   // return
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Make sure currentGrocery not nil before performing segue
        if identifier == "groceryDetails" && currentGrocery == nil {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass current grocery to details controller.
        if let destination = segue.destination as? GroceryDetailsViewController {
            // Set title for new nav view
            destination.navigationItem.title = "Results"
            destination.currentGrocery = currentGrocery
        }
    }
}
