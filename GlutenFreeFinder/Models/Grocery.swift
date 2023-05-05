
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
    var title: String = "Not Found"
    var badges: [String] = []
    var nutrition: Nutrition = Nutrition(calories: 0, fat: "n/a", protein: "n/a", carbs: "n/a")
    var upc: String = "0"
    var image: String = "n/a"
    var checkList = [false, false, false, false, false, false, false, false]
    // Property to determine if grocery should be added to check list
    var checked = false
    
    // MARK: Init
    init(apiData: Data) {
        // Create JSON Decoder
        let decoder = JSONDecoder()
        // Decode data and update grocery with results
        if let scannedGrocery = try? decoder.decode(ScannedGrocery.self, from: apiData) {
            self.title = scannedGrocery.title
            self.badges = scannedGrocery.badges
            self.nutrition = scannedGrocery.nutrition
            self.upc = scannedGrocery.upc
            self.image = scannedGrocery.images[0]
        }
        
    }
    
    //MARK: Methods
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
