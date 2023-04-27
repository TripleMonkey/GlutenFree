
//
//  CheckListTableViewController.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/25/21.
//

import UIKit

class CheckListTableViewController: UITableViewController {

    // MARK: Outlets and Variables
    
    var tabBar: CustomTabBarController!
    
    var checkedHistory = [Grocery?]()
    
    
    
    // MARK: View overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set tabBarController to CustomTabBar for access to search history
        tabBar = self.tabBarController as? CustomTabBarController
        // Use filter to add only groceries that have been checked to list
        if !tabBar.searchHistory.isEmpty {
            checkedHistory = tabBar.searchHistory.filter({ $0.checked == true})
        // Update table view
        self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return 1 section
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return count of groceries in history
        return checkedHistory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Initialize cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListTableViewCell", for: indexPath) as! CheckListTableViewCell
        // Get grocery from search history
        guard let grocery = checkedHistory[indexPath.row]
        else { return cell }
        cell.checkListView.grocery = grocery
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "CheckListDetails", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "CheckListDetails",
           let indexPath = tableView.indexPathForSelectedRow,
           let destination = segue.destination as? GroceryDetailsViewController {
            let selectedGrocery = tabBar.searchHistory[indexPath.row]
            // Set title for new nav view
            destination.navigationItem.title = "Details"
            // Pass the selected object to the new view controller.
            destination.currentGrocery = selectedGrocery
        }
    }
}
