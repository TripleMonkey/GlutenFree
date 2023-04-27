
//
//  PopUpViewController.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/28/21.
//

import UIKit
 
class PopUpViewController: UIViewController {

    // MARK: Properties
    var currentGrocery: Grocery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set button states based on bool list from source
        for int in 1...8 {
            guard let button = self.view.viewWithTag(int) as? UIButton
            else { return }
            button.isSelected = currentGrocery.checkList[int-1]
        }
    }
    
    // Action to handle checklist button taps
    @IBAction func buttonTap(_ sender: UIButton) {
        let tappedButton = sender
        // Edit view and grocery
        tappedButton.isSelected.toggle()
        currentGrocery.checkList[sender.tag-1].toggle()
        
        // Pass and fail should not be selected at same time
        // If either button is tpped other should be deselected
        let passButton = view.viewWithTag(1) as! UIButton
        let failButton = view.viewWithTag(5) as! UIButton
        if tappedButton == passButton {
            failButton.isSelected = false
            currentGrocery.checkList[4] = false
        }
        if tappedButton == failButton {
            passButton.isSelected = false
            currentGrocery.checkList[0] = false
        }
        
    }
    
    @IBAction func doneButtonTap(_ sender: UIButton) {
        // Dismiss view
        super.dismiss(animated: true, completion: nil)
    }
}
