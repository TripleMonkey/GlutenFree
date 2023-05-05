
 //
 //  CustomTabBarController.swift
 //  GlutenFreeFinder
 //
 //  Created by Nigel Krajewski on 1/21/21.
 //
 
 import UIKit
 import Firebase
 
 class CustomTabBarController: UITabBarController {
    
    var searchHistory: [Grocery] = []
    
    // Firebase: get reference for storage
    let database = Database.database()
    let ref = Database.database().reference(withPath: "groceries")
    
    // MARK: View overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add shadow at top of controller
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowOpacity = 0.4
        
        // Firebase: initialize reference
        ref.observe(.value, with: { [self] snapshot in
            guard let groceryToLoad = snapshot.value as? Grocery
            else { return }
            self.searchHistory.append(groceryToLoad)
        })
    }
    
    
    // Function to update search history
    func updateHistory(with grocery: Grocery) {
        // Check scanned upc against search list
        
        // Remove duplicate grocery if exists
        for i in 0..<searchHistory.count {
            if searchHistory[i].upc == grocery.upc {
                searchHistory.remove(at: i)
                break
            }
        }
        // Then add new grocery to beginning of list
        searchHistory.insert(grocery, at: 0)
        // DEBUG:
        print(searchHistory.count)
        // Add grocery to firebase
        addToFirebase(grocery)
        
        // DEBUG:
        print(searchHistory.count)
    }
    
    
    func addToFirebase(_ grocery: Grocery) {
        
        let groceryToAdd = ["title": grocery.title, "checked": grocery.checked, "image": grocery.image] as [String : Any]
        
        let groceryRef = self.ref.child("\(grocery.title.lowercased())")
        let badges = groceryRef.child("badges")
        let checkList = groceryRef.child("checkList")
        let nutrition = groceryRef.child("nutrition")
        let calories = nutrition.child("calories")
        let fat = nutrition.child("fat")
        let protein = nutrition.child("protein")
        let carbs = nutrition.child("carbs")
        groceryRef.setValue(groceryToAdd)
        badges.setValue(grocery.badges)
        checkList.setValue(grocery.checkList)
        calories.setValue(grocery.nutrition.calories)
        fat.setValue(grocery.nutrition.fat)
        protein.setValue(grocery.nutrition.protein)
        carbs.setValue(grocery.nutrition.carbs)
        
    }
    
 }
