//
//  GroceryDetailsViewController.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/16/21.
//

import UIKit

class GroceryDetailsViewController: UIViewController {

    // MARK: Outlets and Variables
    @IBOutlet weak var glutenIndicatorLabel: UILabel!
    @IBOutlet weak var groceryImage: UIImageView!
    @IBOutlet weak var groceryTitleLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var allergensTextView: UITextView!
    
    // Variable to hold grocery from source
    var currentGrocery: Grocery!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Update UI with current grocery details
        if currentGrocery != nil {
            if currentGrocery.badges.contains("grain_free") {
                glutenIndicatorLabel.text = "Gluten-Free"
                glutenIndicatorLabel.textColor = UIColor(named: "glutenFreeGreen")
            }
            else {
                glutenIndicatorLabel.text = "Contains Gluten"
                glutenIndicatorLabel.textColor = UIColor(named: "warningRed")
            }
            groceryTitleLabel.text = currentGrocery.title
            caloriesLabel.text = String(currentGrocery.nutrition.calories)
            carbsLabel.text = currentGrocery.nutrition.carbs
            
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
