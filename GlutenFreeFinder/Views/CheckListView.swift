
//
//  CheckListView.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/26/21.
//

import UIKit
import Firebase
 
class CheckListView: UIView {
    
    // MARK: Outlets and variables
    
    @IBOutlet var checkListView: UIView!
    @IBOutlet weak var groceryImage: UIImageView!
    @IBOutlet weak var groceryTitle: UILabel!
    @IBOutlet weak var glutenIndicator: UILabel!
    @IBOutlet weak var cellAccessory: UIButton!
    
    // Firebase: get reference for storage
    let database = Database.database()
    let ref = Database.database().reference(withPath: "groceries")
    
    // calculated property for grocery details
    var grocery: Grocery! {
        // Using didSet will update grocery for xib each time new cell is loaded in tableview
        didSet {
            groceryImage.image = grocery.loadImage()
            groceryTitle.text = grocery.title
            if grocery.badges.contains("gluten_free") {
                self.glutenIndicator.textColor = UIColor(named: "glutenFreeGreen")
                self.glutenIndicator.text = "Gluten-Free"
            }
            else {
                self.glutenIndicator.textColor = UIColor(named: "warningRed")
                self.glutenIndicator.text = "May Contain Gluten"
            }
            // Loop thru user impression of grocery
            for int in 0..<grocery.checkList.count {
                // Cast button with matching tag
                guard let button = self.viewWithTag(int+1) as? UIButton
                else { return }
                // Set button state to match grocery checklist
                button.isSelected = grocery.checkList[int]
            }
        }
    }
    
    // MARK: Initializers
    
    // Initilizer for code
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkListViewInit()
    }
    // Initializer for storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        checkListViewInit()
    }
    
    // Function to initialize with view constraints
    func checkListViewInit() {
        Bundle.main.loadNibNamed("CheckListView", owner: self, options: nil)
        checkListView.translatesAutoresizingMaskIntoConstraints = false
        // Add checklistView (xib) as subview to make available when CheckListView (class) is initialized
        addSubview(checkListView)
        self.backgroundColor = .clear
        checkListView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        checkListView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        checkListView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        checkListView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    // MARK: IBActions
    
    // Action to handle checklist button taps
    @IBAction func buttonTap(_ sender: UIButton) {
        let tappedButton = sender
        // Edit view and grocery
        tappedButton.isSelected.toggle()
        grocery.checkList[sender.tag-1].toggle()
        grocery.checked = true
        
        // Pass and fail should not be selected at same time
        // If either button is tpped other should be deselected
        let passButton = viewWithTag(1) as! UIButton
        let failButton = viewWithTag(5) as! UIButton
        if tappedButton == passButton {
            failButton.isSelected = false
            grocery.checkList[4] = false
        }
        if tappedButton == failButton {
            passButton.isSelected = false
            grocery.checkList[0] = false
        }
        // Update firebase
        let groceryRef = self.ref.child("\(grocery.title.lowercased())")
        let checkList = groceryRef.child("checkList")
        let checked = groceryRef.child("checked")
        checkList.setValue(grocery.checkList)
        checked.setValue(grocery.checked)
    }
}
