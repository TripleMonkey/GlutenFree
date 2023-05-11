
//
//  HistoryTableViewController.swift
//  GlutenFreeFinder
//
//  Created by Nigel Krajewski on 1/20/21.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    // MARK: Outlets and Variables
    
    var historyVC: HistoryViewController = HistoryViewController.shared
    
    var searchHistory = [Grocery?]()
    
    
    // MARK: View overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set tabBarController to CustomTabBar for access to search history
       // historyVC = self.tabBarController as? HistoryViewController
        searchHistory = historyVC.searchHistory
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return 1 section
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return count of groceries in history
        return searchHistory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Initialize cell
        let cell: HistoryTableViewCell = HistoryTableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "historyGroceryCell")
        
        // Get grocery from search history
        guard let grocery = searchHistory[indexPath.row]
        else { return cell }
        
        cell.textLabel?.text = grocery.title
        if grocery.badges.contains("gluten_free") {
            cell.detailTextLabel?.textColor = UIColor(named: "glutenFreeGreen")
            cell.detailTextLabel?.text = "Gluten-Free"
        }
        else {
            cell.detailTextLabel?.textColor = UIColor(named: "warningRed")
            cell.detailTextLabel?.text = "May Contain Gluten"
        }
        
        // Display grocery image
        Task {
            cell.imageView?.image = await grocery.loadImage()
        }
        cell.imageView?.bounds = CGRect(x: 0, y: 0, width: cell.frame.height * 0.5, height: cell.frame.height * 0.5)
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "HistoryDetails", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "HistoryDetails",
           let indexPath = tableView.indexPathForSelectedRow,
           let destination = segue.destination as? GroceryDetailsViewController {
            let selectedGrocery = historyVC.searchHistory[indexPath.row]
            // Set title for new nav view
            destination.navigationItem.title = "Details"
            // Pass the selected object to the new view controller.
            destination.currentGrocery = selectedGrocery
        }
    }
}
