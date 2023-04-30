
//
//  Grocery.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/16/21.
//

import UIKit

// Struct to parse data from json
struct ScannedGrocery: Codable {
   
   var title: String
   var badges: [String]
   var nutrition: Nutrition
   var upc: String
   var images: [String]
}

// Class to store parsed data with list for user editing
class Grocery: Codable {
   var title: String!
   var badges: [String]!
   var nutrition: Nutrition!
   var upc: String!
   var image: String!
   var checkList = [false, false, false, false, false, false, false, false]
   // Property to determine if grocery should be added to check list
   var checked = false
   
   // Initailizer
   init(title: String, badges: [String], nutrition: Nutrition, upc: String, images: [String]) {
       self.title = title
       self.badges = badges
       self.nutrition = nutrition
       self.upc = upc
       self.image = images[0]
   }
   
   
   // Function to convert url to image
   func loadImage() async -> UIImage {
              
       var groceryImage: UIImage!
       // Use do-catch to download image
       do {
           if let url = URL(string: self.image) {
               let data = try Data(contentsOf: url)
               groceryImage = UIImage(data: data)
           }
       }
       // Or set to default image
       catch {
           groceryImage = UIImage(named: "defaultImage")
       }
       return groceryImage
   }
}
